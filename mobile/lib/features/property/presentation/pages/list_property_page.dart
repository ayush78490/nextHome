import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/location_picker_map.dart';
import '../providers/property_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/property.dart';

class ListPropertyPage extends ConsumerStatefulWidget {
  final Property? existingProperty;

  const ListPropertyPage({super.key, this.existingProperty});

  @override
  ConsumerState<ListPropertyPage> createState() => _ListPropertyPageState();
}

class _ListPropertyPageState extends ConsumerState<ListPropertyPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Client Details
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _clientCityController = TextEditingController();
  final _clientAddressController = TextEditingController();

  // Dropdown values
  String? _selectedPropertyType;
  String? _selectedListingType;

  // Property Information
  final _titleController = TextEditingController();
  final _propertyTypeController = TextEditingController();
  final _listingTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();

  final List<String> _propertyTypes = AppConstants.propertyTypes;
  final List<String> _listingTypes = ['Rent', 'Sale'];

  final Dio _dio = Dio();

  // Numeric Counters
  int _landSqft = 0;
  int _constructionSqft = 0;
  int _bedrooms = 0;
  int _bathrooms = 0;
  int _parkingLots = 0;
  int _kitchen = 0;

  // Facilities & Locality
  final List<String> _availableFacilities = [
    'WiFi',
    'Pool',
    'Gym',
    'Parking',
    'AC',
    'Heater',
    'Balcony',
    'Garden',
    'Security'
  ];
  List<String> _selectedFacilities = [];
  final _localityDestController = TextEditingController();
  final _localityDistController = TextEditingController();

  // Images
  List<String> _uploadedImages = [];
  List<String> _existingNetworkImages = [];

  // Terms
  bool _acceptedTerms = false;

  bool _showMap = false;

  bool get _isFormValid {
    if (_firstNameController.text.trim().isEmpty) return false;
    if (_lastNameController.text.trim().isEmpty) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (_phoneController.text.trim().isEmpty) return false;
    if (_clientCityController.text.trim().isEmpty) return false;
    if (_clientAddressController.text.trim().isEmpty) return false;
    if (_titleController.text.trim().isEmpty) return false;
    if (_selectedPropertyType == null) return false;
    if (_selectedListingType == null) return false;
    if (_priceController.text.trim().isEmpty) return false;
    if (_descriptionController.text.trim().isEmpty) return false;
    if (_countryController.text.trim().isEmpty) return false;
    if (_stateController.text.trim().isEmpty) return false;
    if (_cityController.text.trim().isEmpty) return false;
    if (_addressController.text.trim().isEmpty) return false;
    if (_zipCodeController.text.trim().isEmpty) return false;
    if (_localityDestController.text.trim().isEmpty) return false;
    if (_localityDistController.text.trim().isEmpty) return false;

    // Minimum 4 images
    if (_uploadedImages.length + _existingNetworkImages.length < 4) return false;

    // Terms
    if (!_acceptedTerms) return false;

    return true;
  }

  void _onFieldChanged() {
    setState(() {}); // trigger rebuild to update button state
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingProperty != null) {
      final p = widget.existingProperty!;
      _titleController.text = p.title;
      _priceController.text = p.price;
      _addressController.text = p.address;

      _landSqft = int.tryParse(p.sqft) ?? 0;
      _bedrooms = int.tryParse(p.beds) ?? 0;
      _bathrooms = int.tryParse(p.baths) ?? 0;
      _selectedPropertyType = _propertyTypes.contains(p.category) ? p.category : null;
      _selectedFacilities = List.from(p.facilities);

      if (p.locality.contains(' - ')) {
        final parts = p.locality.split(' - ');
        _localityDestController.text = parts[0];
        if (parts.length > 1) {
          _localityDistController.text = parts[1];
        }
      } else {
        _localityDestController.text = p.locality;
      }

      _existingNetworkImages = List.from(p.imageUrls);
    }

    final controllers = [
      _firstNameController,
      _lastNameController,
      _emailController,
      _phoneController,
      _clientCityController,
      _clientAddressController,
      _titleController,
      _priceController,
      _descriptionController,
      _countryController,
      _stateController,
      _zipCodeController,
      _cityController,
      _addressController,
      _localityDestController,
      _localityDistController,
    ];
    for (var c in controllers) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _clientCityController.dispose();
    _clientAddressController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _localityDestController.dispose();
    _localityDistController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (_uploadedImages.length + images.length > 8) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 8 images allowed.')),
          );
        }
        return;
      }
      setState(() {
        _uploadedImages.addAll(images.map((e) => e.path));
      });
    }
  }

  void _fetchZipDetails(String zip) async {
    if (zip.length < 4) return;
    try {
      final key = AppConstants.googleMapsKey;
      if (key.isEmpty) return;
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {'address': zip, 'key': key},
      );
      final results = response.data['results'] as List;
      if (results.isEmpty) return;

      final addressComponents = results.first['address_components'] as List;
      String city = '', state = '', country = '';

      for (var comp in addressComponents) {
        final types = comp['types'] as List;
        if (types.contains('locality') || types.contains('administrative_area_level_2')) {
          city = comp['long_name']?.toString() ?? '';
        }
        if (types.contains('administrative_area_level_1')) {
          state = comp['long_name']?.toString() ?? '';
        }
        if (types.contains('country')) {
          country = comp['long_name']?.toString() ?? '';
        }
      }

      setState(() {
        if (city.isNotEmpty) {
          _cityController.text = city;
        }
        if (state.isNotEmpty) {
          _stateController.text = state;
        }
        if (country.isNotEmpty) {
          _countryController.text = country;
        }
      });
    } catch (e) {
      debugPrint('Error getting zip details: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1,
      TextInputType? keyboardType,
      String? Function(String?)? validator,
      bool readOnly = false,
      Widget? suffixIcon,
      ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          validator: validator,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(color: readOnly ? Colors.white54 : Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: const Color(0x0DF8F9FA), // Transparent white
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D2D44)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D2D44)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF42898E), width: 2),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildPlacesAutocomplete(String label, TextEditingController controller, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.length < 2) return const Iterable<String>.empty();
            try {
              final response = await _dio.post(
                'https://places.googleapis.com/v1/places:autocomplete',
                options: Options(headers: {
                  'X-Goog-Api-Key': AppConstants.googleMapsKey,
                  'Content-Type': 'application/json',
                }),
                data: {
                  'input': textEditingValue.text,
                  'includedPrimaryTypes': [type],
                },
              );
              final suggestions = response.data['suggestions'] as List?;
              if (suggestions == null) return const Iterable<String>.empty();
              return suggestions
                  .map((s) => s['placePrediction']['text']['text'] as String)
                  .toList();
            } catch (e) {
              return const Iterable<String>.empty();
            }
          },
          displayStringForOption: (String option) => option.split(',').first.trim(),
          onSelected: (String selection) {
            final cleanSelection = selection.split(',').first.trim();
            controller.text = cleanSelection;
            _onFieldChanged();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            // Keep external controller synced
            textEditingController.addListener(() {
              if (controller.text != textEditingController.text) {
                controller.text = textEditingController.text;
                _onFieldChanged();
              }
            });
            controller.addListener(() {
              if (textEditingController.text != controller.text) {
                textEditingController.text = controller.text;
              }
            });

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (val) {
                if (val == null || val.isEmpty) return null;
                return null;
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                filled: true,
                fillColor: const Color(0x0DF8F9FA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D2D44))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D2D44))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF42898E), width: 2)),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                color: const Color(0xFF1B365D),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option, style: const TextStyle(color: Colors.white)),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item,
                  style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1B365D),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: const Color(0x0DF8F9FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D2D44)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D2D44)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF42898E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterField(
      String label, int value, VoidCallback onIncrement, VoidCallback onDecrement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0x0DF8F9FA), // Transparent white
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2D2D44)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 14)),
              Row(
                children: [
                  GestureDetector(
                    onTap: onDecrement,
                    child: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  ),
                  GestureDetector(
                    onTap: onIncrement,
                    child: const Icon(Icons.arrow_drop_up, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B2B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.existingProperty != null ? 'Edit Property' : 'List Property',
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Details
              _buildSectionTitle('Client Details', 'information about the property owner'),
              Row(
                children: [
                  Expanded(child: _buildTextField('First Name', _firstNameController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Last Name', _lastNameController)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Email Address', _emailController,
                        keyboardType: TextInputType.emailAddress, validator: (val) {
                      if (val == null || val.isEmpty) return null;
                      final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(val)) return 'Invalid email format';
                      return null;
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Phone Number', _phoneController,
                        keyboardType: TextInputType.phone, validator: (val) {
                      if (val == null || val.isEmpty) return null;
                      final RegExp phoneRegExp = RegExp(r'^\+?[0-9]{10,14}$');
                      if (!phoneRegExp.hasMatch(val)) return 'Invalid phone number';
                      return null;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('City', _clientCityController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Address', _clientAddressController)),
                ],
              ),
              const SizedBox(height: 32),

              // Property Information
              _buildSectionTitle('Property Information', 'information about the property'),
              _buildTextField('Listing Title', _titleController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                        'Property Type', _propertyTypes, _selectedPropertyType, (val) {
                      setState(() {
                        _selectedPropertyType = val;
                      });
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField('Listing Type', _listingTypes, _selectedListingType,
                        (val) {
                      setState(() {
                        _selectedListingType = val;
                      });
                    }),
                  ),
                ],
              ),
              _buildTextField('Price', _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildCounterField(
                        'Land sqft.',
                        _landSqft,
                        () => setState(() => _landSqft += 100),
                        () => setState(() => _landSqft = (_landSqft - 100).clamp(0, 99999))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCounterField(
                        'Construction sqft.',
                        _constructionSqft,
                        () => setState(() => _constructionSqft += 100),
                        () => setState(
                            () => _constructionSqft = (_constructionSqft - 100).clamp(0, 99999))),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildCounterField(
                        'Bedrooms',
                        _bedrooms,
                        () => setState(() => _bedrooms++),
                        () => setState(() => _bedrooms = (_bedrooms - 1).clamp(0, 20))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCounterField(
                        'Bathrooms',
                        _bathrooms,
                        () => setState(() => _bathrooms++),
                        () => setState(() => _bathrooms = (_bathrooms - 1).clamp(0, 20))),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildCounterField(
                        'Parking Lots',
                        _parkingLots,
                        () => setState(() => _parkingLots++),
                        () => setState(() => _parkingLots = (_parkingLots - 1).clamp(0, 20))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCounterField('Kitchen', _kitchen, () => setState(() => _kitchen++),
                        () => setState(() => _kitchen = (_kitchen - 1).clamp(0, 10))),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField('Description', _descriptionController, maxLines: 5),
              const SizedBox(height: 24),

              // Locality
              _buildSectionTitle('Locality', 'Destination and distance'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField('Destination (e.g. Airport)', _localityDestController),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildTextField('Distance (e.g. 5km)', _localityDistController),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Facilities
              _buildSectionTitle('Facilities', 'Select available facilities'),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _availableFacilities.map((facility) {
                  final isSelected = _selectedFacilities.contains(facility);
                  return FilterChip(
                    label: Text(facility,
                        style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedFacilities.add(facility);
                        } else {
                          _selectedFacilities.remove(facility);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF42898E),
                    backgroundColor: const Color.fromARGB(255, 0, 78, 102),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                        color: isSelected ? const Color(0xFF42898E) : const Color(0xFF2D2D44)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Image Upload
              const Text('Image (Min 4, Max 8)',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF42898E).withOpacity(0.5),
                        width: 2,
                        style: BorderStyle.solid), // Fallback solid if no dotted border
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cloud_upload_outlined, color: Color(0xFF42898E), size: 32),
                      SizedBox(height: 8),
                      Text('Tap to Upload Image',
                          style: TextStyle(color: Color(0xFF42898E), fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_uploadedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _uploadedImages.asMap().entries.map((entry) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(entry.value)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          top: -5,
                          child: GestureDetector(
                            onTap: () => _removeImage(entry.key),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              if (_existingNetworkImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Existing Images',
                    style:
                        TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _existingNetworkImages.asMap().entries.map((entry) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(entry.value),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          top: -5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _existingNetworkImages.removeAt(entry.key);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              _buildTextField('Address', _addressController,
                  suffixIcon: IconButton(
                    icon:
                        Icon(Icons.map, color: _showMap ? const Color(0xFF42898E) : Colors.white54),
                    onPressed: () {
                      setState(() {
                        _showMap = !_showMap;
                      });
                    },
                  )),
              if (_showMap) ...[
                const SizedBox(height: 16),
                LocationPickerMap(
                  onLocationSelected: (lat, lng, address) async {
                    _addressController.text = address;
                    try {
                      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
                      if (placemarks.isNotEmpty) {
                        final p = placemarks.first;
                        setState(() {
                          if (p.locality != null && p.locality!.isNotEmpty) {
                            _cityController.text = p.locality!;
                          }
                          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
                            _stateController.text = p.administrativeArea!;
                          }
                          if (p.country != null && p.country!.isNotEmpty) {
                            _countryController.text = p.country!;
                          }
                          if (p.postalCode != null && p.postalCode!.isNotEmpty) {
                            _zipCodeController.text = p.postalCode!;
                          }
                        });
                      }
                    } catch (e) {
                      debugPrint('Reverse geocoding error: $e');
                    }
                    _onFieldChanged();
                  },
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildPlacesAutocomplete('Country', _countryController, 'country')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPlacesAutocomplete('City', _cityController, 'locality')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildPlacesAutocomplete(
                          'State', _stateController, 'administrative_area_level_1')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField('ZIP Code', _zipCodeController,
                          keyboardType: TextInputType.number, onChanged: _fetchZipDetails)),
                ],
              ),
              const SizedBox(height: 24),

              // Terms & Conditions
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: (val) {
                        setState(() {
                          _acceptedTerms = val ?? false;
                        });
                      },
                      activeColor: const Color(0xFF42898E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms and Conditions and Privacy Policy.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Post Property Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isFormValid && !_isLoading)
                      ? () async {
                          setState(() => _isLoading = true);
                          try {
                            final data = {
                              'firstName': _firstNameController.text.trim(),
                              'lastName': _lastNameController.text.trim(),
                              'email': _emailController.text.trim(),
                              'phone': _phoneController.text.trim(),
                              'clientCity': _clientCityController.text.trim(),
                              'title': _titleController.text.trim(),
                              'propertyType': _selectedPropertyType ?? '',
                              'listingType': _selectedListingType ?? '',
                              'price': double.tryParse(_priceController.text.trim()) ?? 0,
                              'description': _descriptionController.text.trim(),
                              'country': _countryController.text.trim(),
                              'state': _stateController.text.trim(),
                              'city': _cityController.text.trim(),
                              'address': _addressController.text.trim(),
                              'zipCode': _zipCodeController.text.trim(),
                              'landSqft': _landSqft,
                              'constructionSqft': _constructionSqft,
                              'bedrooms': _bedrooms,
                              'bathrooms': _bathrooms,
                              'parkingLots': _parkingLots,
                              'kitchen': _kitchen,
                              'facilities': _selectedFacilities,
                              'locality':
                                  '${_localityDestController.text.trim()} - ${_localityDistController.text.trim()}',
                            };

                            if (widget.existingProperty != null) {
                              data['existingImages'] = _existingNetworkImages;
                              await ref.read(propertyProvider.notifier).updateProperty(
                                  widget.existingProperty!.id, data, _uploadedImages);
                            } else {
                              await ref
                                  .read(propertyProvider.notifier)
                                  .createProperty(data, _uploadedImages);
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(widget.existingProperty != null
                                        ? 'Property Updated Successfully!'
                                        : 'Property Posted Successfully!')),
                              );
                              context.pop();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to post property: $e'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42898E),
                    disabledBackgroundColor: Colors.grey[800],
                    disabledForegroundColor: Colors.white54,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.existingProperty != null ? 'Update Property' : 'Post Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserEntity user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      // Optionally upload immediately or wait for save button
      await _uploadImage(pickedFile.path);
    }
  }

  Future<void> _uploadImage(String path) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).uploadAvatar(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // If email didn't change or if it's a google auth user, don't send email field
      final emailToSend = (widget.user.isGoogleAuth || _emailController.text == widget.user.email)
          ? null
          : _emailController.text;

      await ref.read(authProvider.notifier).updateProfile(
            fullName: _nameController.text,
            phone: _phoneController.text,
            email: emailToSend,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B2B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text('Edit Profile', style: TextStyle(color: Color.fromARGB(255, 255, 111, 111))),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white10,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!) as ImageProvider
                                : (widget.user.avatarUrl != null &&
                                        widget.user.avatarUrl!.isNotEmpty)
                                    ? CachedNetworkImageProvider(widget.user.avatarUrl!)
                                    : null,
                            child: (_selectedImage == null &&
                                    (widget.user.avatarUrl == null ||
                                        widget.user.avatarUrl!.isEmpty))
                                ? const Icon(Icons.person, size: 50, color: Colors.white54)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF42898E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      decoration: _buildInputDecoration('Enter your full name'),
                      validator: (val) => (val == null || val.isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number
                    _buildLabel('Phone Number'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      decoration: _buildInputDecoration('Enter your phone number'),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _buildLabel('Email Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      readOnly: widget.user.isGoogleAuth,
                      style: TextStyle(
                          color: widget.user.isGoogleAuth ? Colors.white54 : Colors.white),
                      decoration: _buildInputDecoration('Enter your email address').copyWith(
                        filled: true,
                        fillColor: widget.user.isGoogleAuth
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.transparent,
                        hintText: widget.user.isGoogleAuth
                            ? 'Email is managed by Google'
                            : 'Enter your email address',
                      ),
                      validator: (val) {
                        if (!widget.user.isGoogleAuth && (val == null || val.isEmpty)) {
                          return 'Email is required';
                        }
                        return null;
                      },
                    ),
                    if (widget.user.isGoogleAuth)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Your email is linked to your Google account and cannot be changed here.',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42898E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveProfile,
                        child: const Text('Save Changes',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF42898E)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerMap extends StatefulWidget {
  final Function(double lat, double lng, String address) onLocationSelected;

  const LocationPickerMap({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _currentPosition = const LatLng(0, 0); // Default position
  Set<Marker> _markers = {};
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    if (mounted) {
      setState(() {
        _hasPermission = true;
      });
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 10));
    } catch (e) {
      position = await Geolocator.getLastKnownPosition();
    }

    if (position != null) {
      _updatePositionAndMarker(LatLng(position.latitude, position.longitude));
    }
  }

  Future<void> _updatePositionAndMarker(LatLng position) async {
    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: position,
        )
      };
    });

    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 16.0,
        )
      ));
    }

    _reverseGeocodeAndNotify(position);
  }
  
  Future<void> _reverseGeocodeAndNotify(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String> parts = [];
        if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
        
        String adminPostal = '';
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) adminPostal += place.administrativeArea!;
        if (place.postalCode != null && place.postalCode!.isNotEmpty) adminPostal += ' ${place.postalCode!}';
        adminPostal = adminPostal.trim();
        if (adminPostal.isNotEmpty) parts.add(adminPostal);
        
        if (place.country != null && place.country!.isNotEmpty) parts.add(place.country!);

        String address = parts.join(', ');
        widget.onLocationSelected(position.latitude, position.longitude, address);
      }
    } catch (e) {
      widget.onLocationSelected(position.latitude, position.longitude, "Selected Location");
    }
  }

  void _onMapTapped(LatLng position) {
    _updatePositionAndMarker(position);
  }

  Future<void> _locateMe() async {
    await _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0x0DF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D2D44)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: _markers.isEmpty ? 2.0 : 16.0, // Zoom out if no marker, zoom in if marker present
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              onTap: _onMapTapped,
              myLocationEnabled: _hasPermission,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF42898E),
                onPressed: _locateMe,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

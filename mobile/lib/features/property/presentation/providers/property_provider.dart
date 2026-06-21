import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/reservation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PropertyNotifier extends StateNotifier<List<Property>> {
  final Dio _dio;
  
  PropertyNotifier(this._dio) : super([]) {
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    try {
      final response = await _dio.get('/properties');
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as List;
        final properties = data.map((json) {
          return Property(
            id: json['id']?.toString() ?? '',
            title: json['title']?.toString() ?? 'No Title',
            address: json['address']?.toString() ?? json['city']?.toString() ?? 'No Address',
            price: json['price']?.toString() ?? '0',
            beds: json['bedrooms']?.toString() ?? '0',
            baths: json['bathrooms']?.toString() ?? '0',
            sqft: json['area']?.toString() ?? '0',
            category: json['property_type']?.toString() ?? 'Other',
            imageUrls: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
            isApproved: json['is_approved'] == true,
            landlordId: json['landlord']?['id']?.toString(),
            landlordName: json['landlord']?['full_name']?.toString() ?? json['landlord']?['username']?.toString(),
            landlordAvatar: json['landlord']?['avatar_url']?.toString(),
          );
        }).toList();
        state = properties;
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> createProperty(Map<String, dynamic> data, List<String> imagePaths) async {
    String? propertyId;
    try {
      // 1. Create property record
      final response = await _dio.post('/properties', data: data);
      propertyId = response.data['data']['id']?.toString();

      // 2. Upload images
      final formData = FormData();
      for (int i = 0; i < imagePaths.length; i++) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(imagePaths[i], filename: 'image_$i.jpg'),
        ));
      }

      await _dio.post('/properties/$propertyId/images', data: formData);
    } catch (e) {
      if (propertyId != null) {
        try {
          // Cleanup orphaned property if image upload fails
          await _dio.delete('/properties/$propertyId');
        } catch (_) {}
      }
      throw Exception('Failed to create property: $e');
    }
  }

  void toggleInterest(String propertyId) {
    state = state.map((prop) {
      if (prop.id == propertyId) {
        return prop.copyWith(isInterested: !prop.isInterested);
      }
      return prop;
    }).toList();
  }

  void toggleAvailability(String propertyId) {
    state = state.map((prop) {
      if (prop.id == propertyId) {
        return prop.copyWith(isAvailable: !prop.isAvailable);
      }
      return prop;
    }).toList();
  }

  void updateReservationStatus(String propertyId, String reservationId, ReservationStatus newStatus, {DateTime? newTime}) {
    state = state.map((prop) {
      if (prop.id == propertyId) {
        final updatedReservations = prop.reservations.map((res) {
          if (res.id == reservationId) {
            return res.copyWith(
              status: newStatus,
              visitingTime: newTime ?? res.visitingTime,
            );
          }
          return res;
        }).toList();
        return prop.copyWith(reservations: updatedReservations);
      }
      return prop;
    }).toList();
  }
  Future<void> approveProperty(String propertyId) async {
    try {
      await _dio.patch('/properties/$propertyId/approve');
      state = state.map((prop) {
        if (prop.id == propertyId) {
          return prop.copyWith(isApproved: true);
        }
        return prop;
      }).toList();
    } catch (e) {
      throw Exception('Failed to approve property');
    }
  }

  Future<void> rejectProperty(String propertyId) async {
    try {
      await _dio.patch('/properties/$propertyId/reject');
      state = state.where((prop) => prop.id != propertyId).toList();
    } catch (e) {
      throw Exception('Failed to reject property');
    }
  }
}

final propertyProvider = StateNotifierProvider<PropertyNotifier, List<Property>>((ref) {
  final dio = ref.watch(dioProvider);
  return PropertyNotifier(dio);
});

final approvedPropertiesProvider = Provider<List<Property>>((ref) {
  final properties = ref.watch(propertyProvider);
  return properties.where((p) => p.isApproved).toList();
});

final interestedPropertiesProvider = Provider<List<Property>>((ref) {
  final properties = ref.watch(propertyProvider);
  return properties.where((p) => p.isInterested).toList();
});

final myListingsProvider = Provider<List<Property>>((ref) {
  final user = ref.watch(userProvider).valueOrNull;
  final properties = ref.watch(propertyProvider);
  if (user == null) return [];
  return properties.where((p) => p.landlordId == user.id).toList();
});

// Provides approved properties grouped by category
final propertiesByCategoryProvider = Provider<Map<String, List<Property>>>((ref) {
  final properties = ref.watch(approvedPropertiesProvider);
  final Map<String, List<Property>> grouped = {};
  for (var prop in properties) {
    if (!grouped.containsKey(prop.category)) {
      grouped[prop.category] = [];
    }
    grouped[prop.category]!.add(prop);
  }
  return grouped;
});

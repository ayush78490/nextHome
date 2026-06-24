import 'reservation.dart';

class Property {
  final String id;
  final String title;
  final String address;
  final String price;
  final String beds;
  final String baths;
  final String sqft;
  final String category;
  final List<String> imageUrls;
  final List<String> facilities;
  final String locality;
  final String description;
  
  // State
  final bool isInterested;
  final bool isAvailable;
  final bool isMyListing;
  final bool isApproved;
  final List<Reservation> reservations;
  
  // Landlord Information
  final String? landlordId;
  final String? landlordName;
  final String? landlordAvatar;

  const Property({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.beds,
    required this.baths,
    required this.sqft,
    required this.category,
    required this.imageUrls,
    this.facilities = const [],
    this.locality = '',
    this.description = '',
    this.isInterested = false,
    this.isAvailable = true,
    this.isMyListing = false,
    this.isApproved = false,
    this.reservations = const [],
    this.landlordId,
    this.landlordName,
    this.landlordAvatar,
  });

  Property copyWith({
    String? id,
    String? title,
    String? address,
    String? price,
    String? beds,
    String? baths,
    String? sqft,
    String? category,
    List<String>? imageUrls,
    List<String>? facilities,
    String? locality,
    String? description,
    bool? isInterested,
    bool? isAvailable,
    bool? isMyListing,
    bool? isApproved,
    List<Reservation>? reservations,
    String? landlordId,
    String? landlordName,
    String? landlordAvatar,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      price: price ?? this.price,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      sqft: sqft ?? this.sqft,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      facilities: facilities ?? this.facilities,
      locality: locality ?? this.locality,
      description: description ?? this.description,
      isInterested: isInterested ?? this.isInterested,
      isAvailable: isAvailable ?? this.isAvailable,
      isMyListing: isMyListing ?? this.isMyListing,
      isApproved: isApproved ?? this.isApproved,
      reservations: reservations ?? this.reservations,
      landlordId: landlordId ?? this.landlordId,
      landlordName: landlordName ?? this.landlordName,
      landlordAvatar: landlordAvatar ?? this.landlordAvatar,
    );
  }
}

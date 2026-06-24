import 'dart:convert';

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
  final bool isApproved;
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
    this.isApproved = false,
    this.landlordId,
    this.landlordName,
    this.landlordAvatar,
  });
}

void main() {
  const jsonString = '''[
    {
      "id": "65056ae5-b145-4789-8942-f8376a7a212f",
      "landlord_id": "9972a727-bb17-4d1c-b488-8c0d98ede2bb",
      "title": "Aryan's chut",
      "client_first_name": "Aryan",
      "client_last_name": "zutshi",
      "client_email": "zutshi@cumail.in",
      "client_phone": "8796525142",
      "client_city": "chutnagar",
      "property_type": "studio",
      "listing_type": "Rent",
      "price": 3000,
      "description": "testing aryan chut is fresh or not. just in 3000",
      "country": "India",
      "state": "Punjab",
      "city": "Mohali",
      "address": "chut ki haweli",
      "zip_code": "140301",
      "land_sqft": 400,
      "construction_sqft": 100,
      "bedrooms": 1,
      "bathrooms": 1,
      "parking_lots": 1,
      "kitchen": 1,
      "images": [
        "https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/18c3aa18-6d62-4b3f-89a1-8cbbd45ad80a.jpeg",
        "https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/623e03ea-8d6d-4b02-bb83-1646c32ffa5c.jpeg",
        "https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/5f37a072-b1fa-407c-99b1-b5116f0c9136.jpeg",
        "https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/1a12b0e1-7f5e-4da0-9615-69f536b510da.jpeg"
      ],
      "is_approved": false,
      "created_at": "2026-06-24T20:27:29.834935+00:00",
      "updated_at": "2026-06-24T20:27:29.834935+00:00",
      "facilities": [
        "WiFi",
        "Parking",
        "AC",
        "Heater",
        "Balcony"
      ],
      "locality": "midical - 100m",
      "landlord": {
        "id": "9972a727-bb17-4d1c-b488-8c0d98ede2bb",
        "full_name": "Ayush Raj",
        "avatar_url": null
      }
    },
    {
      "id": "bb4e2e18-dfda-44a4-8ceb-8d6c294489e2",
      "landlord_id": "f0819c6d-1c7d-4c14-872d-284dc474a44e",
      "title": "Beautiful Apartment",
      "client_first_name": "John",
      "client_last_name": "Doe",
      "client_email": "john@example.com",
      "client_phone": "1234567890",
      "client_city": "New York",
      "property_type": "Apartment",
      "listing_type": "Rent",
      "price": 1500,
      "description": "A very nice apartment.",
      "country": "USA",
      "state": "NY",
      "city": "New York",
      "address": "123 Main St",
      "zip_code": "10001",
      "land_sqft": 1000,
      "construction_sqft": 800,
      "bedrooms": 2,
      "bathrooms": 1,
      "parking_lots": 1,
      "kitchen": 1,
      "images": [],
      "is_approved": false,
      "created_at": "2026-06-24T20:14:34.130163+00:00",
      "updated_at": "2026-06-24T20:14:34.130163+00:00",
      "facilities": [
        "WiFi",
        "Pool"
      ],
      "locality": "Downtown - 5km",
      "landlord": {
        "id": "f0819c6d-1c7d-4c14-872d-284dc474a44e",
        "full_name": "ayush",
        "avatar_url": null
      }
    },
    {
      "id": "464eef31-0b5f-4af9-b840-d41de46a13d4",
      "landlord_id": "9972a727-bb17-4d1c-b488-8c0d98ede2bb",
      "title": "Aryan's chut",
      "client_first_name": "Aryan",
      "client_last_name": "zutshi",
      "client_email": "zutshi@cumail.in",
      "client_phone": "8796525142",
      "client_city": "chutnagar",
      "property_type": "studio",
      "listing_type": "Rent",
      "price": 3000,
      "description": "testing aryan chut is fresh or not. just in 3000",
      "country": "India",
      "state": "Punjab",
      "city": "Mohali",
      "address": "chut ki haweli",
      "zip_code": "140301",
      "land_sqft": 400,
      "construction_sqft": 100,
      "bedrooms": 1,
      "bathrooms": 1,
      "parking_lots": 1,
      "kitchen": 1,
      "images": [],
      "is_approved": false,
      "created_at": "2026-06-24T20:09:17.132583+00:00",
      "updated_at": "2026-06-24T20:09:17.132583+00:00",
      "facilities": [
        "WiFi",
        "Parking",
        "AC",
        "Heater",
        "Balcony"
      ],
      "locality": "midical - 100m",
      "landlord": {
        "id": "9972a727-bb17-4d1c-b488-8c0d98ede2bb",
        "full_name": "Ayush Raj",
        "avatar_url": null
      }
    },
    {
      "id": "b97e713c-51f3-42bc-af3f-211bed77dead",
      "landlord_id": "9972a727-bb17-4d1c-b488-8c0d98ede2bb",
      "title": "Aryan's chut",
      "client_first_name": "Aryan",
      "client_last_name": "zutshi",
      "client_email": "zutshi@cumail.in",
      "client_phone": "8796525142",
      "client_city": "chutnagar",
      "property_type": "studio",
      "listing_type": "Rent",
      "price": 3000,
      "description": "testing aryan chut is fresh or not. just in 3000",
      "country": "India",
      "state": "Punjab",
      "city": "Mohali",
      "address": "chut ki haweli",
      "zip_code": "140301",
      "land_sqft": 400,
      "construction_sqft": 100,
      "bedrooms": 1,
      "bathrooms": 1,
      "parking_lots": 1,
      "kitchen": 1,
      "images": [],
      "is_approved": false,
      "created_at": "2026-06-24T20:08:54.890903+00:00",
      "updated_at": "2026-06-24T20:08:54.890903+00:00",
      "facilities": [
        "WiFi",
        "Parking",
        "AC",
        "Heater",
        "Balcony"
      ],
      "locality": "midical - 100m",
      "landlord": {
        "id": "9972a727-bb17-4d1c-b488-8c0d98ede2bb",
        "full_name": "Ayush Raj",
        "avatar_url": null
      }
    },
    {
      "id": "76d4b95c-c691-4be5-962f-bc343e374a4e",
      "landlord_id": "23226b48-ad56-465d-8a6a-fdd7db124c75",
      "title": "fresh chut",
      "client_first_name": "jucy",
      "client_last_name": "aryan",
      "client_email": "aryan@chut.com",
      "client_phone": "9570465896",
      "client_city": "kharar",
      "property_type": "house",
      "listing_type": "Rent",
      "price": 6000,
      "description": "testing for chut",
      "country": "india",
      "state": "punjab",
      "city": "kharar",
      "address": "kharar. gbp crest",
      "zip_code": "140301",
      "land_sqft": 400,
      "construction_sqft": 300,
      "bedrooms": 3,
      "bathrooms": 3,
      "parking_lots": 1,
      "kitchen": 1,
      "images": [
        "https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/1f440656-ce05-40c7-b3e7-26cae8b40430.jpeg",
        "https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/0f58ea90-8d7a-497b-8b88-44f60afd30b7.jpeg",
        "https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/ff423ccb-6f39-425c-b130-e19f6abd42a0.jpeg",
        "https://nexthome1173.s3.eu-north-1.amazonaws.com/properties/2ff6ff4d-26bd-491b-af8e-07244a2fa407.jpeg"
      ],
      "is_approved": true,
      "created_at": "2026-06-20T18:45:13.213211+00:00",
      "updated_at": "2026-06-20T18:45:13.213211+00:00",
      "facilities": [],
      "locality": null,
      "landlord": {
        "id": "23226b48-ad56-465d-8a6a-fdd7db124c75",
        "full_name": "Ayush Raj",
        "avatar_url": null
      }
    }
  ]''';

  final jsonList = jsonDecode(jsonString) as List;

  try {
    final properties = jsonList.map((json) {
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
        facilities: (json['facilities'] as List?)?.map((e) => e.toString()).toList() ?? [],
        locality: json['locality']?.toString() ?? '',
        isApproved: json['is_approved'] == true,
        landlordId: json['landlord']?['id']?.toString(),
        landlordName: json['landlord']?['full_name']?.toString() ?? json['landlord']?['username']?.toString(),
        landlordAvatar: json['landlord']?['avatar_url']?.toString(),
      );
    }).toList();
    print('Successfully parsed ${properties.length} properties');
  } catch (e, st) {
    print('Error: $e');
    print(st);
  }
}

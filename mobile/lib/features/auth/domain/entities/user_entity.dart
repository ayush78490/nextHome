import 'package:equatable/equatable.dart';

/// User entity – pure domain model, no framework dependencies
class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? username;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final String role;          // 'tenant' | 'landlord' | 'admin'
  final bool isVerified;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    this.email,
    this.username,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.isVerified = false,
    this.createdAt,
  });

  bool get isTenant   => role == 'tenant';
  bool get isLandlord => role == 'landlord';
  bool get isAdmin    => role == 'admin';

  @override
  List<Object?> get props => [id, email, username, fullName, role, isVerified];
}

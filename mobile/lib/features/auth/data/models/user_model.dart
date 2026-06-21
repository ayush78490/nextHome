import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data model with JSON serialization (Freezed + json_serializable)
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    String? email,
    String? username,
    String? phone,
    required String fullName,
    String? avatarUrl,
    required String role,
    @Default(false) bool isVerified,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  // Convert to domain entity
  const UserModel._();
  UserEntity toEntity() => UserEntity(
    id:         id,
    email:      email,
    phone:      phone,
    fullName:   fullName,
    avatarUrl:  avatarUrl,
    role:       role,
    isVerified: isVerified,
    createdAt:  createdAt,
  );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id:         entity.id,
    email:      entity.email,
    username:   entity.username,
    phone:      entity.phone,
    fullName:   entity.fullName,
    avatarUrl:  entity.avatarUrl,
    role:       entity.role,
    isVerified: entity.isVerified,
    createdAt:  entity.createdAt,
  );
}

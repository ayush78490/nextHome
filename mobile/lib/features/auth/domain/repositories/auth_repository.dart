import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract contract for auth repository
abstract class AuthRepository {
  /// Sign in / register via Firebase ID token
  Future<Either<Failure, UserEntity>> loginWithGoogle({
    required String idToken,
    String? email,
    String? fcmToken,
  });

  /// Register via Email and Password
  Future<Either<Failure, UserEntity>> register({
    String? email,
    String? username,
    required String password,
    String? fullName,
  });

  /// Login via Email and Password
  Future<Either<Failure, UserEntity>> login({
    String? email,
    String? username,
    required String password,
  });

  /// Get current user profile from API
  Future<Either<Failure, UserEntity>> getProfile();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  });

  /// Sign out (clear local storage + Firebase signOut)
  Future<Either<Failure, void>> signOut();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get cached user (offline access)
  Future<UserEntity?> getCachedUser();
}

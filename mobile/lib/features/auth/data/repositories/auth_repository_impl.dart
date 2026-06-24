import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource  _local;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource  local,
    FlutterSecureStorage? storage,
  })  : _remote = remote,
        _local  = local,
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle({
    required String idToken,
    String? email,
    String? fcmToken,
  }) async {
    try {
      final (userModel, token) = await _remote.loginWithGoogle(idToken: idToken, email: email, fcmToken: fcmToken);
      await _storage.write(key: 'auth_token', value: token);
      await _local.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on DioException catch (err) {
      final e = err.error is ApiException ? err.error as ApiException : ApiException.fromDio(err);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    String? email,
    String? username,
    required String password,
    String? fullName,
  }) async {
    try {
      final (userModel, token) = await _remote.register(email: email, username: username, password: password, fullName: fullName);
      await _storage.write(key: 'auth_token', value: token);
      await _local.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on DioException catch (err) {
      final e = err.error is ApiException ? err.error as ApiException : ApiException.fromDio(err);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    String? email,
    String? username,
    required String password,
  }) async {
    try {
      final (userModel, token) = await _remote.login(email: email, username: username, password: password);
      await _storage.write(key: 'auth_token', value: token);
      await _local.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on DioException catch (err) {
      final e = err.error is ApiException ? err.error as ApiException : ApiException.fromDio(err);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final userModel = await _remote.getProfile();
      await _local.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on DioException catch (err) {
      final e = err.error is ApiException ? err.error as ApiException : ApiException.fromDio(err);
      if (e.statusCode == null) {
        // Network error – return cached
        final cached = await _local.getCachedUser();
        if (cached != null) return Right(cached.toEntity());
        return Left(NetworkFailure(message: e.message));
      }
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final userModel = await _remote.updateProfile(
        fullName: fullName, phone: phone, email: email, avatarUrl: avatarUrl,
      );
      await _local.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on DioException catch (err) {
      final e = err.error is ApiException ? err.error as ApiException : ApiException.fromDio(err);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> uploadAvatar(String filePath) async {
    try {
      final userModel = await _remote.uploadAvatar(filePath);
      await _local.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on DioException catch (err) {
      final e = err.error is ApiException ? err.error as ApiException : ApiException.fromDio(err);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _storage.delete(key: 'auth_token');
      await _local.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    final model = await _local.getCachedUser();
    return model?.toEntity();
  }
}

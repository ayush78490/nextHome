import 'package:dio/dio.dart';
import '../models/user_model.dart';

/// Remote data source – communicates with Next Home backend
abstract class AuthRemoteDataSource {
  Future<(UserModel, String)> loginWithGoogle({required String idToken, String? email, String? fcmToken});
  Future<(UserModel, String)> register({String? email, String? username, required String password, String? fullName});
  Future<(UserModel, String)> login({String? email, String? username, required String password});
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({String? fullName, String? phone, String? avatarUrl});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<(UserModel, String)> loginWithGoogle({required String idToken, String? email, String? fcmToken}) async {
    final response = await _dio.post('/auth/login', data: {
      'idToken':  idToken,
      if (email != null) 'email': email,
      if (fcmToken != null) 'fcmToken': fcmToken,
    });
    final data = response.data['data'];
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (user, data['token'] as String);
  }

  @override
  Future<(UserModel, String)> register({String? email, String? username, required String password, String? fullName}) async {
    final response = await _dio.post('/auth/register', data: {
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      'password': password,
      if (fullName != null) 'fullName': fullName,
    });
    final data = response.data['data'];
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (user, data['token'] as String);
  }

  @override
  Future<(UserModel, String)> login({String? email, String? username, required String password}) async {

    final response = await _dio.post('/auth/login/email', data: {
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      'password': password,
    });
    final data = response.data['data'];
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (user, data['token'] as String);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile({String? fullName, String? phone, String? avatarUrl}) async {
    final response = await _dio.patch('/auth/me', data: {
      if (fullName   != null) 'fullName':  fullName,
      if (phone      != null) 'phone':     phone,
      if (avatarUrl  != null) 'avatarUrl': avatarUrl,
    });
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

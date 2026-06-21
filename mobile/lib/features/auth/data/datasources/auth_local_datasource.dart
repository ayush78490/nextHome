import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Local data source – Hive box for offline user caching
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  Box get _box => Hive.box(AppConstants.userBox);

  @override
  Future<void> cacheUser(UserModel user) async {
    await _box.put('current_user', user.toJson());
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final data = _box.get('current_user');
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> clearUser() async {
    await _box.delete('current_user');
  }
}

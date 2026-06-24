import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/user_entity.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSourceImpl(dio),
    local: AuthLocalDataSourceImpl(),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref, ref.watch(authRepositoryProvider));
});

final userProvider = FutureProvider<UserEntity?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final cached = await repo.getCachedUser();
  if (cached != null) return cached;

  final result = await repo.getProfile();
  return result.fold((l) => null, (r) => r);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final AuthRepository _repository;

  AuthNotifier(this._ref, this._repository) : super(const AsyncValue.data(null));

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // 1. Trigger the Google Sign-In flow (v7 API uses authenticate())
      final googleUser = await GoogleSignIn.instance.authenticate();

      // 2. Get the idToken from authentication
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw Exception('Google Sign-In failed: no ID token received.');
      }

      // 3. Get email directly from the signed-in user object (v7 always has it)
      final email = googleUser.email;

      // 4. Send idToken + email to our backend
      final result = await _repository.loginWithGoogle(
        idToken: idToken,
        email: email,
      );

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );

      _ref.invalidate(userProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> registerWithUsername(String username, String password, String? fullName) async {
    state = const AsyncValue.loading();
    try {
      final result =
          await _repository.register(username: username, password: password, fullName: fullName);
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
      _ref.invalidate(userProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loginWithUsernameOrEmail(String usernameOrEmail, String password) async {
    state = const AsyncValue.loading();
    try {
      final isEmail = usernameOrEmail.contains('@');
      final result = await _repository.login(
        email: isEmail ? usernameOrEmail : null,
        username: !isEmail ? usernameOrEmail : null,
        password: password,
      );
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
      _ref.invalidate(userProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await GoogleSignIn.instance.signOut();
      await _repository.signOut();
      _ref.invalidate(userProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateProfile({String? fullName, String? phone, String? email, String? avatarUrl}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        email: email,
        avatarUrl: avatarUrl,
      );
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
      _ref.invalidate(userProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.uploadAvatar(filePath);
      result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
      _ref.invalidate(userProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

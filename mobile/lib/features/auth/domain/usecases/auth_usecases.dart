import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: Login with Firebase ID token
class loginWithGoogleUseCase {
  final AuthRepository _repository;
  loginWithGoogleUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String idToken,
    String? fcmToken,
  }) {
    return _repository.loginWithGoogle(idToken: idToken, fcmToken: fcmToken);
  }
}

/// Use case: Get current user profile
class GetProfileUseCase {
  final AuthRepository _repository;
  GetProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() => _repository.getProfile();
}

/// Use case: Sign out
class SignOutUseCase {
  final AuthRepository _repository;
  SignOutUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.signOut();
}

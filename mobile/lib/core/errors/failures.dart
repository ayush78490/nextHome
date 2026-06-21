import 'package:dartz/dartz.dart';

/// Base Failure class for domain layer error handling (dartz Either)
abstract class Failure {
  final String code;
  final String message;
  const Failure({required this.code, required this.message});

  @override
  String toString() => '$runtimeType($code): $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No internet connection'})
      : super(code: 'NETWORK_ERROR', message: message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required String message, this.statusCode})
      : super(code: 'SERVER_ERROR', message: message);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message})
      : super(code: 'AUTH_ERROR', message: message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'Resource not found'})
      : super(code: 'NOT_FOUND', message: message);
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message})
      : super(code: 'VALIDATION_ERROR', message: message);
}

class UnknownFailure extends Failure {
  const UnknownFailure({String message = 'An unexpected error occurred'})
      : super(code: 'UNKNOWN', message: message);
}

/// Convenience type alias
typedef EitherFailure<T> = Either<Failure, T>;

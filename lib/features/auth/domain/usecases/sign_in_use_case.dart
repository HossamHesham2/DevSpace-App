import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/features/auth/domain/entities/auth_entity.dart';
import 'package:dev_space/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase({required this._authRepository});

  Future<Either<Failure, AuthEntity>> call({
    required String email,
    required String password,
  }) async {
    return await _authRepository.signIn(email: email, password: password);
  }
}

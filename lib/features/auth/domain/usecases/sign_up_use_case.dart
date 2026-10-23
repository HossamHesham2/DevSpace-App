import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/features/auth/domain/entities/sign_up_result.dart';
import 'package:dev_space/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase({required this._authRepository});

  Future<Either<Failure, SignUpResult>> call({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return await _authRepository.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}

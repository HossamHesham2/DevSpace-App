import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase({required this._authRepository});

  Future<Either<Failure, void>> call() async {
    return await _authRepository.signOut();
  }
}

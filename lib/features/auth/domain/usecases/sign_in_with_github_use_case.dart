import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/features/auth/domain/repositories/auth_repository.dart';

@injectable
class SignInWithGitHubUseCase {
  final AuthRepository _repository;

  SignInWithGitHubUseCase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.signInWithGitHub();
  }
}
import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
  }) {
    return repository.sendPasswordResetEmail(
      email: email,
    );
  }
}
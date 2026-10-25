import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/features/profile/domain/entities/github_profile_entity.dart';
import 'package:dev_space/features/profile/domain/repositories/profile_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetGithubProfileUseCase {
  final ProfileRepository _repository;

  GetGithubProfileUseCase({required this._repository});

  Future<Either<Failure, GitHubProfileEntity>> call(String username) async {
    return await _repository.getProfile(username);
  }
}

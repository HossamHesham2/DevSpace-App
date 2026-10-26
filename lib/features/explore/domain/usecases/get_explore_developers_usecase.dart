import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:injectable/injectable.dart';

import 'package:dev_space/features/explore/domain/entities/explore_repository_entity.dart';
import 'package:dev_space/features/explore/domain/repositories/explore_repository.dart';

/// Builds the Explore feed: up to [maxDevelopers] individual GitHub
/// developers, each represented by their latest [reposPerDeveloper] public,
/// non-forked, non-archived repositories.
///
/// The selection rules live here in the Domain layer so the UI only has to
/// render whatever list it receives.
@injectable
class GetExploreDevelopersUseCase {
  static const int maxDevelopers = 3;
  static const int reposPerDeveloper = 2;

  /// Upper bound on unique users we look up per load, to keep GitHub API
  /// usage low.
  static const int maxUserLookups = 8;

  final ExploreRepository _repository;

  GetExploreDevelopersUseCase(this._repository);

  Future<Either<Failure, List<List<ExploreRepositoryEntity>>>> call() async {
    final result = await _repository.getExploreRepositories();

    return result.fold((failure) => Left(failure), (repositories) async {
      final developers = <List<ExploreRepositoryEntity>>[];
      final usernames = <String>{};
      var lookups = 0;
      Failure? rateLimitFailure;

      for (final repo in repositories) {
        if (developers.length >= maxDevelopers || lookups >= maxUserLookups) {
          break;
        }

        // Prefer individual users over organizations.
        if (repo.ownerType != 'User') continue;

        if (repo.ownerUsername.isEmpty) continue;

        // Skip duplicate users and users whose profile URL is missing.
        if (!usernames.add(repo.ownerUsername)) continue;
        if (repo.ownerHtmlUrl.isEmpty) continue;

        lookups++;

        var userFailed = false;
        final userResult = await _repository.getUserRepositories(
          repo.ownerUsername,
        );

        userResult.fold(
          (failure) {
            userFailed = true;

            // Do not silently ignore rate limits: stop immediately and
            // surface the failure instead of hammering the API further.
            if (_isRateLimited(failure)) {
              rateLimitFailure = failure;
            }
          },
          (userRepositories) {
            if (userRepositories.length >= reposPerDeveloper) {
              developers.add(userRepositories.take(reposPerDeveloper).toList());
            }
          },
        );

        final limit = rateLimitFailure;
        if (limit != null) {
          return Left<Failure, List<List<ExploreRepositoryEntity>>>(limit);
        }

        // Other per-user failures simply skip that developer.
        if (userFailed) continue;
      }

      return Right(developers);
    });
  }

  bool _isRateLimited(Failure failure) =>
      failure is ServerFailure &&
      (failure.statusCode == 403 || failure.statusCode == 429);
}

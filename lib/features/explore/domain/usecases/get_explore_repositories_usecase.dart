import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:injectable/injectable.dart';

import 'package:dev_space/features/explore/domain/entities/explore_repository_entity.dart';
import 'package:dev_space/features/explore/domain/repositories/explore_repository.dart';

@injectable
class GetExploreRepositoriesUseCase {
  final ExploreRepository _repository;

  GetExploreRepositoriesUseCase(this._repository);

  Future<Either<Failure, List<ExploreRepositoryEntity>>> call() {
    return _repository.getExploreRepositories();
  }
}

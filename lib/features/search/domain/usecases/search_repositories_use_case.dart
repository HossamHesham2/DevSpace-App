import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/core/models/repository_model.dart';
import 'package:dev_space/features/search/domain/repositories/search_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchRepositoriesUseCase {
  final SearchRepository _searchRepository;

  SearchRepositoriesUseCase({required this._searchRepository});

  Future<Either<Failure, List<RepositoryModel>>> call(String query) async {
    return _searchRepository.searchRepositories(query);
  }
}

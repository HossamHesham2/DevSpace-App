import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/core/models/user_model.dart';
import 'package:dev_space/features/search/domain/repositories/search_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchUsersUseCase {
  final SearchRepository _searchRepository;

  SearchUsersUseCase({required this._searchRepository});

  Future<Either<Failure, List<UserModel>>> call(String query) async {
    return _searchRepository.searchUsers(query);
  }
}

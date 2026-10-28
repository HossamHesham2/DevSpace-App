import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:dev_space/core/errors/failures.dart';
import 'package:dev_space/core/models/repository_model.dart';
import 'package:dev_space/core/models/user_model.dart';
import 'package:dev_space/core/utils/logger.dart';
import 'package:dev_space/features/search/domain/usecases/search_repositories_use_case.dart';
import 'package:dev_space/features/search/domain/usecases/search_users_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'search_state.dart';

@injectable
class SearchCubit extends Cubit<SearchState> {
  final SearchUsersUseCase _searchUsersUseCase;
  final SearchRepositoriesUseCase _searchRepositoriesUseCase;

  /// Identifies the most recent search request. Responses from older
  /// requests are ignored so a slow query can never overwrite a newer one.
  int _requestId = 0;

  SearchCubit({
    required this._searchUsersUseCase,
    required this._searchRepositoriesUseCase,
  }) : super(const SearchInitialState());

  Future<void> searchRepositories(String rawQuery) {
    return _run<RepositoryModel>(
      rawQuery: rawQuery,
      mode: SearchMode.repositories,
      request: (query) => _searchRepositoriesUseCase(query),
      onSuccess: (query, repositories) =>
          LoadedRepositories(query: query, repositories: repositories),
    );
  }

  Future<void> searchUsers(String rawQuery) {
    return _run<UserModel>(
      rawQuery: rawQuery,
      mode: SearchMode.users,
      request: (query) => _searchUsersUseCase(query),
      onSuccess: (query, users) => LoadedUsers(query: query, users: users),
    );
  }

  /// Clears the results and invalidates any request still in flight.
  void reset() {
    _requestId++;

    if (isClosed) return;

    emit(const SearchInitialState());
  }

  Future<void> _run<T>({
    required String rawQuery,
    required SearchMode mode,
    required Future<Either<Failure, List<T>>> Function(String query) request,
    required SearchState Function(String query, List<T> items) onSuccess,
  }) async {
    if (isClosed) return;

    final query = rawQuery.trim();

    if (query.isEmpty) {
      reset();
      return;
    }

    // Repeated taps/submissions for the same query must not start a second
    // request while the first one is still running.
    if (_isLoading(query, mode)) return;

    final requestId = ++_requestId;
    emit(SearchLoadingState(query: query, mode: mode));

    try {
      final result = await request(query);

      if (_isStale(requestId)) return;

      result.fold(
        (failure) => emit(
          SearchErrorState(
            query: query,
            mode: mode,
            errorMessage: failure.errorMessage,
          ),
        ),
        (items) => emit(onSuccess(query, items)),
      );
    } catch (error, stackTrace) {
      if (_isStale(requestId)) return;

      Logger.log('Search failed: $error\n$stackTrace');

      emit(
        SearchErrorState(
          query: query,
          mode: mode,
          errorMessage: 'Something went wrong while searching. Try again.',
        ),
      );
    }
  }

  bool _isLoading(String query, SearchMode mode) {
    final current = state;

    return current is SearchLoadingState &&
        current.query == query &&
        current.mode == mode;
  }

  bool _isStale(int requestId) => isClosed || requestId != _requestId;
}

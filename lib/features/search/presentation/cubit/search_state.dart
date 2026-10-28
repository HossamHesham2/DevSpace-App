part of 'search_cubit.dart';

/// The kind of GitHub search currently being performed.
enum SearchMode { repositories, users }

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitialState extends SearchState {
  const SearchInitialState();
}

final class SearchLoadingState extends SearchState {
  const SearchLoadingState({required this.query, required this.mode});

  final String query;
  final SearchMode mode;

  @override
  List<Object?> get props => [query, mode];
}

final class LoadedUsers extends SearchState {
  LoadedUsers({required this.query, required List<UserModel> users})
    : users = List.unmodifiable(users);

  final String query;
  final List<UserModel> users;

  @override
  List<Object?> get props => [query, users];
}

final class LoadedRepositories extends SearchState {
  LoadedRepositories({
    required this.query,
    required List<RepositoryModel> repositories,
  }) : repositories = List.unmodifiable(repositories);

  final String query;
  final List<RepositoryModel> repositories;

  @override
  List<Object?> get props => [query, repositories];
}

final class SearchErrorState extends SearchState {
  const SearchErrorState({
    required this.query,
    required this.mode,
    required this.errorMessage,
  });

  final String query;
  final SearchMode mode;
  final String errorMessage;

  @override
  List<Object?> get props => [query, mode, errorMessage];
}

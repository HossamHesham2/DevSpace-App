import 'package:dev_space/core/models/repository_model.dart';
import 'package:dev_space/core/models/user_model.dart';
import 'package:dev_space/core/networks/dio_client.dart';
import 'package:dev_space/features/search/data/datasources/remote/search_remote_datasource.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: SearchRemoteDatasource)
class SearchRemoteDatasourceImpl extends SearchRemoteDatasource {
  final DioClient _dioClient;

  SearchRemoteDatasourceImpl({required this._dioClient});

  @override
  Future<List<RepositoryModel>> searchRepositories(String query) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/search/repositories',
      queryParameters: {'q': query, 'per_page': 30},
    );

    return _parseItems(response.data, RepositoryModel.fromJson);
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/search/users',
      queryParameters: {'q': query, 'per_page': 30},
    );

    return _parseItems(response.data, UserModel.fromJson);
  }

  /// Maps the GitHub search envelope to a typed list.
  ///
  /// A missing `items` key is a valid empty result. A present but non-list
  /// payload is treated as a malformed response so the repository can surface
  /// a friendly error instead of silently returning partial data.
  List<T> _parseItems<T>(
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = data?['items'];

    if (items == null) return const [];

    if (items is! List) {
      throw const FormatException('Expected a list of search items.');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }
}

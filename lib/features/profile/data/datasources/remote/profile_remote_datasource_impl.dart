import 'package:dev_space/core/networks/dio_client.dart';
import 'package:dev_space/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:dev_space/features/profile/data/models/github_profile_model.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ProfileRemoteDatasource)
class ProfileRemoteDatasourceImpl extends ProfileRemoteDatasource {
  final DioClient _dioClient;

  ProfileRemoteDatasourceImpl({required this._dioClient});

  @override
  Future<GitHubProfileModel> getProfile(String username) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/users/${Uri.encodeComponent(username)}',
    );
    return GitHubProfileModel.fromJson(response.data!);
  }
}

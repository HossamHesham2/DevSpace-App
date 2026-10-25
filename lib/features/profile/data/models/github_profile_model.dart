import 'package:dev_space/features/profile/domain/entities/github_profile_entity.dart';

class GitHubProfileModel extends GitHubProfileEntity {
  const GitHubProfileModel({
    required super.username,
    required super.name,
    required super.avatarUrl,
    required super.bio,
    required super.publicRepos,
    required super.followers,
    required super.following,
  });

  factory GitHubProfileModel.fromJson(Map<String, dynamic> json) {
    return GitHubProfileModel(
      username: json['login'] as String,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      publicRepos: json['public_repos'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
    );
  }
}
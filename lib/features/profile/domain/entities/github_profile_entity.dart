import 'package:equatable/equatable.dart';

class GitHubProfileEntity extends Equatable {
  final String username;
  final String name;
  final String avatarUrl;
  final String bio;
  final int publicRepos;
  final int followers;
  final int following;

  const GitHubProfileEntity({
    required this.username,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.publicRepos,
    required this.followers,
    required this.following,
  });

  @override
  List<Object?> get props => [
    username,
    name,
    avatarUrl,
    bio,
    publicRepos,
    followers,
    following,
  ];
}
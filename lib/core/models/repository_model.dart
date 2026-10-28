import 'package:equatable/equatable.dart';

class RepositoryModel extends Equatable {
  const RepositoryModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.htmlUrl,
    required this.isPrivate,
    required this.isFork,
    required this.isArchived,
    required this.starsCount,
    required this.forksCount,
    required this.ownerUsername,
    required this.ownerAvatarUrl,
    required this.ownerHtmlUrl,
    required this.ownerType,
    this.language,
  });

  final int id;
  final String name;
  final String fullName;
  final String description;
  final String htmlUrl;
  final bool isPrivate;
  final bool isFork;
  final bool isArchived;

  /// Number of GitHub stars. Falls back to `0` when the API omits it.
  final int starsCount;

  /// Number of GitHub forks. Falls back to `0` when the API omits it.
  final int forksCount;

  /// The primary programming language, or `null` when GitHub has none on file.
  final String? language;

  final String ownerUsername;
  final String ownerAvatarUrl;
  final String ownerHtmlUrl;
  final String ownerType;

  @override
  List<Object?> get props => [
    id,
    name,
    fullName,
    description,
    htmlUrl,
    isPrivate,
    isFork,
    isArchived,
    starsCount,
    forksCount,
    language,
    ownerUsername,
    ownerAvatarUrl,
    ownerHtmlUrl,
    ownerType,
  ];
  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? const {};

    return RepositoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      isPrivate: json['private'] as bool? ?? false,
      isFork: json['fork'] as bool? ?? false,
      isArchived: json['archived'] as bool? ?? false,
      starsCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      language: json['language'] as String?,
      ownerUsername: owner['login'] as String? ?? '',
      ownerAvatarUrl: owner['avatar_url'] as String? ?? '',
      ownerHtmlUrl: owner['html_url'] as String? ?? '',
      ownerType: owner['type'] as String? ?? '',
    );
  }
}

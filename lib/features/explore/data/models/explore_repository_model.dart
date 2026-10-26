import 'package:dev_space/features/explore/domain/entities/explore_repository_entity.dart';

class ExploreRepositoryModel extends ExploreRepositoryEntity {
  const ExploreRepositoryModel({
    required super.id,
    required super.name,
    required super.fullName,
    required super.description,
    required super.htmlUrl,
    required super.isPrivate,
    required super.isFork,
    required super.isArchived,
    required super.starsCount,
    required super.forksCount,
    required super.ownerUsername,
    required super.ownerAvatarUrl,
    required super.ownerHtmlUrl,
    required super.ownerType,
    super.language,
  });

  /// All parsing of the GitHub REST payload lives here, so every field has a
  /// safe fallback and no UI code ever sees raw JSON or literal `null` text.
  factory ExploreRepositoryModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? const {};

    return ExploreRepositoryModel(
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

import 'package:equatable/equatable.dart';

class ExploreRepositoryEntity extends Equatable {
  const ExploreRepositoryEntity({
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
}

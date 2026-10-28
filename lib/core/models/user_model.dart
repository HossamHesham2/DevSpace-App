import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String username;
  final String avatarUrl;
  final String htmlUrl;
  final String type;

  const UserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.type,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['login'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      type: json['type'] as String? ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': username,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [id, username, avatarUrl, htmlUrl, type];
}

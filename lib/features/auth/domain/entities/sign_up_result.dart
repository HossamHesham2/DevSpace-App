import 'package:dev_space/features/auth/domain/entities/auth_entity.dart';

class SignUpResult {
  final AuthEntity user;
  final bool requiresEmailVerification;

  SignUpResult({required this.user, required this.requiresEmailVerification});
}

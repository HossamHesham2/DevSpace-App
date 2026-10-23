import 'package:equatable/equatable.dart';
import 'package:dev_space/features/auth/domain/entities/auth_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final AuthEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthEmailVerificationRequired extends AuthState {
  const AuthEmailVerificationRequired();
}

final class AuthPasswordResetEmailSent extends AuthState {
  const AuthPasswordResetEmailSent();
}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
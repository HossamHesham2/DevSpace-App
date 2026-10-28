import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/helpers/prefs_helper.dart';
import 'package:dev_space/features/auth/domain/entities/auth_entity.dart';
import 'package:dev_space/features/auth/domain/repositories/auth_repository.dart';
import 'package:dev_space/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:dev_space/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:dev_space/features/auth/domain/usecases/sign_in_with_github_use_case.dart';
import 'package:dev_space/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:dev_space/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final SendPasswordResetEmailUseCase _resetPasswordUseCase;
  final AuthRepository _authRepository;
  final SignInWithGitHubUseCase _signInWithGitHubUseCase;
  StreamSubscription<supabase.AuthState>? _authSubscription;
  bool _isGitHubSignInPending = false;

  AuthCubit({
    required this._signInUseCase,
    required this._signUpUseCase,
    required this._signOutUseCase,
    required this._resetPasswordUseCase,
    required this._authRepository,
    required this._signInWithGitHubUseCase,
  }) : super(const AuthInitial());

  Future<void> signIn({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      final result = await _signInUseCase.call(
        email: email,
        password: password,
      );
      if (isClosed) return;
      result.fold(
        (failure) => emit(AuthError(failure.errorMessage)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } on Exception catch (e) {
      if (isClosed) return;
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGitHub() async {
    if (isClosed) return;

    try {
      emit(AuthLoadingGitHub());

      final result = await _signInWithGitHubUseCase();

      if (isClosed) return;

      result.fold(
        (failure) {
          _isGitHubSignInPending = false;
          emit(AuthError(failure.errorMessage));
        },
        (started) {
          // A started attempt only completes through [listenToAuthChanges]
          // once the user comes back from GitHub with a session.
          _isGitHubSignInPending = started;
          if (!started) {
            emit(
              const AuthError(
                'Could not start GitHub authentication.',
              ),
            );
          }
        },
      );
    } catch (e) {
      _isGitHubSignInPending = false;
      if (isClosed) return;
      emit(AuthError(e.toString()));
    }
  }

  /// Detects a GitHub sign-in that the user abandoned.
  ///
  /// A successful OAuth round-trip is reported by [listenToAuthChanges]. When
  /// the app comes back to the foreground while an attempt is still pending
  /// and no session exists, the GitHub window was closed (X) instead of
  /// completed, so the sign-in is marked as cancelled.
  Future<void> handleGitHubAuthReturn() async {
    if (isClosed || !_isGitHubSignInPending) return;

    // Give the OAuth deep link a moment to reach Supabase before deciding
    // that the flow was cancelled.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (isClosed || !_isGitHubSignInPending) return;
    if (_authRepository.currentUser != null) return;

    _isGitHubSignInPending = false;
    emit(const AuthGitHubSignInCancelled());
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      emit(const AuthLoading());

      final result = await _signUpUseCase(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (isClosed) return;

      result.fold((failure) => emit(AuthError(failure.errorMessage)), (
        signUpResult,
      ) {
        if (signUpResult.requiresEmailVerification) {
          emit(const AuthEmailVerificationRequired());
        } else {
          emit(AuthAuthenticated(signUpResult.user));
        }
      });
    } on Exception catch (e) {
      if (isClosed) return;
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    if (isClosed) return;

    // Signing out abandons any GitHub attempt that was still waiting for the
    // user to come back from the GitHub window.
    _isGitHubSignInPending = false;

    try {
      emit(AuthLoading());
      final result = await _signOutUseCase.call();
      if (isClosed) return;

      if (result.isLeft()) {
        result.fold(
          (failure) => emit(AuthError(failure.errorMessage)),
          (_) {},
        );
        return;
      }

      // Without this the next launch would still find "Remember me" and route
      // straight back into the app after signing out.
      await PrefsHelper.instance.setBool(AppConstants.rememberMe, false);

      if (isClosed) return;
      emit(const AuthUnauthenticated());
    } on Exception catch (e) {
      if (isClosed) return;
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      emit(AuthLoading());
      final result = await _resetPasswordUseCase.call(email: email);

      if (isClosed) return;
      result.fold(
        (failure) => emit(AuthError(failure.errorMessage)),
        (_) => emit(const AuthPasswordResetEmailSent()),
      );
    } catch (_) {
      if (isClosed) return;
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  void checkAuthStatus() {
    final user = _authRepository.currentUser;

    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(
      AuthAuthenticated(
        AuthEntity(
          id: user.id,
          fullName: user.userMetadata?['full_name'] as String? ?? '',
          email: user.email ?? '',
        ),
      ),
    );
  }

  void listenToAuthChanges() {
    _authSubscription?.cancel();

    _authSubscription = _authRepository.authStateChanges.listen((authState) {
      if (isClosed) return;

      switch (authState.event) {
        case supabase.AuthChangeEvent.initialSession:
        case supabase.AuthChangeEvent.signedIn:
        case supabase.AuthChangeEvent.tokenRefreshed:
        case supabase.AuthChangeEvent.userUpdated:
          _isGitHubSignInPending = false;
          final user = authState.session?.user;

          if (user == null) {
            emit(const AuthUnauthenticated());
            return;
          }

          emit(
            AuthAuthenticated(
              AuthEntity(
                id: user.id,
                fullName: user.userMetadata?['full_name'] as String? ?? '',
                email: user.email ?? '',
              ),
            ),
          );

        case supabase.AuthChangeEvent.signedOut:
          _isGitHubSignInPending = false;
          emit(const AuthUnauthenticated());

        // Recovery and MFA events do not change the signed-in session here.
        default:
          break;
      }
    });
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}

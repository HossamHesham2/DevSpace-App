import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dev_space/features/auth/domain/entities/auth_entity.dart';
import 'package:dev_space/features/auth/domain/repositories/auth_repository.dart';
import 'package:dev_space/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:dev_space/features/auth/domain/usecases/sign_in_use_case.dart';
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
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthCubit({
    required this._signInUseCase,
    required this._signUpUseCase,
    required this._signOutUseCase,
    required this._resetPasswordUseCase,
    required this._authRepository,
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
    try {
      emit(AuthLoading());
      final result = await _signOutUseCase.call();
      if (isClosed) return;
      result.fold(
        (failure) => emit(AuthError(failure.errorMessage)),
        (_) => emit(const AuthUnauthenticated()),
      );
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

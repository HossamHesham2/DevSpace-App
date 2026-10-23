import 'package:dev_space/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Injectable(as: AuthRemoteDatasource)
class AuthRemoteDatasourceImpl extends AuthRemoteDatasource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDatasourceImpl({required this._supabaseClient});

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  @override
  Future<void> signOut() async {
    return await _supabaseClient.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    final redirectUrl = dotenv.env['PASSWORD_RESET_REDIRECT_URL'];

    return await _supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: (redirectUrl == null || redirectUrl.isEmpty)
          ? null
          : redirectUrl,
    );
  }

  @override
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<bool> signInWithGitHub() async{
    return await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'io.devspace.app://login-callback/',
    );
  }
}

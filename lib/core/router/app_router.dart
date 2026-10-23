import 'package:dev_space/core/router/app_transitions.dart';
import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/features/auth/presentation/pages/auth_page.dart';
import 'package:dev_space/features/auth/presentation/pages/login_page.dart';
import 'package:dev_space/features/auth/presentation/pages/register_page.dart';
import 'package:dev_space/features/auth/presentation/pages/reset_password_page.dart';
import 'package:dev_space/features/main/presentation/pages/main_layout.dart';
import 'package:dev_space/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:dev_space/features/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) =>
            AppTransitions.fade(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => AppTransitions.slideFade(
          state: state,
          child: const OnboardingPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.auth,
        name: RouteNames.auth,
        pageBuilder: (context, state) =>
            AppTransitions.fade(state: state, child: const AuthPage()),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        pageBuilder: (context, state) =>
            AppTransitions.slide(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        pageBuilder: (context, state) =>
            AppTransitions.slide(state: state, child: const RegisterPage()),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: RouteNames.resetPassword,
        pageBuilder: (context, state) => AppTransitions.slide(
          state: state,
          child: ResetPasswordPage(
            initialEmail: state.uri.queryParameters['email'],
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.main,
        name: RouteNames.main,
        pageBuilder: (context, state) =>
            AppTransitions.fade(state: state, child: const MainLayout()),
      ),
    ],
  );
}

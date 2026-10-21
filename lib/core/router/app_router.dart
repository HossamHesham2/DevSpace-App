import 'package:dev_space/features/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';
import 'package:dev_space/core/router/route_names.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => SplashPage(),
      ),
    ],
  );
}

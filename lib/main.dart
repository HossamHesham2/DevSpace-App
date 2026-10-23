import 'package:bloc/bloc.dart';
import 'package:dev_space/app/app.dart';
import 'package:dev_space/app/bloc_observer.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/di/dependency_injection.dart';
import 'package:dev_space/core/helpers/prefs_helper.dart';
import 'package:dev_space/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await PrefsHelper.instance.init();
  await _clearPersistedSessionIfNeeded();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );
  configureDependencies();
  Bloc.observer = AppBlocObserver();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const DevSpaceApp(),
    ),
  );
}

/// Removes a previously persisted Supabase session when the user opted out of
/// "Remember me". Runs before Supabase initializes so the session cannot be
/// restored during app startup.
Future<void> _clearPersistedSessionIfNeeded() async {
  final rememberMe =
      PrefsHelper.instance.getBool(AppConstants.rememberMe) ?? false;
  if (rememberMe) return;

  final prefs = await SharedPreferences.getInstance();
  final authKeys = prefs
      .getKeys()
      .where((key) => key.startsWith('sb-') && key.endsWith('-auth-token'))
      .toList();

  for (final key in authKeys) {
    await prefs.remove(key);
  }
}

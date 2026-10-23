import 'package:bloc/bloc.dart';
import 'package:dev_space/app/app.dart';
import 'package:dev_space/app/bloc_observer.dart';
import 'package:dev_space/core/di/dependency_injection.dart';
import 'package:dev_space/core/helpers/prefs_helper.dart';
import 'package:dev_space/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await PrefsHelper.instance.init();
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

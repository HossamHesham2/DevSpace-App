import 'package:dev_space/app/app.dart';
import 'package:dev_space/core/helpers/prefs_helper.dart';
import 'package:dev_space/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefsHelper.instance.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const DevSpaceApp(),
    ),
  );
}

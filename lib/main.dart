import 'package:flutter/material.dart';
import 'app/my_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/observers/app_observer.dart';
import 'core/helpers/prefs_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsHelper.instance.init();
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

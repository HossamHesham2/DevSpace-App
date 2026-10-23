import 'package:dev_space/core/di/dependency_injection.dart';
import 'package:dev_space/core/router/app_router.dart';
import 'package:dev_space/core/theme/app_theme.dart';
import 'package:dev_space/core/theme/theme_provider.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DevSpaceApp extends StatelessWidget {
  const DevSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>()
        ..checkAuthStatus()
        ..listenToAuthChanges(),
      lazy: false,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'DevSpace',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeProvider.themeMode,
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}

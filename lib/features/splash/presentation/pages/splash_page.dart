import 'dart:async';

import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/extensions/color_extension.dart';
import 'package:dev_space/core/helpers/prefs_helper.dart';
import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      final isOnboardingCompleted =
          PrefsHelper.instance.getBool(AppConstants.onboardingCompleted) ??
          false;

      if (!isOnboardingCompleted) {
        context.goNamed(RouteNames.onboarding);
        return;
      }

      final rememberMe =
          PrefsHelper.instance.getBool(AppConstants.rememberMe) ?? false;
      final isAuthenticated =
          context.read<AuthCubit>().state is AuthAuthenticated;

      context.goNamed(
        rememberMe && isAuthenticated ? RouteNames.main : RouteNames.auth,
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;

    return DScaffold(
      body: Column(
        children: [
          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Secure Link
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: appColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12.r,
                      height: 12.r,
                      decoration: BoxDecoration(
                        color: appColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text("SECURE LINK", style: appText.labelMedium),
                  ],
                ),
              ),

              // Production Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: appColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppSvgs.logoCode,
                      width: 15.r,
                      height: 15.r,
                      colorFilter: ColorFilter.mode(
                        appColors.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text("PROD", style: appText.labelMedium),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // ================= LOGO =================
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: appColors.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: appColors.outlineVariant, width: 2),
              boxShadow: [
                BoxShadow(
                  color: appColors.primary.withValues(alpha: 0.25),
                  blurRadius: 24.r,
                  spreadRadius: 2.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                color: appColors.surfaceContainer,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Stack(
                children: [
                  // Logo
                  Center(
                    child: SvgPicture.asset(
                      AppSvgs.logoCode,
                      width: 35.r,
                      height: 35.r,
                    ),
                  ),

                  // Purple Dot
                  Positioned(
                    top: 10.r,
                    right: 10.r,
                    child: Container(
                      width: 9.r,
                      height: 9.r,
                      decoration: BoxDecoration(
                        color: appColors.primary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // ================= APP NAME =================
          Text(
            AppConstants.appName,
            style: appText.headlineLarge,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10.h),

          // ================= SUBTITLE =================
          Text(
            "Your space. Your code. Your community.",
            style: appText.bodyLarge,
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // ================= LOADING =================
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 3.r,
              strokeCap: StrokeCap.round,
              color: appColors.primary,
            ),
          ),

          SizedBox(height: 20.h),

          // ================= VERSION =================
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: appColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("v1.0.0", style: appText.labelSmall),

                SizedBox(width: 8.w),

                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: BoxDecoration(
                    color: appColors.onSurface,
                    shape: BoxShape.circle,
                  ),
                ),

                SizedBox(width: 8.w),

                Text("Production Ready", style: appText.labelMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

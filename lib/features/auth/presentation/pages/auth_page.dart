import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/extensions/color_extension.dart';
import 'package:dev_space/core/helpers/prefs_helper.dart';
import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/core/widgets/app_snackbar.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/core/widgets/secondary_button.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:dev_space/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with WidgetsBindingObserver {
  Future<void> _continueWithGitHub() async {
    FocusScope.of(context).unfocus();
    await context.read<AuthCubit>().signInWithGitHub();
    await PrefsHelper.instance.setBool(AppConstants.rememberMe,true);

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;

    // Returning to the app without a session means the GitHub window was
    // closed, so the cubit asks the user to start the sign in again.
    context.read<AuthCubit>().handleGitHubAuthReturn();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.goNamed(RouteNames.main);
          return;
        }

        if (state is AuthError) {
          AppSnackBar.error(
            context,
            state.message,
            title: 'GitHub sign in failed',
          );
        }

        if (state is AuthGitHubSignInCancelled) {
          AppSnackBar.warning(
            context,
            'GitHub sign in was cancelled. Please start the sign in again.',
            title: 'Sign in cancelled',
            actionLabel: 'Try again',
            onAction: _continueWithGitHub,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingGitHub;
        return DScaffold(
          body: Column(
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppSvgs.logoCode,
                        width: 20.r,
                        height: 20.r,
                        colorFilter: ColorFilter.mode(
                          appColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Text(
                        AppConstants.appName,
                        style: appText.titleLarge?.copyWith(
                          color: appColors.primary,
                        ),
                      ),
                    ],
                  ),
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
                          width: 8.r,
                          height: 8.r,
                          decoration: BoxDecoration(
                            color: appColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text("v1.0 ONLINE", style: appText.labelMedium),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h),
              Center(
                child: Image.asset(
                  isDark ? AppImages.image4Dark : AppImages.image4Light,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 30.h),

              // Title
              Text("Welcome to DevSpace", style: appText.headlineLarge),

              SizedBox(height: 10.h),

              // Description
              Text(
                "The open-source intelligence platform engineered for modern builders. Explore repos,track velocity, and connect.",
                style: appText.bodyLarge,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30.h),

              SecondaryButton(
                icon: SvgPicture.asset(
                  AppSvgs.githubIcon,
                  colorFilter: ColorFilter.mode(
                    appColors.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                text: "Continue with GitHub",
                isLoading: isLoading,
                onPressed: _continueWithGitHub,
              ),
              SizedBox(height: 10.h),
              PrimaryButton(
                icon: Icon(Icons.email),
                text: "Continue with Email",
                isEnabled: !isLoading,
                onPressed: () {
                  context.pushNamed(RouteNames.login);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

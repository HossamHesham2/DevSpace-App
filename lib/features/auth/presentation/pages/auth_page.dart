import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/extensions/color_extension.dart';
import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/core/widgets/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            onPressed: () {},
          ),
          SizedBox(height: 10.h),
          PrimaryButton(
            icon: Icon(Icons.email),
            text: "Continue with Email",
            onPressed: () {
              context.pushNamed(RouteNames.login);
            },
          ),
        ],
      ),
    );
  }
}

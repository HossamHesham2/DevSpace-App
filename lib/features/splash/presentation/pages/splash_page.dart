import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/extensions/color_extension.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;
    return DScaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: appColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16.r),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppSvgs.logoCode,
                      colorFilter: ColorFilter.mode(
                        appColors.onSurface,
                        BlendMode.srcIn,
                      ),
                      width: 15.r,
                    ),
                    SizedBox(width: 10.w),
                    Text("PROD", style: appText.labelMedium),
                  ],
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: appColors.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: appColors.outlineVariant, width: 2),
              boxShadow: [
                BoxShadow(
                  color: appColors.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: 90.w,
              height: 90.h,
              decoration: BoxDecoration(
                color: appColors.surfaceContainer,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      AppSvgs.logoCode,
                      width: 35.w,
                      height: 35.h,
                    ),
                  ),

                  // Purple Dot
                  Positioned(
                    top: 10.h,
                    right: 10.w,
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
          SizedBox(height: 10.h),
          Text(AppConstants.appName, style: appText.headlineLarge),
          SizedBox(height: 10.h),
          Text(
            "Your space. Your code. Your community.",
            style: appText.bodyLarge,
          ),

          Spacer(),
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: appColors.primary,
            ),
          ),

          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: appColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16.r),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("v1.0.0", style: appText.labelSmall),
                SizedBox(width: 5.w),
                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: BoxDecoration(
                    color: appColors.onSurface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),

                SizedBox(width: 5.w),
                Text("Production Ready", style: appText.labelMedium),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

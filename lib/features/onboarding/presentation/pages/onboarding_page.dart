import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/router/route_names.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:dev_space/features/onboarding/data/models/onboarding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  static const _animationDuration = Duration(milliseconds: 350);
  int pageNumber = 0;
  final List<OnboardingModel> pages = [
    OnboardingModel(
      imageInLight: AppImages.image1Light,
      imageInDark: AppImages.image1Dark,
      title: "Discover Amazing Projects",
      description: "Explore trending repositories, curate breakthrough open-source tools, and dive into community-driven software with granular code intelligence.",
    ),
    OnboardingModel(
      imageInLight: AppImages.image2Light,
      imageInDark: AppImages.image2Dark,
      title: "Connect With Developers",
      description: "Find brilliant builders behind the tools you love. Follow top open-source contributors, inspect tech stacks,and collaborate across global developer ecosystems.",
    ),
    OnboardingModel(
      imageInLight: AppImages.image3Light,
      imageInDark: AppImages.image3Dark,
      title: "Track Your Insights",
      description: "Deep-dive into repository health, inspect language distributions, monitor star momentum, and keep tabs on release telemetry with real-time intelligence.",
    ),
  ];

  bool get isLastPage => pageNumber == pages.length - 1;

  void _nextPage() {
    if (isLastPage) {
      _finishOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: _animationDuration,
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (pageNumber == 0) return;

    _pageController.previousPage(
      duration: _animationDuration,
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() {
    context.goNamed(RouteNames.auth);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).colorScheme;
    final appText = Theme.of(context).textTheme;

    return DScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: pageNumber != 0,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: InkWell(
                    onTap: _previousPage,
                    borderRadius: BorderRadius.circular(50.r),
                    child: Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: appColors.primary),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: appColors.primary,
                        size: 25.r,
                      ),
                    ),
                  ),
                ),

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

                TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    "Skip",
                    style: appText.titleMedium?.copyWith(
                      color: appColors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.h),

            // ================= PAGE VIEW =================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    pageNumber = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];

                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            isDark ? page.imageInDark : page.imageInLight,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Step Badge
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: appColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "Step ${index + 1} of ${pages.length}",
                          style: appText.bodySmall?.copyWith(
                            color: appColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Title
                      Text(page.title, style: appText.titleLarge),

                      SizedBox(height: 10.h),

                      // Description
                      Text(page.description, style: appText.bodyLarge),

                      SizedBox(height: 30.h),
                    ],
                  );
                },
              ),
            ),

            // ================= INDICATORS =================
            _buildIndicators(),

            SizedBox(height: 30.h),

            // ================= CONTINUE BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.primary,
                  foregroundColor: appColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? "Get Started" : "Continue",
                      style: appText.titleMedium?.copyWith(
                        color: appColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Icon(
                      Icons.arrow_forward,
                      color: appColors.onPrimary,
                      size: 20.r,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pages.length, (index) => _buildIndicator(index)),
    );
  }

  Widget _buildIndicator(int index) {
    final appColors = Theme.of(context).colorScheme;

    final bool isActive = pageNumber == index;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: _animationDuration,
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        width: isActive ? 28.w : 8.r,
        height: 8.r,
        decoration: BoxDecoration(
          color: isActive
              ? appColors.primary
              : appColors.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}

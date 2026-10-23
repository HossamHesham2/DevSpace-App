import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/extensions/color_extension.dart';
import 'package:dev_space/core/theme/app_colors.dart';
import 'package:dev_space/core/widgets/app_snackbar.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key, this.onProfileTap});

  /// Called when the profile avatar in the app bar is tapped.
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};

    final avatarUrl = metadata['avatar_url'] as String?;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return DScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40.w,
        leading: Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Center(
            child: SvgPicture.asset(
              AppSvgs.logoCode,
              width: 20.r,
              height: 20.r,
              colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Flexible(
              child: Text(
                AppConstants.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            const _LiveBadge(label: 'LIVE v2.4'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => AppSnackBar.info(
              context,
              'You are all caught up for now.',
              title: 'Notifications',
            ),
            tooltip: 'Notifications',
            style: IconButton.styleFrom(
              foregroundColor: colors.onSurface,
              minimumSize: Size(44.r, 44.r),
            ),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded, size: 24.r),
                Positioned(
                  top: 1.h,
                  right: 1.w,
                  child: Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Tooltip(
            message: 'Profile',
            child: InkWell(
              onTap: onProfileTap,
              customBorder: const CircleBorder(),
              child: Container(
                padding: EdgeInsets.all(3.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: colors.surfaceContainerHighest,
                  foregroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                  onForegroundImageError: hasAvatar
                      ? (exception, stackTrace) {}
                      : null,
                  child: Icon(
                    Icons.person_rounded,
                    size: 40.r,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: colors.outlineVariant),
        ),
      ),

      body: Column(),
    );
  }
}

/// Small status pill shown next to the application name.
class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: colors.success,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: text.labelSmall?.copyWith(
              color: colors.success,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

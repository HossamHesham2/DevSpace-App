import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/constants/app_constants.dart';
import 'package:dev_space/core/di/dependency_injection.dart';
import 'package:dev_space/core/extensions/color_extension.dart';
import 'package:dev_space/core/theme/app_colors.dart';
import 'package:dev_space/core/widgets/app_snackbar.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/core/widgets/secondary_button.dart';
import 'package:dev_space/features/explore/domain/entities/explore_repository_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_space/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:dev_space/features/explore/presentation/cubit/explore_state.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key, this.onProfileTap, this.onSearchTap});

  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExploreCubit>()..getExploreDevelopers(),
      child: _ExploreView(onProfileTap: onProfileTap, onSearchTap: onSearchTap),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const _ExploreView({this.onProfileTap, this.onSearchTap});

  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final name = metadata['name'] as String?;

    return BlocListener<ExploreCubit, ExploreState>(
      listenWhen: (previous, current) => current is ExploreRefreshError,
      listener: (context, state) {
        if (state is ExploreRefreshError) {
          AppSnackBar.error(context, state.message, title: 'Refresh Failed');
        }
      },
      child: DScaffold(
        appBar: _CustomAppBar(onProfileTap: onProfileTap, metadata: metadata),
        body: RefreshIndicator(
          color: colors.primary,
          backgroundColor: colors.surface,
          onRefresh: () async {
            // Existing cards stay visible: the cubit only swaps in new data
            // (or emits an ExploreRefreshError snackbar) once the request
            // completes.
            await context.read<ExploreCubit>().getExploreDevelopers();
          },
          child: ListView(
            // Keeps pull-to-refresh available even when the content is
            // shorter than the viewport.
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Text(
                'Hello, ${name?.split(' ').first ?? 'Developer'} 👋',
                style: text.titleLarge,
              ),

              const SizedBox(height: 4),

              Text(
                'Explore curated open-source projects today',
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),

              const SizedBox(height: 16),

              _SearchCard(onSearchTap: onSearchTap),

              const SizedBox(height: 20),

              BlocBuilder<ExploreCubit, ExploreState>(
                builder: (context, state) {
                  // Initial / first-time loading indicator.
                  if (state is ExploreLoading || state is ExploreInitial) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // A refresh that failed keeps the previously loaded cards
                  // visible; the error itself is surfaced via the snackbar
                  // in the BlocListener above.
                  final developers = switch (state) {
                    ExploreLoaded(:final developers) => developers,
                    ExploreRefreshError(:final developers) => developers,
                    _ => null,
                  };

                  if (state is ExploreError) {
                    return _ExploreErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<ExploreCubit>().getExploreDevelopers(),
                    );
                  }

                  if (developers == null) return const SizedBox.shrink();

                  if (developers.isEmpty) {
                    return const _ExploreEmptyView();
                  }

                  return Column(
                    children: developers.map((repositories) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: _DeveloperRepoCard(repositories: repositories),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final Map<String, dynamic> metadata;

  const _CustomAppBar({
    this.onProfileTap,
    this.metadata = const <String, dynamic>{},
  });

  @override
  Widget build(BuildContext context) {
    final rawAvatarUrl = metadata['avatar_url'];
    final avatarUrl = rawAvatarUrl is String ? rawAvatarUrl.trim() : '';
    final hasAvatar = avatarUrl.isNotEmpty;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: colors.surface,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 30.w,
      leading: Padding(
        padding: EdgeInsets.only(right: 10.w),
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
              style: text.titleMedium?.copyWith(letterSpacing: 0.4),
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
                  size: 28.r,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({this.onSearchTap});

  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onSearchTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search repositories, developers, topics...',
                style: text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.tune, size: 18),
          ],
        ),
      ),
    );
  }
}

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

class _DeveloperRepoCard extends StatelessWidget {
  const _DeveloperRepoCard({required this.repositories});

  final List<ExploreRepositoryEntity> repositories;

  @override
  Widget build(BuildContext context) {
    if (repositories.isEmpty) {
      return const SizedBox.shrink();
    }

    final owner = repositories.first;
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: colors.outlineVariant),
        color: colors.surfaceContainerLow,
      ),
      child: Column(
        children: [
          _DeveloperDetails(
            imagePath: owner.ownerAvatarUrl,
            username: owner.ownerUsername,
            profileUrl: owner.ownerHtmlUrl,
          ),

          ...repositories.map(
            (repo) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _RepositoryCard(repository: repo),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperDetails extends StatelessWidget {
  const _DeveloperDetails({
    required this.imagePath,
    required this.username,
    required this.profileUrl,
  });

  final String imagePath;
  final String username;
  final String profileUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final hasAvatar = imagePath.trim().isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 2.5),
              ),
              child: CircleAvatar(
                radius: 20.r,
                backgroundColor: colors.surfaceContainerHighest,
                // The person icon (child) stays visible while the image
                // loads or when it fails, so an empty/broken avatar never
                // renders as a blank circle.
                foregroundImage: hasAvatar ? NetworkImage(imagePath) : null,
                onForegroundImageError: hasAvatar
                    ? (exception, stackTrace) {}
                    : null,
                child: Icon(
                  Icons.person,
                  size: 26.r,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: text.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '@$username',
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            SecondaryButton(
              text: 'Profile',
              onPressed: () => _openProfile(context),
              borderColor: colors.primary,
              borderRadius: 999,
              width: 100,
            ),
          ],
        ),
        SizedBox(height: 18.h),
      ],
    );
  }

  /// Opens the developer's GitHub profile. There is no real Follow API in
  /// this app, so the profile view is the honest action.
  Future<void> _openProfile(BuildContext context) async {
    final rawUrl = profileUrl.trim().isNotEmpty
        ? profileUrl.trim()
        : 'https://github.com/$username';
    final url = Uri.tryParse(rawUrl);

    if (url != null && (url.scheme == 'https' || url.scheme == 'http')) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _RepositoryCard extends StatelessWidget {
  const _RepositoryCard({required this.repository});

  final ExploreRepositoryEntity repository;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: colors.outlineVariant),
        color: colors.surfaceContainerLow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project: ${repository.name}',
                      style: text.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 5.h),

                    Text(
                      repository.description.isEmpty
                          ? 'No description available'
                          : repository.description,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 5.h),

                    Text(
                      repository.fullName,
                      style: text.bodySmall?.copyWith(color: colors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 5.h),

                    _RepositoryStats(repository: repository),
                  ],
                ),
              ),

              SizedBox(width: 14.w),

              PrimaryButton(
                text: 'View',
                icon: SvgPicture.asset(
                  AppSvgs.openToIcon,
                  colorFilter: ColorFilter.mode(
                    colors.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => _openRepository(context),
                width: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openRepository(BuildContext context) async {
    final url = Uri.tryParse(repository.htmlUrl);

    if (url != null && (url.scheme == 'https' || url.scheme == 'http')) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

/// Compact stars / forks / language row for a repository.
///
/// Missing values fall back safely (counts to `0`, language hidden) so
/// nothing ever renders as `null`.
class _RepositoryStats extends StatelessWidget {
  const _RepositoryStats({required this.repository});

  final ExploreRepositoryEntity repository;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final statStyle = text.labelSmall?.copyWith(color: colors.onSurfaceVariant);
    final iconColor = colors.onSurfaceVariant;

    final language = repository.language?.trim() ?? '';

    return Wrap(
      spacing: 12.w,
      runSpacing: 4.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.star_border_rounded, size: 14, color: iconColor),
        Text(_formatCount(repository.starsCount), style: statStyle),
        Icon(Icons.call_split_rounded, size: 14, color: iconColor),
        Text(_formatCount(repository.forksCount), style: statStyle),
        if (language.isNotEmpty) ...[
          Icon(Icons.code_rounded, size: 14, color: iconColor),
          Text(language, style: statStyle),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return '$count';
    return '${(count / 1000).toStringAsFixed(count < 10000 ? 1 : 0)}k';
  }
}

/// Empty-state widget shown when the feed has no developers.
class _ExploreEmptyView extends StatelessWidget {
  const _ExploreEmptyView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.explore_outlined,
              size: 36,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No developers to show right now.\nPull down to refresh.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error-state widget shown when the initial load fails, with a retry
/// action using the existing project button.
class _ExploreErrorView extends StatelessWidget {
  const _ExploreErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, size: 36, color: colors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              text: 'Retry',
              onPressed: onRetry,
              borderColor: colors.primary,
              width: 140,
            ),
          ],
        ),
      ),
    );
  }
}

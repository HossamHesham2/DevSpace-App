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
  const ExplorePage({super.key, this.onProfileTap, this.onSearchTap});

  /// Called when the profile avatar in the app bar is tapped.
  final VoidCallback? onProfileTap;

  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};

    final avatarUrl = metadata['avatar_url'] as String?;
    final name = metadata['name'] as String?;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return DScaffold(
      appBar: AppBar(
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
                  child: hasAvatar
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.r,
                            strokeCap: StrokeCap.round,
                            color: colors.primary,
                          ),
                        )
                      : Icon(
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

      body: ListView(
        children: [
          Text(
            'Hello, ${name?.split(' ').first ?? 'Developer'} 👋',
            style: text.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Explore 18.4k curated open-source projects today',
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          // Search
          InkWell(
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
          ),

          const SizedBox(height: 16),
          const _TopicFilters(),
          const SizedBox(height: 20),
        ],
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

class _TopicFilters extends StatefulWidget {
  const _TopicFilters();

  @override
  State<_TopicFilters> createState() => _TopicFiltersState();
}

class _TopicFiltersState extends State<_TopicFilters> {
  final topics = ['All', 'TypeScript','Flutter', 'Python', 'Java', 'Swift'];
  String selected = 'All';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final topic in topics)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(topic),
                selected: selected == topic,
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                onSelected: (_) {
                  setState(() => selected = topic);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _GrowthBadge extends StatelessWidget {
  const _GrowthBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF56D6A0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: green.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: green),
      ),
    );
  }
}

class _RepoStats extends StatelessWidget {
  const _RepoStats({
    required this.stars,
    required this.language,
    required this.languageColor,
    this.forks,
  });

  final String stars;
  final String? forks;
  final String language;
  final Color languageColor;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;

    return Wrap(
      spacing: 14,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_border_rounded,
              size: 15,
              color: Color(0xFFE9B86E),
            ),
            const SizedBox(width: 4),
            Text(stars, style: style),
          ],
        ),
        if (forks != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fork_right, size: 15),
              const SizedBox(width: 4),
              Text(forks!, style: style),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 7, color: languageColor),
            const SizedBox(width: 5),
            Text(language, style: style),
          ],
        ),
      ],
    );
  }
}

class _RepositoryCard extends StatelessWidget {
  const _RepositoryCard({
    required this.name,
    required this.description,
    required this.language,
    required this.languageColor,
    required this.stars,
    required this.growth,
  });

  final String name;
  final String description;
  final String language;
  final Color languageColor;
  final String stars;
  final String growth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ExploreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _RepoStats(
                stars: stars,
                language: language,
                languageColor: languageColor,
              ),
              _GrowthBadge(label: growth),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuilderCard extends StatefulWidget {
  const _BuilderCard({
    required this.name,
    required this.handle,
    required this.role,
    required this.commits,
    required this.initials,
  });

  final String name;
  final String handle;
  final String role;
  final String commits;
  final String initials;

  @override
  State<_BuilderCard> createState() => _BuilderCardState();
}

class _BuilderCardState extends State<_BuilderCard> {
  bool following = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _ExploreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  widget.initials,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: theme.textTheme.titleSmall),
                    Text(
                      widget.handle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.role, style: theme.textTheme.bodySmall),
                    Text(
                      widget.commits,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() => following = !following);
                },
                child: Text(following ? 'Following' : 'Follow'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

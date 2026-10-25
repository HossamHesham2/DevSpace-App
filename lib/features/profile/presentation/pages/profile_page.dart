import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/di/dependency_injection.dart';
import 'package:dev_space/core/extensions/color_extension.dart';
import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/features/profile/domain/entities/github_profile_entity.dart';
import 'package:dev_space/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final metadata =
        Supabase.instance.client.auth.currentUser?.userMetadata ?? {};

    final username = metadata['user_name'] as String?;

    return DScaffold(
      padding: EdgeInsets.zero,
      body: BlocProvider(
        create: (_) {
          final cubit = getIt<ProfileCubit>();

          if (username != null && username.isNotEmpty) {
            cubit.getProfile(username);
          }

          return cubit;
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileHeader(),
              SizedBox(height: 22.h),
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (username == null || username.isEmpty) {
                    return const _MessageCard(
                      message: 'GitHub account not connected',
                    );
                  }

                  if (state is ProfileLoading || state is ProfileInitial) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.r),
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  if (state is ProfileError) {
                    return _MessageCard(message: state.message);
                  }

                  if (state is ProfileLoaded) {
                    return _ProfileContent(profile: state.profile);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Profile',
          style: text.headlineMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings_outlined, color: colors.onSurface),
          ),
        ),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final GitHubProfileEntity profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MainProfileCard(profile: profile),
        SizedBox(height: 16.h),
        _AboutCard(bio: profile.bio),
        SizedBox(height: 16.h),
        const _SettingsCard(),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _MainProfileCard extends StatelessWidget {
  final GitHubProfileEntity profile;

  const _MainProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasAvatar = profile.avatarUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: colors.outlineVariant),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.18),
            colors.surfaceContainerLow,
            colors.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.primary, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 40.r,
                      backgroundColor: colors.surfaceContainerHighest,
                      foregroundImage: hasAvatar
                          ? NetworkImage(profile.avatarUrl)
                          : null,
                      onForegroundImageError: hasAvatar ? (_, _) {} : null,
                      child: Icon(Icons.person, color: colors.onSurfaceVariant),
                    ),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 3,
                    child: Container(
                      width: 17.r,
                      height: 17.r,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isNotEmpty ? profile.name : profile.username,
                      style: text.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '@${profile.username}',
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 9.h),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: colors.success,
                          size: 17,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'GitHub Connected',
                            style: text.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              text: "GitHub Profile",
              onPressed: () {
                launchUrl(Uri.parse('https://github.com/${profile.username}'));
              },
              icon: SvgPicture.asset(
                AppSvgs.openToIcon,
                colorFilter: ColorFilter.mode(
                  colors.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
              width: 180,
            ),
          ),
          SizedBox(height: 18.h),
          Container(height: 1.h, color: colors.outlineVariant),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  value: profile.publicRepos.toString(),
                  label: 'Projects',
                ),
              ),
              Container(height: 45.h, width: 1, color: colors.outlineVariant),
              Expanded(
                child: _ProfileStat(
                  value: profile.followers.toString(),
                  label: 'Followers',
                ),
              ),
              Container(height: 45.h, width: 1, color: colors.outlineVariant),
              Expanded(
                child: _ProfileStat(
                  value: profile.following.toString(),
                  label: 'Following',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          value,
          style: text.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  final String bio;

  const _AboutCard({required this.bio});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'About Me',
            trailing: Icon(
              Icons.edit_outlined,
              color: colors.onSurfaceVariant,
              size: 21,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            bio.isNotEmpty ? bio : 'No bio available',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}


class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _SectionCard(
      child: Column(
        children: [
          _SettingsRow(icon: Icons.bookmark_border, title: 'Saved Projects'),
          Divider(color: colors.outlineVariant),
          _SettingsRow(icon: Icons.history, title: 'Recently Viewed'),
          Divider(color: colors.outlineVariant),
          _SettingsRow(icon: Icons.notifications_none, title: 'Notifications'),
          Divider(color: colors.outlineVariant),
          _SettingsRow(
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
          ),
          Divider(color: colors.outlineVariant),
          _SettingsRow(icon: Icons.help_outline, title: 'Help & Support'),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant, size: 23.r),
          SizedBox(width: 18.w),
          Expanded(
            child: Text(
              title,
              style: text.bodyMedium?.copyWith(color: colors.onSurface),
            ),
          ),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(19.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _SectionTitle({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: text.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing,
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return _SectionCard(
      child: Center(
        child: Text(
          message,
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

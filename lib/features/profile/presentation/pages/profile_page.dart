import 'package:dev_space/core/widgets/d_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = Supabase.instance.client.auth.currentUser;

  late final avatarUrl = user?.userMetadata?['avatar_url'];

  late final fullName = user?.userMetadata?['full_name'];

  late final userName = user?.userMetadata?['user_name'];

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return DScaffold(
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Profile", style: text.titleLarge),
              IconButton(onPressed: () {}, icon: Icon(Icons.settings_outlined)),
            ],
          ),
          SizedBox(height: 20.h),
          ProfileDetails(),
        ],
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};

    final avatarUrl = metadata['avatar_url'] as String?;
    final fullName =
        (metadata['full_name'] as String?) ??
        (metadata['name'] as String?) ??
        'Developer';

    final username =
        (metadata['user_name'] as String?) ??
        (metadata['preferred_username'] as String?) ??
        user?.email?.split('@').first ??
        'developer';

    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Image
              Container(
                padding: EdgeInsets.all(3.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 38.r,
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

              SizedBox(width: 14.w),

              // User Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: text.titleMedium?.copyWith(
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

                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 15.r,
                        ),
                        SizedBox(width: 5.w),
                        Flexible(
                          child: Text(
                            'DevSpace Member',
                            style: text.labelSmall,
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

          SizedBox(height: 22.h),

          // Divider
          Divider(color: colors.outlineVariant.withValues(alpha: 0.4)),

          SizedBox(height: 16.h),

          // Profile Statistics
          Row(
            children: [
              Expanded(
                child: _ProfileStat(value: '0', label: 'Projects'),
              ),
              Expanded(
                child: _ProfileStat(value: '0', label: 'Followers'),
              ),
              Expanded(
                child: _ProfileStat(value: '0', label: 'Following'),
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
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

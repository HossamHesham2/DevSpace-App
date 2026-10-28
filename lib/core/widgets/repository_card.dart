import 'package:dev_space/core/constants/app_assets.dart';
import 'package:dev_space/core/widgets/primary_button.dart';
import 'package:dev_space/core/models/repository_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class RepositoryCard extends StatelessWidget {
  const RepositoryCard({super.key, required this.repository});

  final RepositoryModel repository;

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
class _RepositoryStats extends StatelessWidget {
  const _RepositoryStats({required this.repository});

  final RepositoryModel repository;

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
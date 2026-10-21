import 'package:dev_space/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

extension AppColorSchemeExtension on ColorScheme {
  Color get white => AppColors.lightSurface;

  Color get subtitleColor => onSurface.withValues(alpha: 0.7);

  Color get success => AppColors.success;

  Color get successDark => AppColors.successDark;

  Color get onSuccess => AppColors.lightSurface;
}

import 'package:flutter/material.dart';

/// Shared visual metrics for DevSpace buttons.
abstract final class ButtonMetrics {
  static const double height = 52;
  static const double borderRadius = 14;
  static const double iconSize = 20;
  static const double iconSpacing = 8;
  static const double progressSize = 20;
  static const double progressStrokeWidth = 2;
}

/// Internal button content shared by the primary and secondary buttons.
///
/// Renders the label, an optional leading icon, or a centered progress
/// indicator while loading. The button itself keeps its own dimensions.
class ButtonContent extends StatelessWidget {
  const ButtonContent({
    super.key,
    required this.text,
    required this.foregroundColor,
    required this.progressColor,
    required this.textStyle,
    this.icon,
    this.isLoading = false,
  });

  final String text;
  final Color foregroundColor;
  final Color progressColor;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: ButtonMetrics.progressSize,
        child: CircularProgressIndicator(
          strokeWidth: ButtonMetrics.progressStrokeWidth,
          color: progressColor,
          semanticsLabel: 'Loading',
        ),
      );
    }

    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: textStyle?.copyWith(color: foregroundColor),
    );

    if (icon == null) {
      return label;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTheme.merge(
          data: IconThemeData(
            color: foregroundColor,
            size: ButtonMetrics.iconSize,
          ),
          child: icon!,
        ),
        const SizedBox(width: ButtonMetrics.iconSpacing),
        Flexible(child: label),
      ],
    );
  }
}

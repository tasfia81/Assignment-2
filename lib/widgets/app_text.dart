import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

enum AppTextVariant {
  h1,
  h2,
  subtitleMedium,
  body,
  caption,
  goldLabel,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;

  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style;

    switch (variant) {
      case AppTextVariant.h1:
        style = AppTypography.displayBold(fontSize: fontSize ?? 28, color: color ?? AppColors.white);
        break;
      case AppTextVariant.h2:
        style = AppTypography.headingBold(fontSize: fontSize ?? 20, color: color ?? AppColors.gold);
        break;
      case AppTextVariant.subtitleMedium:
        style = AppTypography.subtitleMedium(fontSize: fontSize ?? 16, color: color ?? AppColors.white);
        break;
      case AppTextVariant.body:
        style = AppTypography.bodyText(fontSize: fontSize ?? 14, color: color ?? AppColors.grey);
        break;
      case AppTextVariant.caption:
        style = AppTypography.caption(fontSize: fontSize ?? 12, color: color ?? AppColors.grey);
        break;
      case AppTextVariant.goldLabel:
        style = AppTypography.goldLabel(fontSize: fontSize ?? 14);
        if (color != null) style = style.copyWith(color: color);
        break;
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style,
    );
  }
}

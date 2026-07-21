import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

class PriceWidget extends StatelessWidget {
  final double price;
  final double fontSize;
  final Color color;

  const PriceWidget({
    super.key,
    required this.price,
    this.fontSize = 18.0,
    this.color = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'PKR ${price.toStringAsFixed(0)}',
      style: AppTypography.headingBold(fontSize: fontSize, color: color),
    );
  }
}

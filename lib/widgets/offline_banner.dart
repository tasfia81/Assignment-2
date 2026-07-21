import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: AppColors.gold, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: AppColors.white, size: 16.0),
          const SizedBox(width: 8.0),
          Text(
            'OFFLINE MODE • CHECKOUT DISABLED',
            style: AppTypography.goldLabel(fontSize: 11.0).copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

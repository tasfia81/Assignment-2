import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      maxWidthDiskCache: 600, // Limit cache size for memory optimization
      maxHeightDiskCache: 600,
      placeholder: (context, url) => Container(
        color: AppColors.lightGrey,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.lightGrey,
        child: const Center(
          child: Icon(Icons.fastfood, size: 40, color: AppColors.gold),
        ),
      ),
    );
  }
}

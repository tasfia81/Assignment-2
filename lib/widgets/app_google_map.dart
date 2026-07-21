import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme/colors.dart';
import '../core/utils/map_helper.dart';
import 'app_text.dart';

/// A wrapper widget around [GoogleMap] that safely falls back to a stylized, dark-themed
/// map visualizer on Web if Google Maps JavaScript SDK script is not loaded or missing an API key.
class AppGoogleMap extends StatelessWidget {
  final MapCreatedCallback? onMapCreated;
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final ArgumentCallback<CameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final String? fallbackTitle;

  const AppGoogleMap({
    super.key,
    this.onMapCreated,
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.onCameraMove,
    this.onCameraIdle,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.fallbackTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (isGoogleMapAvailable()) {
      try {
        return GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: initialCameraPosition,
          markers: markers,
          onCameraMove: onCameraMove,
          onCameraIdle: onCameraIdle,
          myLocationButtonEnabled: myLocationButtonEnabled,
          zoomControlsEnabled: zoomControlsEnabled,
        );
      } catch (_) {
        return _buildFallbackMap(context);
      }
    }

    return _buildFallbackMap(context);
  }

  Widget _buildFallbackMap(BuildContext context) {
    final lat = initialCameraPosition.target.latitude;
    final lng = initialCameraPosition.target.longitude;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Stack(
        children: [
          // Grid background lines simulation
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),

          // Center radar / pulse marker visualizer
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(0.1),
                        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(0.2),
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      color: AppColors.gold,
                      size: 34,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                  ),
                  child: AppText(
                    fallbackTitle ?? 'GPS: ${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E',
                    variant: AppTextVariant.caption,
                    color: AppColors.gold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Top Web Map indicator banner
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, color: AppColors.gold, size: 14),
                      SizedBox(width: 6),
                      AppText(
                        'MUSTAV LIVE MAP (WEB PREVIEW)',
                        variant: AppTextVariant.caption,
                        fontSize: 10,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..strokeWidth = 0.5;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

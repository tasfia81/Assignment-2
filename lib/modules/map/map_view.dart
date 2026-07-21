import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_google_map.dart';
import '../../widgets/app_text.dart';
import '../../widgets/primary_app_bar.dart';
import 'map_controller.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: PrimaryAppBar(
        title: controller.isViewingBranch.value ? 'BRANCH LOCATOR' : 'PIN DELIVERY LOCATION',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          Obx(() => AppGoogleMap(
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(controller.currentLat, controller.currentLng),
                  zoom: 14.0,
                ),
                markers: controller.markers.toSet(),
                onCameraMove: controller.onCameraMove,
                onCameraIdle: controller.onCameraIdle,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              )),

          // Custom crosshair in center for pinning (if not viewing a branch)
          if (!controller.isViewingBranch.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 32.0),
                child: Icon(
                  Icons.location_searching,
                  color: AppColors.gold,
                  size: 38,
                ),
              ),
            ),

          // Top action: GPS My Location button
          if (!controller.isViewingBranch.value)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.gold,
                shape: CircleBorder(side: BorderSide(color: AppColors.border, width: 1.0)),
                onPressed: controller.moveToUserLocation,
                child: const Icon(Icons.my_location),
              ),
            ),

          // Bottom Info Sheet Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Obx(() => AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            controller.isViewingBranch.value ? 'STORE DETAILS' : 'DELIVER HERE',
                            variant: AppTextVariant.goldLabel,
                          ),
                          if (controller.nearestStoreInfo.value.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.gold, width: 0.5),
                              ),
                              child: AppText(
                                controller.nearestStoreInfo.value.toUpperCase(),
                                variant: AppTextVariant.caption,
                                color: AppColors.gold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      
                      // Selected Address
                      controller.isLoadingAddress.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.gold),
                              ),
                            )
                          : Row(
                              children: [
                                const Icon(Icons.pin_drop, color: AppColors.gold, size: 20),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: AppText(
                                    controller.selectedAddress.value,
                                    variant: AppTextVariant.body,
                                    color: AppColors.white,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 16.0),
                      
                      // Submit/Confirm Button
                      AppButton(
                        text: controller.isViewingBranch.value ? 'CLOSE MAP' : 'CONFIRM SELECTION',
                        onPressed: controller.confirmAddressSelection,
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

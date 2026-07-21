import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text.dart';
import '../../widgets/price_widget.dart';
import '../../widgets/primary_app_bar.dart';
import '../../routes/app_pages.dart';
import 'tracking_controller.dart';

import '../../widgets/app_google_map.dart';

class TrackingView extends GetView<TrackingController> {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: PrimaryAppBar(
        title: 'ORDER TRACKING',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Delivery estimation card
              _buildEstimationCard(),
              const SizedBox(height: 20.0),

              // Maps tracking visualizer
              _buildMapVisualizer(),
              const SizedBox(height: 24.0),

              // Status Progression Stepper
              const AppText('ORDER PROGRESSION', variant: AppTextVariant.goldLabel),
              const SizedBox(height: 12.0),
              _buildTrackingStepper(),
              const SizedBox(height: 24.0),

              // Summary
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('ORDER ID', variant: AppTextVariant.caption),
                        const SizedBox(height: 2.0),
                        AppText(controller.order.id.toUpperCase(), variant: AppTextVariant.subtitleMedium, fontSize: 16.0),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const AppText('TOTAL AMOUNT', variant: AppTextVariant.caption),
                        const SizedBox(height: 2.0),
                        PriceWidget(price: controller.order.totalAmount, fontSize: 16.0),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28.0),

              AppButton(
                text: 'BACK TO KITCHEN MENU',
                onPressed: () => Get.offAllNamed(AppRoutes.home),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstimationCard() {
    return Obx(() {
      final curStatus = controller.status.value;
      final minutes = controller.minutesRemaining.value;
      
      String statusMsg = 'Connecting to kitchen...';
      if (curStatus == 'Received') statusMsg = 'Order Placed & Received';
      if (curStatus == 'Preparing') statusMsg = 'Patties are sizzling on flat-top';
      if (curStatus == 'Ready') statusMsg = 'Packed hot and awaiting dispatch';
      if (curStatus == 'Out For Delivery') statusMsg = 'Rider is driving to you';
      if (curStatus == 'Delivered') statusMsg = 'Delivered. Enjoy your hot smash!';

      return AppCard(
        backgroundColor: AppColors.surface,
        child: Row(
          children: [
            _buildStatusEmoji(curStatus),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    curStatus == 'Delivered' ? 'DELIVERED!' : 'ESTIMATED ARRIVAL',
                    variant: AppTextVariant.caption,
                    color: AppColors.gold,
                  ),
                  const SizedBox(height: 2.0),
                  AppText(
                    curStatus == 'Delivered' ? 'ENJOY THE SMASH' : '$minutes MINS AWAY',
                    variant: AppTextVariant.h1,
                  ),
                  const SizedBox(height: 4.0),
                  AppText(
                    statusMsg,
                    variant: AppTextVariant.body,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusEmoji(String status) {
    String emoji = '📝';
    if (status == 'Preparing') emoji = '🍳';
    if (status == 'Ready') emoji = '📦';
    if (status == 'Out For Delivery') emoji = '🏍️';
    if (status == 'Delivered') emoji = '🎉';

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.black,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1.0),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  Widget _buildMapVisualizer() {
    final double defaultLat = controller.order.latitude != 0.0 ? controller.order.latitude : 31.4704;
    final double defaultLng = controller.order.longitude != 0.0 ? controller.order.longitude : 74.4087;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: AppGoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(defaultLat, defaultLng),
            zoom: 14.5,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('rider_loc'),
              position: LatLng(defaultLat, defaultLng),
              infoWindow: const InfoWindow(title: 'Your Smashed Burgers Delivery'),
            ),
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          fallbackTitle: 'Rider En Route to Coordinates',
        ),
      ),
    );
  }

  Widget _buildTrackingStepper() {
    return AppCard(
      child: Obx(() {
        final curStatus = controller.status.value;
        
        final bool isPrep = curStatus == 'Preparing' || curStatus == 'Ready' || curStatus == 'Out For Delivery' || curStatus == 'Delivered';
        final bool isReady = curStatus == 'Ready' || curStatus == 'Out For Delivery' || curStatus == 'Delivered';
        final bool isOut = curStatus == 'Out For Delivery' || curStatus == 'Delivered';
        final bool isDel = curStatus == 'Delivered';

        return Column(
          children: [
            _buildStepRow(
              title: 'ORDER RECEIVED',
              description: 'MUSTAV received your ticket request.',
              isActive: true,
              isCompleted: isPrep,
            ),
            _buildStepDivider(isCompleted: isPrep),
            _buildStepRow(
              title: 'SMASHING & PREPARING',
              description: 'Beef patties are locking caramelization crust.',
              isActive: isPrep,
              isCompleted: isReady,
            ),
            _buildStepDivider(isCompleted: isReady),
            _buildStepRow(
              title: 'READY FOR DISPATCH',
              description: 'Burgers bagged hot under fresh seal tags.',
              isActive: isReady,
              isCompleted: isOut,
            ),
            _buildStepDivider(isCompleted: isOut),
            _buildStepRow(
              title: 'OUT FOR DELIVERY',
              description: 'Rider is driving fast to your coordinates.',
              isActive: isOut,
              isCompleted: isDel,
            ),
            _buildStepDivider(isCompleted: isDel),
            _buildStepRow(
              title: 'DELIVERED',
              description: 'Smashed hot, delivered fresh. Enjoy!',
              isActive: isDel,
              isCompleted: isDel,
              isLast: true,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepRow({
    required String title,
    required String description,
    required bool isActive,
    required bool isCompleted,
    bool isLast = false,
  }) {
    Color dotColor = AppColors.lightGrey;
    Color titleColor = AppColors.grey;
    if (isCompleted) {
      dotColor = AppColors.gold;
      titleColor = AppColors.white;
    } else if (isActive) {
      dotColor = AppColors.accentGold;
      titleColor = AppColors.gold;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppColors.white : Colors.transparent,
                  width: 2.0,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.5),
                          blurRadius: 6,
                        )
                      ]
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                variant: AppTextVariant.subtitleMedium,
                fontSize: 14.0,
                color: titleColor,
              ),
              const SizedBox(height: 2.0),
              AppText(
                description,
                variant: AppTextVariant.caption,
                color: AppColors.grey,
              ),
              if (!isLast) const SizedBox(height: 12.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isCompleted}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 7.0),
      child: Container(
        height: 20,
        width: 2,
        color: isCompleted ? AppColors.gold : AppColors.lightGrey,
      ),
    );
  }
}

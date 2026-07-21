import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/app_text.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/price_widget.dart';
import '../../widgets/quantity_button.dart';
import 'details_controller.dart';

class DetailsView extends GetView<DetailsController> {
  const DetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final burger = controller.menuItem;
    final connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          burger.name.toUpperCase(),
          style: AppTypography.headingBold(fontSize: 20.0, color: AppColors.white),
        ),
      ),
      body: Obx(() => Column(
            children: [
              // Connection Status Banner
              if (connectivityService.isOffline.value) const OfflineBanner(),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Large Image surface Card
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: AppColors.border, width: 1.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19.0),
                          child: AppImage(
                            imageUrl: burger.imageUrl,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Title & Price Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AppText(
                              burger.name,
                              variant: AppTextVariant.h1,
                              color: AppColors.white,
                            ),
                          ),
                          PriceWidget(price: burger.price, fontSize: 24.0),
                        ],
                      ),
                      const SizedBox(height: 12.0),

                      // Description
                      AppText(
                        burger.description,
                        variant: AppTextVariant.body,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 20.0),

                      // Macros Breakdown
                      _buildNutritionalInfo(),
                      const SizedBox(height: 24.0),

                      // Customizations (Add-ons & onion removals)
                      if (burger.availableAddons.isNotEmpty) ...[
                        const AppText('CUSTOMIZE YOUR ORDER', variant: AppTextVariant.goldLabel),
                        const SizedBox(height: 12.0),
                        
                        // Map addons
                        Column(
                          children: burger.availableAddons.map((addon) {
                            return Obx(() {
                              final isSelected = controller.isAddonSelected(addon.id);
                              return AppCard(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                backgroundColor: isSelected ? AppColors.lightGrey : AppColors.surface,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(addon.name, variant: AppTextVariant.subtitleMedium, fontSize: 15.0),
                                        const SizedBox(height: 2.0),
                                        AppText(
                                          addon.category == 'patty' ? 'Extra Smashed Patty' : 'Cheese Melt Addon',
                                          variant: AppTextVariant.caption,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        PriceWidget(price: addon.price, fontSize: 15.0),
                                        const SizedBox(width: 12.0),
                                        Checkbox(
                                          value: isSelected,
                                          activeColor: AppColors.gold,
                                          checkColor: AppColors.black,
                                          onChanged: (val) => controller.toggleAddon(addon),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            });
                          }).toList(),
                        ),
                        const SizedBox(height: 8.0),
                      ],

                      // Remove onion toggle - only for smashed burgers
                      if (burger.category == 'smashed') ...[
                        const AppText('INGREDIENTS CUSTOMIZATION', variant: AppTextVariant.goldLabel),
                        const SizedBox(height: 12.0),
                        Obx(() => AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                activeColor: AppColors.gold,
                                title: const AppText('REMOVE ONIONS', variant: AppTextVariant.subtitleMedium, fontSize: 15.0),
                                subtitle: const AppText('No fresh onions in the burger stack.', variant: AppTextVariant.caption),
                                value: controller.removeOnion.value,
                                onChanged: (val) => controller.toggleRemoveOnion(),
                              ),
                            )),
                        const SizedBox(height: 24.0),
                      ],

                      // Special Instructions
                      const AppText('SPECIAL INSTRUCTIONS', variant: AppTextVariant.goldLabel),
                      const SizedBox(height: 12.0),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppColors.border, width: 1.0),
                        ),
                        child: TextField(
                          controller: controller.instructionsController,
                          maxLines: 2,
                          style: AppTypography.bodyText(color: AppColors.white),
                          decoration: InputDecoration(
                            hintText: 'e.g. Extra hot glaze, no pickles...',
                            hintStyle: AppTypography.bodyText(color: AppColors.grey.withOpacity(0.4)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ),
              
              // Bottom bar purchase
              _buildPurchaseBar(),
            ],
          )),
    );
  }

  Widget _buildNutritionalInfo() {
    final burger = controller.menuItem;
    final stats = [
      {'label': 'CALORIES', 'val': '${burger.calories} kcal'},
      {'label': 'PROTEIN', 'val': '${burger.protein.toInt()}g'},
      {'label': 'CARBS', 'val': '${burger.carbs.toInt()}g'},
      {'label': 'FAT', 'val': '${burger.fat.toInt()}g'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats.map((stat) {
        return Expanded(
          child: AppCard(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            padding: const EdgeInsets.all(10.0),
            borderRadius: 12.0,
            child: Column(
              children: [
                AppText(stat['label']!, variant: AppTextVariant.caption),
                const SizedBox(height: 4.0),
                AppText(
                  stat['val']!,
                  variant: AppTextVariant.goldLabel,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurchaseBar() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 24.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Row(
        children: [
          // Quantity Selector
          Obx(() => QuantityButton(
                quantity: controller.quantity.value,
                onIncrement: controller.incrementQuantity,
                onDecrement: controller.decrementQuantity,
              )),
          const SizedBox(width: 16.0),
          // Price and Button
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() => AppText(
                      'TOTAL: PKR ${controller.totalComputedPrice.toInt()}',
                      variant: AppTextVariant.h2,
                      color: AppColors.gold,
                      textAlign: TextAlign.right,
                    )),
                const SizedBox(height: 4.0),
                AppButton(
                  text: 'ADD TO GRILL',
                  onPressed: controller.addToCart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

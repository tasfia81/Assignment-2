import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../routes/app_pages.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/price_widget.dart';
import '../../widgets/quantity_button.dart';
import '../../widgets/primary_app_bar.dart';
import 'cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: PrimaryAppBar(
        title: 'YOUR GRILL (CART)',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final items = controller.cartService.cartItems;
        
        if (items.isEmpty) {
          return _buildEmptyCartView();
        }

        return Column(
          children: [
            // Offline banner alerts
            if (controller.connectivityService.isOffline.value) const OfflineBanner(),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // Cart failure retry alert card
                  if (controller.isCheckoutError.value) _buildCheckoutFailureCard(),
                  const SizedBox(height: 8.0),

                  // Cart items list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItemCard(item);
                    },
                  ),
                  const SizedBox(height: 12.0),

                  // Delivery Address card
                  _buildAddressSection(),
                  const SizedBox(height: 20.0),

                  // Payment configuration Card
                  _buildPaymentSection(),
                  const SizedBox(height: 20.0),

                  // Invoice values details
                  _buildInvoiceCard(),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
            
            // Bottom persistent purchase controls
            _buildCheckoutAction(),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCartView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: const Text('🛒', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 32.0),
            const AppText(
              'YOUR GRILL IS COLD!',
              variant: AppTextVariant.h1,
              color: AppColors.gold,
            ),
            const SizedBox(height: 8.0),
            const AppText(
              'You haven\'t added any smash items to the cart yet.',
              variant: AppTextVariant.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            AppButton(
              text: 'EXPLORE MENU',
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutFailureCard() {
    return AppCard(
      backgroundColor: AppColors.error.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 24),
              SizedBox(width: 10),
              AppText('CONNECTION TIMEOUT ERROR', variant: AppTextVariant.goldLabel, color: AppColors.error),
            ],
          ),
          const SizedBox(height: 8.0),
          const AppText(
            'Order submission failed due to simulated network failure. Your cart data is fully preserved and intact.',
            variant: AppTextVariant.body,
            color: AppColors.white,
          ),
          const SizedBox(height: 12.0),
          AppButton(
            text: 'RETRY CHECKOUT NOW',
            onPressed: controller.checkout,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(dynamic item) {
    // List selected customizations
    final List<String> details = [];
    for (final addon in item.selectedAddons) {
      details.add('+ ${addon.name}');
    }
    if (item.removeOnion) {
      details.add('• No Onions');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Thumbnail Image
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11.0),
              child: Image.network(
                item.menuItem.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // Info & counter controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item.menuItem.name,
                  variant: AppTextVariant.subtitleMedium,
                  fontSize: 16.0,
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  AppText(
                    details.join(' • '),
                    variant: AppTextVariant.caption,
                    color: AppColors.gold,
                  ),
                ],
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PriceWidget(
                      price: item.totalPrice,
                      fontSize: 16.0,
                    ),
                    
                    // Quantity adjustments widget
                    QuantityButton(
                      quantity: item.quantity,
                      onIncrement: () => controller.cartService.updateQuantity(item.id, item.quantity + 1),
                      onDecrement: () => controller.cartService.updateQuantity(item.id, item.quantity - 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('DELIVER TO', variant: AppTextVariant.goldLabel),
              GestureDetector(
                onTap: () async {
                  await Get.toNamed(AppRoutes.map);
                  controller.loadUserData();
                },
                child: AppText(
                  'CHANGE ON MAP',
                  variant: AppTextVariant.caption,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.gold, size: 20),
              const SizedBox(width: 8.0),
              Expanded(
                child: Obx(() => AppText(
                      controller.userAddress.value,
                      variant: AppTextVariant.body,
                      color: AppColors.white,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final options = ['Cash on Delivery', 'Mock Card'];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('PAYMENT METHOD', variant: AppTextVariant.goldLabel),
          const SizedBox(height: 12.0),
          Row(
            children: options.map((opt) {
              return Expanded(
                child: Obx(() {
                  final isSelected = controller.paymentMethod.value == opt;
                  return GestureDetector(
                    onTap: () => controller.setPaymentMethod(opt),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : AppColors.black,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : AppColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        opt.toUpperCase(),
                        style: AppTypography.goldLabel(
                          fontSize: 12.0,
                        ).copyWith(
                          color: isSelected ? AppColors.black : AppColors.white,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return AppCard(
      child: Column(
        children: [
          _buildInvoiceRow('Subtotal', controller.cartService.subtotal),
          const SizedBox(height: 8.0),
          _buildInvoiceRow('Delivery Charge', controller.cartService.deliveryFee),
          const Divider(color: AppColors.border, thickness: 1.0, height: 24.0),
          _buildInvoiceRow(
            'Grand Total',
            controller.cartService.grandTotal,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: isBold ? AppTextVariant.h2 : AppTextVariant.body,
          color: isBold ? AppColors.gold : AppColors.white,
        ),
        PriceWidget(
          price: value,
          fontSize: isBold ? 18.0 : 14.0,
          color: isBold ? AppColors.gold : AppColors.white,
        ),
      ],
    );
  }

  Widget _buildCheckoutAction() {
    final bool isOffline = controller.connectivityService.isOffline.value;

    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 24.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: AppButton(
        text: isOffline ? 'OFFLINE - SUBMIT BLOCKED' : 'SUBMIT ORDER',
        isLoading: controller.isLoading.value,
        onPressed: isOffline ? null : controller.checkout,
      ),
    );
  }
}

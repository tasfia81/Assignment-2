import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../models/menu_item_model.dart';
import '../../models/addon_model.dart';
import '../../models/cart_item_model.dart';
import '../../services/cart_service.dart';

/// View Controller for Product Detail & Customization Screen.
/// 
/// Controls product quantity, optional addon selections (e.g. extra smashed patty, extra cheddar),
/// custom instructions (e.g., no onion), price recalculations, and adding the configured item to [CartService].
class DetailsController extends GetxController {
  final CartService _cartService = Get.find<CartService>();

  /// Selected burger/menu item passed via route arguments.
  late MenuItemModel menuItem;

  /// Quantity selector value.
  final quantity = 1.obs;
  
  /// List of selected extra add-ons.
  final selectedAddons = <AddonModel>[].obs;

  /// Flag to remove onions from the item.
  final removeOnion = false.obs;
  
  /// Text controller for custom preparation instructions.
  final instructionsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    menuItem = Get.arguments as MenuItemModel;
  }

  /// Increments quantity value.
  void incrementQuantity() => quantity.value++;

  /// Decrements quantity value, enforcing a minimum of 1.
  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  /// Toggles an addon selection (adds if missing, removes if present).
  void toggleAddon(AddonModel addon) {
    final existingIndex = selectedAddons.indexWhere((a) => a.id == addon.id);
    if (existingIndex != -1) {
      selectedAddons.removeAt(existingIndex);
    } else {
      selectedAddons.add(addon);
    }
  }

  /// Checks if a specific addon ID is currently selected.
  bool isAddonSelected(String addonId) {
    return selectedAddons.any((a) => a.id == addonId);
  }

  /// Toggles the remove onion customization switch.
  void toggleRemoveOnion() {
    removeOnion.value = !removeOnion.value;
  }

  /// Calculates single unit price including base menu item price + sum of selected addons.
  double get singlePrice {
    double total = menuItem.price;
    for (final addon in selectedAddons) {
      total += addon.price;
    }
    return total;
  }

  /// Calculates total price for the configured quantity ([singlePrice] * [quantity]).
  double get totalComputedPrice => singlePrice * quantity.value;

  /// Constructs a [CartItemModel] with selected options and adds it to [CartService].
  void addToCart() {
    final cartItem = CartItemModel(
      id: const Uuid().v4(),
      menuItem: menuItem,
      quantity: quantity.value,
      selectedAddons: List<AddonModel>.from(selectedAddons),
      removeOnion: removeOnion.value,
      customInstructions: instructionsController.text.trim(),
    );

    _cartService.addItem(cartItem);
    
    // Close details screen first
    Get.back();
    
    // Show confirmation notification banner
    Get.snackbar(
      '🔥 ADDED TO GRILL',
      '${menuItem.name} x${quantity.value} added to your cart!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12.0),
    );
  }

  @override
  void onClose() {
    instructionsController.dispose();
    super.onClose();
  }
}

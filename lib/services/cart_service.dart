import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../core/values/constants.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

/// Application-wide Reactive Cart Management Service.
/// 
/// Controls the active shopping cart state, handles item additions with custom configurations,
/// performs automatic persistence to local Hive storage (`cartBox`), and computes pricing totals.
class CartService extends GetxService {
  final Box _cartBox;
  
  /// Observable reactive state containing the current shopping cart model.
  final Rx<CartModel> cart = CartModel(items: []).obs;

  CartService(this._cartBox);

  /// Initializes the service by reading stored cart data from Hive.
  Future<CartService> init() async {
    _loadCartFromBox();
    return this;
  }

  /// Deserializes JSON string stored in Hive into the reactive [cart] model.
  void _loadCartFromBox() {
    final String? cartJson = _cartBox.get(AppConstants.keyCartItems) as String?;
    if (cartJson != null) {
      try {
        final decoded = jsonDecode(cartJson) as Map<String, dynamic>;
        cart.value = CartModel.fromJson(decoded);
      } catch (_) {
        // Delete corrupted data to prevent application crashes
        _cartBox.delete(AppConstants.keyCartItems);
      }
    }
  }

  /// Serializes current cart state into JSON and updates Hive disk cache.
  Future<void> _saveCartToBox() async {
    final String serialized = jsonEncode(cart.value.toJson());
    await _cartBox.put(AppConstants.keyCartItems, serialized);
  }

  /// Adds a new [CartItemModel] to the shopping cart.
  /// 
  /// Checks for duplicate item configurations (same item ID, matching add-ons, and onion preferences).
  /// If an exact matching item exists, increments its quantity rather than adding a separate line item.
  void addItem(CartItemModel newItem) {
    final List<CartItemModel> updatedItems = List.from(cart.value.items);
    
    // Check if identical item configuration already exists in cart
    final int existingIndex = updatedItems.indexWhere((item) =>
        item.menuItem.id == newItem.menuItem.id &&
        _areAddonsEqual(item.selectedAddons, newItem.selectedAddons) &&
        item.removeOnion == newItem.removeOnion);

    if (existingIndex != -1) {
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + newItem.quantity,
      );
    } else {
      updatedItems.add(newItem);
    }

    cart.value = cart.value.copyWith(items: updatedItems);
    _saveCartToBox();
  }

  /// Removes an item completely from the cart by its unique cart item ID.
  void removeItem(String cartItemId) {
    final List<CartItemModel> updatedItems = List.from(cart.value.items);
    updatedItems.removeWhere((item) => item.id == cartItemId);
    
    cart.value = cart.value.copyWith(items: updatedItems);
    _saveCartToBox();
  }

  /// Updates quantity for a specific line item.
  /// If quantity reaches zero or negative, automatically removes the item.
  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }
    
    final List<CartItemModel> updatedItems = List.from(cart.value.items);
    final int index = updatedItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      updatedItems[index] = updatedItems[index].copyWith(quantity: newQuantity);
      cart.value = cart.value.copyWith(items: updatedItems);
      _saveCartToBox();
    }
  }

  /// Empties the cart completely (e.g. after successful checkout).
  void clearCart() {
    cart.value = CartModel(items: []);
    _saveCartToBox();
  }

  /// Helper to compare whether two lists of selected add-ons are set-equivalent.
  bool _areAddonsEqual(dynamic list1, dynamic list2) {
    if (list1.length != list2.length) return false;
    final set1 = list1.map((e) => e.id).toSet();
    final set2 = list2.map((e) => e.id).toSet();
    return set1.difference(set2).isEmpty;
  }

  // Handy state getters for convenient UI bindings
  List<CartItemModel> get cartItems => cart.value.items;
  int get totalQuantity => cart.value.totalQuantity;
  double get subtotal => cart.value.subtotal;
  double get deliveryFee => cart.value.deliveryFee;
  double get grandTotal => cart.value.grandTotal;
}

import 'menu_item_model.dart';
import 'addon_model.dart';

class CartItemModel {
  final String id;
  final MenuItemModel menuItem;
  final int quantity;
  final List<AddonModel> selectedAddons;
  final bool removeOnion;
  final String customInstructions;

  CartItemModel({
    required this.id,
    required this.menuItem,
    this.quantity = 1,
    required this.selectedAddons,
    this.removeOnion = false,
    this.customInstructions = '',
  });

  // Calculate single item price including all selected addons
  double get singleItemPrice {
    double total = menuItem.price;
    for (final addon in selectedAddons) {
      total += addon.price;
    }
    return total;
  }

  double get totalPrice => singleItemPrice * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      menuItem: MenuItemModel.fromJson(json['menuItem'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedAddons: (json['selectedAddons'] as List)
          .map((e) => AddonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      removeOnion: json['removeOnion'] as bool? ?? false,
      customInstructions: json['customInstructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
      'selectedAddons': selectedAddons.map((e) => e.toJson()).toList(),
      'removeOnion': removeOnion,
      'customInstructions': customInstructions,
    };
  }

  CartItemModel copyWith({
    String? id,
    MenuItemModel? menuItem,
    int? quantity,
    List<AddonModel>? selectedAddons,
    bool? removeOnion,
    String? customInstructions,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      removeOnion: removeOnion ?? this.removeOnion,
      customInstructions: customInstructions ?? this.customInstructions,
    );
  }
}

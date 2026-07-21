import 'cart_item_model.dart';

class CartModel {
  final List<CartItemModel> items;
  final double deliveryFee;

  CartModel({
    required this.items,
    this.deliveryFee = 150.0, // Flat 150 PKR delivery charge
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get grandTotal => items.isEmpty ? 0.0 : subtotal + deliveryFee;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryFee: (json['deliveryFee'] as num? ?? 150.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'deliveryFee': deliveryFee,
    };
  }

  CartModel copyWith({
    List<CartItemModel>? items,
    double? deliveryFee,
  }) {
    return CartModel(
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }
}

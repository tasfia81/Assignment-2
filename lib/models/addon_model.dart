class AddonModel {
  final String id;
  final String name;
  final double price;
  final String category; // 'patty', 'cheese', 'sauce', 'veggie'
  final bool isSelected;

  AddonModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isSelected = false,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'isSelected': isSelected,
    };
  }

  AddonModel copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    bool? isSelected,
  }) {
    return AddonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

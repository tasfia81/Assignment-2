class BurgerModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String imageUrl;
  final String category; // 'smashed', 'sides', 'drinks', 'sauces'
  final bool isFeatured;
  final List<String> ingredients;
  final String prepTime;     // e.g. "12 mins"
  final String spiceLevel;   // e.g. "Chili Honey Glaze", "Mild", "None"
  final String pattyType;    // e.g. "Smashed Beef", "Crispy Chicken", "Veggie"

  BurgerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.imageUrl,
    required this.category,
    this.isFeatured = false,
    required this.ingredients,
    required this.prepTime,
    required this.spiceLevel,
    required this.pattyType,
  });

  factory BurgerModel.fromJson(Map<String, dynamic> json) {
    return BurgerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isFeatured: json['isFeatured'] as bool? ?? false,
      ingredients: List<String>.from(json['ingredients'] as List),
      prepTime: json['prepTime'] as String? ?? '10 mins',
      spiceLevel: json['spiceLevel'] as String? ?? 'None',
      pattyType: json['pattyType'] as String? ?? 'Smashed Beef',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'imageUrl': imageUrl,
      'category': category,
      'isFeatured': isFeatured,
      'ingredients': ingredients,
      'prepTime': prepTime,
      'spiceLevel': spiceLevel,
      'pattyType': pattyType,
    };
  }

  BurgerModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? imageUrl,
    String? category,
    bool? isFeatured,
    List<String>? ingredients,
    String? prepTime,
    String? spiceLevel,
    String? pattyType,
  }) {
    return BurgerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
      ingredients: ingredients ?? this.ingredients,
      prepTime: prepTime ?? this.prepTime,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      pattyType: pattyType ?? this.pattyType,
    );
  }
}

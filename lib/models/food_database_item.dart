// lib/models/food_database_item.dart

import '../models/food_item.dart';

/// Food Database Item Model
/// Represents a pre-defined food item with nutritional information
class FoodDatabaseItem {
  final String id;
  final String name;
  final String category;
  final double calories; // per 100g
  final double protein; // per 100g
  final double carbs; // per 100g
  final double fat; // per 100g
  final String unit; // serving unit (g, ml, piece, etc.)
  final double servingSize; // standard serving size
  final List<String> tags; // for search functionality
  final String? imageAsset; // optional image path
  final String? description;

  const FoodDatabaseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.unit,
    required this.servingSize,
    this.tags = const [],
    this.imageAsset,
    this.description,
  });

  /// Calculate nutrition for specific serving size
  Map<String, double> getNutritionForServing(double servingAmount) {
    final ratio = servingAmount / 100.0; // nutrition is per 100g
    return {
      'calories': calories * ratio,
      'protein': protein * ratio,
      'carbs': carbs * ratio,
      'fat': fat * ratio,
    };
  }

  /// Get nutrition for standard serving
  Map<String, double> get standardServingNutrition {
    return getNutritionForServing(servingSize);
  }

  /// Convert to FoodItem for adding to diary
  FoodItem toFoodItem({
    required String mealType,
    required DateTime date,
    double? customServing,
  }) {
    final serving = customServing ?? servingSize;
    final nutrition = getNutritionForServing(serving);

    return FoodItem(
      name: name,
      calories: nutrition['calories']!,
      protein: nutrition['protein']!,
      carbs: nutrition['carbs']!,
      fat: nutrition['fat']!,
      mealType: mealType,
      date: date,
      quantity: serving,
      unit: unit,
    );
  }

  /// Create from JSON (for future API integration)
  factory FoodDatabaseItem.fromJson(Map<String, dynamic> json) {
    return FoodDatabaseItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      unit: json['unit'],
      servingSize: (json['servingSize'] as num).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      imageAsset: json['imageAsset'],
      description: json['description'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'unit': unit,
      'servingSize': servingSize,
      'tags': tags,
      'imageAsset': imageAsset,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodDatabaseItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FoodDatabaseItem(id: $id, name: $name, category: $category)';
}

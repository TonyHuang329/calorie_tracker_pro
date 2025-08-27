// lib/services/food_database_service.dart

import 'package:flutter/foundation.dart';
import '../models/food_database_item.dart';

/// Food Database Service
/// Manages common food items database for user selection
class FoodDatabaseService {
  static FoodDatabaseService? _instance;
  static FoodDatabaseService get instance =>
      _instance ??= FoodDatabaseService._();

  FoodDatabaseService._();

  // Cache for loaded food items
  List<FoodDatabaseItem>? _foodDatabase;
  Map<String, List<FoodDatabaseItem>>? _categorizedFoods;

  /// Get all food items
  List<FoodDatabaseItem> get allFoods {
    _foodDatabase ??= _loadFoodDatabase();
    return _foodDatabase!;
  }

  /// Get foods by category
  Map<String, List<FoodDatabaseItem>> get categorizedFoods {
    if (_categorizedFoods == null) {
      _categorizedFoods = {};
      for (final food in allFoods) {
        _categorizedFoods!.putIfAbsent(food.category, () => []).add(food);
      }
    }
    return _categorizedFoods!;
  }

  /// Get all available categories
  List<String> get categories {
    return categorizedFoods.keys.toList()..sort();
  }

  /// Search foods by name or tags
  List<FoodDatabaseItem> searchFoods(String query) {
    if (query.isEmpty) return allFoods;

    final lowerQuery = query.toLowerCase();
    return allFoods.where((food) {
      return food.name.toLowerCase().contains(lowerQuery) ||
          food.category.toLowerCase().contains(lowerQuery) ||
          food.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get foods by category
  List<FoodDatabaseItem> getFoodsByCategory(String category) {
    return categorizedFoods[category] ?? [];
  }

  /// Get popular foods (most commonly used items)
  List<FoodDatabaseItem> getPopularFoods({int limit = 20}) {
    // Return a curated list of popular foods
    final popularIds = [
      'rice_white',
      'chicken_breast',
      'apple_fresh',
      'banana_fresh',
      'egg_whole',
      'milk_whole',
      'bread_white',
      'potato_baked',
      'salmon_grilled',
      'yogurt_plain',
      'oats_rolled',
      'broccoli_steamed',
      'pasta_cooked',
      'cheese_cheddar',
      'orange_fresh',
      'beef_lean',
      'spinach_fresh',
      'tomato_fresh',
      'avocado_fresh',
      'almonds_raw'
    ];

    final popularFoods = <FoodDatabaseItem>[];
    for (final id in popularIds) {
      try {
        final food = allFoods.firstWhere((f) => f.id == id);
        popularFoods.add(food);
      } catch (e) {
        // Food not found, skip
        continue;
      }
    }

    return popularFoods.take(limit).toList();
  }

  /// Load the food database
  List<FoodDatabaseItem> _loadFoodDatabase() {
    return [
      // FRUITS
      FoodDatabaseItem(
        id: 'apple_fresh',
        name: 'Apple',
        category: 'Fruits',
        calories: 52,
        protein: 0.3,
        carbs: 14,
        fat: 0.2,
        unit: 'g',
        servingSize: 150, // medium apple
        tags: ['fresh', 'raw', 'vitamin c'],
      ),
      FoodDatabaseItem(
        id: 'banana_fresh',
        name: 'Banana',
        category: 'Fruits',
        calories: 89,
        protein: 1.1,
        carbs: 23,
        fat: 0.3,
        unit: 'g',
        servingSize: 120, // medium banana
        tags: ['fresh', 'potassium', 'energy'],
      ),
      FoodDatabaseItem(
        id: 'orange_fresh',
        name: 'Orange',
        category: 'Fruits',
        calories: 47,
        protein: 0.9,
        carbs: 12,
        fat: 0.1,
        unit: 'g',
        servingSize: 130, // medium orange
        tags: ['fresh', 'citrus', 'vitamin c'],
      ),
      FoodDatabaseItem(
        id: 'avocado_fresh',
        name: 'Avocado',
        category: 'Fruits',
        calories: 160,
        protein: 2,
        carbs: 9,
        fat: 15,
        unit: 'g',
        servingSize: 100, // half avocado
        tags: ['fresh', 'healthy fat', 'fiber'],
      ),

      // VEGETABLES
      FoodDatabaseItem(
        id: 'broccoli_steamed',
        name: 'Broccoli (Steamed)',
        category: 'Vegetables',
        calories: 35,
        protein: 3.7,
        carbs: 7,
        fat: 0.4,
        unit: 'g',
        servingSize: 100,
        tags: ['green', 'steamed', 'vitamin k'],
      ),
      FoodDatabaseItem(
        id: 'spinach_fresh',
        name: 'Spinach (Raw)',
        category: 'Vegetables',
        calories: 23,
        protein: 2.9,
        carbs: 3.6,
        fat: 0.4,
        unit: 'g',
        servingSize: 85, // 3 cups
        tags: ['leafy green', 'iron', 'folate'],
      ),
      FoodDatabaseItem(
        id: 'carrot_raw',
        name: 'Carrot (Raw)',
        category: 'Vegetables',
        calories: 41,
        protein: 0.9,
        carbs: 10,
        fat: 0.2,
        unit: 'g',
        servingSize: 60, // medium carrot
        tags: ['orange', 'beta carotene', 'crunchy'],
      ),
      FoodDatabaseItem(
        id: 'tomato_fresh',
        name: 'Tomato (Fresh)',
        category: 'Vegetables',
        calories: 18,
        protein: 0.9,
        carbs: 3.9,
        fat: 0.2,
        unit: 'g',
        servingSize: 150, // medium tomato
        tags: ['red', 'lycopene', 'fresh'],
      ),

      // GRAINS & CEREALS
      FoodDatabaseItem(
        id: 'rice_white',
        name: 'White Rice (Cooked)',
        category: 'Grains',
        calories: 130,
        protein: 2.7,
        carbs: 28,
        fat: 0.3,
        unit: 'g',
        servingSize: 150, // 3/4 cup cooked
        tags: ['staple', 'carbs', 'cooked'],
      ),
      FoodDatabaseItem(
        id: 'rice_brown',
        name: 'Brown Rice (Cooked)',
        category: 'Grains',
        calories: 111,
        protein: 2.6,
        carbs: 23,
        fat: 0.9,
        unit: 'g',
        servingSize: 150,
        tags: ['whole grain', 'fiber', 'cooked'],
      ),
      FoodDatabaseItem(
        id: 'oats_rolled',
        name: 'Rolled Oats (Dry)',
        category: 'Grains',
        calories: 389,
        protein: 16.9,
        carbs: 66,
        fat: 6.9,
        unit: 'g',
        servingSize: 40, // 1/2 cup dry
        tags: ['breakfast', 'fiber', 'whole grain'],
      ),
      FoodDatabaseItem(
        id: 'bread_white',
        name: 'White Bread',
        category: 'Grains',
        calories: 265,
        protein: 9,
        carbs: 49,
        fat: 3.2,
        unit: 'g',
        servingSize: 25, // 1 slice
        tags: ['bread', 'processed'],
      ),
      FoodDatabaseItem(
        id: 'pasta_cooked',
        name: 'Pasta (Cooked)',
        category: 'Grains',
        calories: 131,
        protein: 5,
        carbs: 25,
        fat: 1.1,
        unit: 'g',
        servingSize: 100, // about 1 cup
        tags: ['italian', 'carbs', 'cooked'],
      ),

      // PROTEINS
      FoodDatabaseItem(
        id: 'chicken_breast',
        name: 'Chicken Breast (Grilled)',
        category: 'Proteins',
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
        unit: 'g',
        servingSize: 100, // 3.5 oz
        tags: ['lean', 'grilled', 'poultry'],
      ),
      FoodDatabaseItem(
        id: 'salmon_grilled',
        name: 'Salmon (Grilled)',
        category: 'Proteins',
        calories: 206,
        protein: 22,
        carbs: 0,
        fat: 12,
        unit: 'g',
        servingSize: 100,
        tags: ['fish', 'omega-3', 'grilled'],
      ),
      FoodDatabaseItem(
        id: 'beef_lean',
        name: 'Beef (Lean, Cooked)',
        category: 'Proteins',
        calories: 250,
        protein: 26,
        carbs: 0,
        fat: 15,
        unit: 'g',
        servingSize: 100,
        tags: ['red meat', 'iron', 'cooked'],
      ),
      FoodDatabaseItem(
        id: 'egg_whole',
        name: 'Egg (Whole, Large)',
        category: 'Proteins',
        calories: 155,
        protein: 13,
        carbs: 1.1,
        fat: 11,
        unit: 'g',
        servingSize: 50, // 1 large egg
        tags: ['breakfast', 'complete protein'],
      ),
      FoodDatabaseItem(
        id: 'tofu_firm',
        name: 'Tofu (Firm)',
        category: 'Proteins',
        calories: 144,
        protein: 17,
        carbs: 3,
        fat: 9,
        unit: 'g',
        servingSize: 100,
        tags: ['vegetarian', 'soy', 'plant protein'],
      ),

      // DAIRY
      FoodDatabaseItem(
        id: 'milk_whole',
        name: 'Milk (Whole, 3.25%)',
        category: 'Dairy',
        calories: 61,
        protein: 3.2,
        carbs: 4.8,
        fat: 3.3,
        unit: 'ml',
        servingSize: 240, // 1 cup
        tags: ['dairy', 'calcium', 'vitamin d'],
      ),
      FoodDatabaseItem(
        id: 'yogurt_plain',
        name: 'Yogurt (Plain, Low-fat)',
        category: 'Dairy',
        calories: 63,
        protein: 5.2,
        carbs: 7,
        fat: 1.6,
        unit: 'g',
        servingSize: 170, // 3/4 cup
        tags: ['dairy', 'probiotics', 'calcium'],
      ),
      FoodDatabaseItem(
        id: 'cheese_cheddar',
        name: 'Cheddar Cheese',
        category: 'Dairy',
        calories: 403,
        protein: 25,
        carbs: 1.3,
        fat: 33,
        unit: 'g',
        servingSize: 30, // 1 oz
        tags: ['dairy', 'aged', 'calcium'],
      ),

      // NUTS & SEEDS
      FoodDatabaseItem(
        id: 'almonds_raw',
        name: 'Almonds (Raw)',
        category: 'Nuts & Seeds',
        calories: 579,
        protein: 21,
        carbs: 22,
        fat: 50,
        unit: 'g',
        servingSize: 25, // small handful
        tags: ['nuts', 'vitamin e', 'healthy fat'],
      ),
      FoodDatabaseItem(
        id: 'walnuts_raw',
        name: 'Walnuts (Raw)',
        category: 'Nuts & Seeds',
        calories: 654,
        protein: 15,
        carbs: 14,
        fat: 65,
        unit: 'g',
        servingSize: 25,
        tags: ['nuts', 'omega-3', 'brain food'],
      ),

      // SNACKS & TREATS
      FoodDatabaseItem(
        id: 'potato_baked',
        name: 'Baked Potato (with skin)',
        category: 'Vegetables',
        calories: 93,
        protein: 2.5,
        carbs: 21,
        fat: 0.1,
        unit: 'g',
        servingSize: 200, // medium potato
        tags: ['baked', 'potassium', 'fiber'],
      ),
      FoodDatabaseItem(
        id: 'dark_chocolate',
        name: 'Dark Chocolate (70% cacao)',
        category: 'Snacks',
        calories: 598,
        protein: 7.9,
        carbs: 46,
        fat: 43,
        unit: 'g',
        servingSize: 20, // small square
        tags: ['chocolate', 'antioxidants', 'treat'],
      ),

      // BEVERAGES (per 100ml for consistency)
      FoodDatabaseItem(
        id: 'orange_juice',
        name: 'Orange Juice (Fresh)',
        category: 'Beverages',
        calories: 45,
        protein: 0.7,
        carbs: 10.4,
        fat: 0.2,
        unit: 'ml',
        servingSize: 240, // 1 cup
        tags: ['juice', 'vitamin c', 'fresh'],
      ),
    ];
  }
}

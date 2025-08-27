// lib/models/food_item.dart

/// Food item data model
/// Used to record food information added by users, including nutritional components, portions, etc.
class FoodItem {
  final int? id;
  final String name;
  final double calories;
  final double protein; // g
  final double carbs; // g
  final double fat; // g
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final DateTime date;
  final double? quantity; // portion, optional
  final String? unit; // unit like 'g', 'ml', 'serving'
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodItem({
    this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.date,
    this.quantity,
    this.unit,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Create FoodItem instance from Map (for database operations)
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      mealType: map['mealType'] as String,
      date: DateTime.parse(map['date'] as String),
      quantity: (map['quantity'] as num?)?.toDouble(),
      unit: map['unit'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to Map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealType': mealType,
      'date': date.toIso8601String(),
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Create copy with optionally modified properties
  FoodItem copyWith({
    int? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? mealType,
    DateTime? date,
    double? quantity,
    String? unit,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted quantity string
  String get formattedQuantity {
    if (quantity == null || quantity == 0) {
      return '';
    }

    final quantityStr = quantity! % 1 == 0
        ? quantity!.toInt().toString()
        : quantity!.toStringAsFixed(1);

    if (unit != null && unit!.isNotEmpty) {
      return '$quantityStr$unit';
    }

    return quantityStr;
  }

  /// Get formatted calories string
  String get formattedCalories {
    return calories % 1 == 0
        ? calories.toInt().toString()
        : calories.toStringAsFixed(1);
  }

  /// Get formatted protein string
  String get formattedProtein {
    return protein % 1 == 0
        ? protein.toInt().toString()
        : protein.toStringAsFixed(1);
  }

  /// Get formatted carbs string
  String get formattedCarbs {
    return carbs % 1 == 0 ? carbs.toInt().toString() : carbs.toStringAsFixed(1);
  }

  /// Get formatted fat string
  String get formattedFat {
    return fat % 1 == 0 ? fat.toInt().toString() : fat.toStringAsFixed(1);
  }

  /// Get meal type display name
  String get mealTypeDisplayName {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return mealType;
    }
  }

  /// Get formatted date string
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get formatted time string
  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted datetime string
  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  /// Calculate total macro calories
  double get macroCalories {
    return (protein * 4) + (carbs * 4) + (fat * 9);
  }

  /// Check if nutrition data is valid (macros match total calories)
  bool get isNutritionDataValid {
    if (calories == 0) return protein == 0 && carbs == 0 && fat == 0;

    final macroCaloriesValue = macroCalories;
    final difference = (macroCaloriesValue - calories).abs();
    final tolerance = calories * 0.2; // Allow 20% tolerance

    return difference <= tolerance;
  }

  /// Get brief nutrition summary
  String get nutritionSummary {
    final parts = <String>[];

    if (protein > 0) {
      parts.add('Protein ${formattedProtein}g');
    }
    if (carbs > 0) {
      parts.add('Carbs ${formattedCarbs}g');
    }
    if (fat > 0) {
      parts.add('Fat ${formattedFat}g');
    }

    return parts.join(' • ');
  }

  /// Get full food description
  String get fullDescription {
    final parts = <String>[name];

    if (formattedQuantity.isNotEmpty) {
      parts.add('(${formattedQuantity})');
    }

    parts.add('${formattedCalories} kcal');

    if (nutritionSummary.isNotEmpty) {
      parts.add(nutritionSummary);
    }

    return parts.join(' ');
  }

  /// Calculate protein percentage
  double get proteinPercentage {
    if (macroCalories == 0) return 0;
    return (protein * 4) / macroCalories * 100;
  }

  /// Calculate carbs percentage
  double get carbsPercentage {
    if (macroCalories == 0) return 0;
    return (carbs * 4) / macroCalories * 100;
  }

  /// Calculate fat percentage
  double get fatPercentage {
    if (macroCalories == 0) return 0;
    return (fat * 9) / macroCalories * 100;
  }

  /// Adjust food item by quantity
  FoodItem adjustByQuantity(double newQuantity, [String? newUnit]) {
    if (quantity == null || quantity == 0 || newQuantity == 0) {
      return copyWith(quantity: newQuantity, unit: newUnit ?? unit);
    }

    final ratio = newQuantity / quantity!;

    return copyWith(
      calories: calories * ratio,
      protein: protein * ratio,
      carbs: carbs * ratio,
      fat: fat * ratio,
      quantity: newQuantity,
      unit: newUnit ?? unit,
      updatedAt: DateTime.now(),
    );
  }

  /// Merge two food items
  FoodItem merge(FoodItem other, {String? newName}) {
    return FoodItem(
      id: null, // New merged item shouldn't have ID
      name: newName ?? '$name + ${other.name}',
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      mealType: mealType, // Keep first item's meal type
      date: date, // Keep first item's date
      quantity: null, // Merged quantity concept no longer applies
      unit: null,
      notes: notes != null && other.notes != null
          ? '$notes; ${other.notes}'
          : notes ?? other.notes,
      createdAt: DateTime.now(),
    );
  }

  /// Create food template (remove ID and timestamps, for quick adding)
  FoodItem toTemplate({String? templateName}) {
    return FoodItem(
      id: null,
      name: templateName ?? name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      mealType: mealType,
      date: DateTime.now(), // Use current time
      quantity: quantity,
      unit: unit,
      notes: notes,
    );
  }

  /// Validate food data integrity
  List<String> validate() {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Food name cannot be empty');
    }

    if (calories < 0) {
      errors.add('Calories cannot be negative');
    }

    if (protein < 0) {
      errors.add('Protein cannot be negative');
    }

    if (carbs < 0) {
      errors.add('Carbs cannot be negative');
    }

    if (fat < 0) {
      errors.add('Fat cannot be negative');
    }

    if (quantity != null && quantity! < 0) {
      errors.add('Quantity cannot be negative');
    }

    const validMealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    if (!validMealTypes.contains(mealType.toLowerCase())) {
      errors.add('Invalid meal type');
    }

    if (!isNutritionDataValid && calories > 0) {
      errors.add('Nutrition data may be inaccurate');
    }

    return errors;
  }

  /// Compare two food items for equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FoodItem &&
        other.id == id &&
        other.name == name &&
        other.calories == calories &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fat == fat &&
        other.mealType == mealType &&
        other.date == date &&
        other.quantity == quantity &&
        other.unit == unit;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      calories,
      protein,
      carbs,
      fat,
      mealType,
      date,
      quantity,
      unit,
    );
  }

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, calories: $calories, '
        'protein: $protein, carbs: $carbs, fat: $fat, '
        'mealType: $mealType, date: $formattedDate, '
        'quantity: $quantity, unit: $unit)';
  }

  /// Convert to JSON format (for export/import)
  Map<String, dynamic> toJson() {
    return toMap();
  }

  /// Create instance from JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem.fromMap(json);
  }

  /// Create sample food items (for testing)
  static List<FoodItem> createSampleFoods() {
    final now = DateTime.now();

    return [
      FoodItem(
        id: 1,
        name: 'White Rice',
        calories: 130,
        protein: 2.7,
        carbs: 28,
        fat: 0.3,
        mealType: 'lunch',
        date: now,
        quantity: 100,
        unit: 'g',
      ),
      FoodItem(
        id: 2,
        name: 'Chicken Breast',
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
        mealType: 'lunch',
        date: now,
        quantity: 100,
        unit: 'g',
      ),
      FoodItem(
        id: 3,
        name: 'Broccoli',
        calories: 34,
        protein: 2.8,
        carbs: 7,
        fat: 0.4,
        mealType: 'lunch',
        date: now,
        quantity: 100,
        unit: 'g',
      ),
      FoodItem(
        id: 4,
        name: 'Milk',
        calories: 54,
        protein: 3.2,
        carbs: 5,
        fat: 3.2,
        mealType: 'breakfast',
        date: now,
        quantity: 100,
        unit: 'ml',
      ),
      FoodItem(
        id: 5,
        name: 'Banana',
        calories: 89,
        protein: 1.1,
        carbs: 23,
        fat: 0.3,
        mealType: 'snack',
        date: now,
        quantity: 100,
        unit: 'g',
      ),
    ];
  }
}

/// Meal type enumeration
enum MealType {
  breakfast('breakfast', 'Breakfast'),
  lunch('lunch', 'Lunch'),
  dinner('dinner', 'Dinner'),
  snack('snack', 'Snack');

  const MealType(this.value, this.displayName);

  final String value;
  final String displayName;

  static MealType fromValue(String value) {
    return MealType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MealType.snack,
    );
  }

  static List<Map<String, String>> getAllOptions() {
    return MealType.values
        .map((type) => {
              'value': type.value,
              'title': type.displayName,
            })
        .toList();
  }
}

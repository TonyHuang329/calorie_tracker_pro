class FoodItem {
  final int? id;
  final String name;
  final double calories;
  final double protein; // g
  final double carbs; // g
  final double fat; // g
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final DateTime date;
  final double? quantity; // 份量，可选
  final String? unit; // 单位，如 'g', 'ml', '份'

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
  });

  // 将对象转换为Map，用于数据库操作
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealType': mealType,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
    };
  }

  // 从Map创建对象，用于从数据库读取
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      calories: map['calories'] as double,
      protein: map['protein'] as double,
      carbs: map['carbs'] as double,
      fat: map['fat'] as double,
      mealType: map['mealType'] as String,
      date: DateTime.parse(map['date'] as String),
      quantity: map['quantity'] as double?,
      unit: map['unit'] as String?,
    );
  }

  // 创建副本，用于更新对象
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
    );
  }

  @override
  String toString() {
    return 'FoodItem{id: $id, name: $name, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, mealType: $mealType, date: $date, quantity: $quantity, unit: $unit}';
  }

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
    return Object.hash(id, name, calories, protein, carbs, fat, mealType, date,
        quantity, unit);
  }

  // 餐次显示名称
  String get mealTypeDisplayName {
    switch (mealType) {
      case 'breakfast':
        return '早餐';
      case 'lunch':
        return '午餐';
      case 'dinner':
        return '晚餐';
      case 'snack':
        return '零食';
      default:
        return mealType;
    }
  }

  // 总的宏量营养素卡路里
  double get totalMacroCalories {
    return (protein * 4) + (carbs * 4) + (fat * 9);
  }

  // 蛋白质卡路里百分比
  double get proteinPercentage {
    if (totalMacroCalories == 0) return 0;
    return (protein * 4) / totalMacroCalories * 100;
  }

  // 碳水化合物卡路里百分比
  double get carbsPercentage {
    if (totalMacroCalories == 0) return 0;
    return (carbs * 4) / totalMacroCalories * 100;
  }

  // 脂肪卡路里百分比
  double get fatPercentage {
    if (totalMacroCalories == 0) return 0;
    return (fat * 9) / totalMacroCalories * 100;
  }

  // 格式化显示份量
  String get formattedQuantity {
    if (quantity == null) return '';
    if (unit == null) return quantity!.toStringAsFixed(0);
    return '${quantity!.toStringAsFixed(0)}$unit';
  }
}

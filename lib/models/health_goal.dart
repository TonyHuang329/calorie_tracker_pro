// lib/models/health_goal.dart

/// Health goal data model
/// Stores user's nutrition targets and goal settings
class HealthGoal {
  final int? id;
  final double targetCalories;
  final double targetProtein; // g
  final double targetCarbs; // g
  final double targetFat; // g
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? goalType; // 'maintain', 'lose', 'gain', 'custom'
  final String? notes; // User notes
  final bool isActive; // Whether this goal is currently active

  const HealthGoal({
    this.id,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.createdAt,
    this.updatedAt,
    this.goalType,
    this.notes,
    this.isActive = true,
  });

  /// Convert object to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (goalType != null) 'goalType': goalType,
      if (notes != null) 'notes': notes,
      'isActive': isActive ? 1 : 0,
    };
  }

  /// Create object from Map for database reading
  factory HealthGoal.fromMap(Map<String, dynamic> map) {
    return HealthGoal(
      id: map['id'] as int?,
      targetCalories: (map['targetCalories'] as num).toDouble(),
      targetProtein: (map['targetProtein'] as num).toDouble(),
      targetCarbs: (map['targetCarbs'] as num).toDouble(),
      targetFat: (map['targetFat'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      goalType: map['goalType'] as String?,
      notes: map['notes'] as String?,
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
  }

  /// Create copy for updating object
  HealthGoal copyWith({
    int? id,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? goalType,
    String? notes,
    bool? isActive,
  }) {
    return HealthGoal(
      id: id ?? this.id,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      goalType: goalType ?? this.goalType,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'HealthGoal{id: $id, targetCalories: $targetCalories, '
        'targetProtein: $targetProtein, targetCarbs: $targetCarbs, '
        'targetFat: $targetFat, goalType: $goalType, '
        'isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthGoal &&
        other.id == id &&
        other.targetCalories == targetCalories &&
        other.targetProtein == targetProtein &&
        other.targetCarbs == targetCarbs &&
        other.targetFat == targetFat &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.goalType == goalType &&
        other.notes == notes &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      targetCalories,
      targetProtein,
      targetCarbs,
      targetFat,
      createdAt,
      updatedAt,
      goalType,
      notes,
      isActive,
    );
  }

  /// Goal type display name
  String get goalTypeDisplayName {
    switch (goalType?.toLowerCase()) {
      case 'maintain':
        return 'Maintain Weight';
      case 'lose':
        return 'Lose Weight';
      case 'gain':
        return 'Gain Weight';
      case 'custom':
        return 'Custom Goal';
      default:
        return goalType ?? 'Not Set';
    }
  }

  /// Total target macro calories
  double get totalMacroCalories {
    return (targetProtein * 4) + (targetCarbs * 4) + (targetFat * 9);
  }

  /// Protein calories percentage
  double get proteinPercentage {
    if (totalMacroCalories == 0) return 0;
    return (targetProtein * 4) / totalMacroCalories * 100;
  }

  /// Carbs calories percentage
  double get carbsPercentage {
    if (totalMacroCalories == 0) return 0;
    return (targetCarbs * 4) / totalMacroCalories * 100;
  }

  /// Fat calories percentage
  double get fatPercentage {
    if (totalMacroCalories == 0) return 0;
    return (targetFat * 9) / totalMacroCalories * 100;
  }

  /// Get formatted target calories string
  String get formattedTargetCalories {
    return targetCalories % 1 == 0
        ? targetCalories.toInt().toString()
        : targetCalories.toStringAsFixed(1);
  }

  /// Get formatted target protein string
  String get formattedTargetProtein {
    return targetProtein % 1 == 0
        ? targetProtein.toInt().toString()
        : targetProtein.toStringAsFixed(1);
  }

  /// Get formatted target carbs string
  String get formattedTargetCarbs {
    return targetCarbs % 1 == 0
        ? targetCarbs.toInt().toString()
        : targetCarbs.toStringAsFixed(1);
  }

  /// Get formatted target fat string
  String get formattedTargetFat {
    return targetFat % 1 == 0
        ? targetFat.toInt().toString()
        : targetFat.toStringAsFixed(1);
  }

  /// Validate if goal is reasonable
  bool get isValid {
    return targetCalories > 0 &&
        targetProtein >= 0 &&
        targetCarbs >= 0 &&
        targetFat >= 0 &&
        targetCalories >= 800 && // Minimum safe calorie intake
        targetCalories <= 5000; // Maximum reasonable calorie intake
  }

  /// Check if macro distribution is reasonable
  bool get isMacroDistributionValid {
    if (!isValid) return false;

    final macroCalories = totalMacroCalories;
    final difference = (macroCalories - targetCalories).abs();
    final tolerance = targetCalories * 0.15; // Allow 15% tolerance

    return difference <= tolerance;
  }

  /// Get macro distribution description
  String get macroDistributionDescription {
    return 'Protein: ${proteinPercentage.toStringAsFixed(0)}%, '
        'Carbs: ${carbsPercentage.toStringAsFixed(0)}%, '
        'Fat: ${fatPercentage.toStringAsFixed(0)}%';
  }

  /// Calculate calorie difference percentage with given actual calories
  double calculateCalorieDifference(double actualCalories) {
    if (targetCalories == 0) return 0;
    return ((actualCalories - targetCalories) / targetCalories) * 100;
  }

  /// Calculate progress percentage for a given actual value against target
  double calculateProgress(double actualValue, double targetValue) {
    if (targetValue == 0) return 0;
    return (actualValue / targetValue * 100).clamp(0, 200); // Max 200%
  }

  /// Get calorie deficit/surplus per day for weight goals
  double get dailyCalorieAdjustment {
    switch (goalType?.toLowerCase()) {
      case 'lose':
        return -500; // 500 calorie deficit for ~1 lb/week loss
      case 'gain':
        return 500; // 500 calorie surplus for ~1 lb/week gain
      case 'maintain':
      default:
        return 0; // No adjustment for maintenance
    }
  }

  /// Estimate weekly weight change based on calorie adjustment
  double get estimatedWeeklyWeightChange {
    const caloriesPerPound = 3500; // Approximately 3500 calories = 1 lb
    final weeklyCalorieChange = dailyCalorieAdjustment * 7;
    return weeklyCalorieChange / caloriesPerPound;
  }

  /// Get goal duration description
  String get goalDurationDescription {
    if (updatedAt != null) {
      final duration = updatedAt!.difference(createdAt).inDays;
      if (duration < 7) {
        return '$duration day${duration == 1 ? '' : 's'}';
      } else if (duration < 30) {
        final weeks = (duration / 7).round();
        return '$weeks week${weeks == 1 ? '' : 's'}';
      } else {
        final months = (duration / 30).round();
        return '$months month${months == 1 ? '' : 's'}';
      }
    } else {
      final duration = DateTime.now().difference(createdAt).inDays;
      return 'Active for $duration day${duration == 1 ? '' : 's'}';
    }
  }

  /// Validate health goal data
  List<String> validate() {
    final errors = <String>[];

    if (targetCalories < 800) {
      errors.add('Target calories should be at least 800 for safety');
    }

    if (targetCalories > 5000) {
      errors.add('Target calories should not exceed 5000');
    }

    if (targetProtein < 0) {
      errors.add('Target protein cannot be negative');
    }

    if (targetCarbs < 0) {
      errors.add('Target carbs cannot be negative');
    }

    if (targetFat < 0) {
      errors.add('Target fat cannot be negative');
    }

    if (targetProtein > 300) {
      errors.add('Target protein seems unusually high (>300g)');
    }

    if (targetCarbs > 600) {
      errors.add('Target carbs seems unusually high (>600g)');
    }

    if (targetFat > 250) {
      errors.add('Target fat seems unusually high (>250g)');
    }

    if (!isMacroDistributionValid) {
      errors.add('Macro nutrients don\'t match total calories');
    }

    // Check for reasonable macro ratios
    if (proteinPercentage < 10) {
      errors.add('Protein percentage is quite low (<10%)');
    }

    if (proteinPercentage > 40) {
      errors.add('Protein percentage is quite high (>40%)');
    }

    if (fatPercentage < 15) {
      errors.add('Fat percentage is quite low (<15%)');
    }

    if (fatPercentage > 45) {
      errors.add('Fat percentage is quite high (>45%)');
    }

    return errors;
  }

  /// Create default goal based on TDEE
  factory HealthGoal.createDefault({
    required double tdee,
    String goalType = 'maintain',
    List<double>? macroRatio,
  }) {
    double targetCalories = tdee;

    // Adjust calories based on goal type
    switch (goalType.toLowerCase()) {
      case 'lose':
        targetCalories = tdee - 500; // 500 calorie deficit per day
        break;
      case 'gain':
        targetCalories = tdee + 500; // 500 calorie surplus per day
        break;
      case 'maintain':
      default:
        targetCalories = tdee;
        break;
    }

    // Ensure minimum safe calories
    targetCalories = targetCalories.clamp(1200, 5000);

    // Default macro distribution or use provided ratio
    final ratio = macroRatio ?? _getDefaultMacroRatio(goalType);

    final targetProtein =
        (targetCalories * ratio[0] / 100) / 4; // Protein: 4 cal/g
    final targetCarbs = (targetCalories * ratio[1] / 100) / 4; // Carbs: 4 cal/g
    final targetFat = (targetCalories * ratio[2] / 100) / 9; // Fat: 9 cal/g

    return HealthGoal(
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      createdAt: DateTime.now(),
      goalType: goalType,
    );
  }

  /// Get default macro ratio based on goal type
  static List<double> _getDefaultMacroRatio(String goalType) {
    switch (goalType.toLowerCase()) {
      case 'lose':
        return [30, 40, 30]; // Higher protein for weight loss
      case 'gain':
        return [25, 45, 30]; // Higher carbs for weight gain
      case 'maintain':
      default:
        return [25, 45, 30]; // Balanced distribution
    }
  }

  /// Get all valid goal type options
  static List<Map<String, String>> getGoalTypeOptions() {
    return [
      {
        'value': 'maintain',
        'title': 'Maintain Weight',
        'subtitle': 'Keep current weight with balanced nutrition',
      },
      {
        'value': 'lose',
        'title': 'Lose Weight',
        'subtitle': 'Moderate calorie deficit for healthy weight loss',
      },
      {
        'value': 'gain',
        'title': 'Gain Weight',
        'subtitle': 'Moderate calorie surplus for healthy weight gain',
      },
      {
        'value': 'custom',
        'title': 'Custom Goal',
        'subtitle': 'Set your own specific nutrition targets',
      },
    ];
  }

  /// Create sample health goal (for testing)
  static HealthGoal createSample({double tdee = 2000}) {
    return HealthGoal.createDefault(
      tdee: tdee,
      goalType: 'maintain',
    );
  }

  /// Get recommended macro ranges for different goals
  static Map<String, Map<String, List<double>>> getMacroRecommendations() {
    return {
      'lose': {
        'protein': [25, 35], // 25-35% of calories
        'carbs': [35, 45], // 35-45% of calories
        'fat': [25, 35], // 25-35% of calories
      },
      'gain': {
        'protein': [20, 30], // 20-30% of calories
        'carbs': [40, 50], // 40-50% of calories
        'fat': [25, 35], // 25-35% of calories
      },
      'maintain': {
        'protein': [20, 30], // 20-30% of calories
        'carbs': [40, 50], // 40-50% of calories
        'fat': [25, 35], // 25-35% of calories
      },
    };
  }

  /// Check if current macro distribution matches recommendations
  bool isWithinRecommendedRanges() {
    final recommendations = getMacroRecommendations();
    final goalRecs = recommendations[goalType?.toLowerCase()] ??
        recommendations['maintain']!;

    final proteinRange = goalRecs['protein']!;
    final carbsRange = goalRecs['carbs']!;
    final fatRange = goalRecs['fat']!;

    return proteinPercentage >= proteinRange[0] &&
        proteinPercentage <= proteinRange[1] &&
        carbsPercentage >= carbsRange[0] &&
        carbsPercentage <= carbsRange[1] &&
        fatPercentage >= fatRange[0] &&
        fatPercentage <= fatRange[1];
  }

  /// Convert to JSON format (for export/import)
  Map<String, dynamic> toJson() {
    return toMap();
  }

  /// Create instance from JSON
  factory HealthGoal.fromJson(Map<String, dynamic> json) {
    return HealthGoal.fromMap(json);
  }
}

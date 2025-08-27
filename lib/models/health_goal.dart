class HealthGoal {
  final int? id;
  final double targetCalories;
  final double targetProtein; // g
  final double targetCarbs; // g
  final double targetFat; // g
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? goalType; // 'maintain', 'lose', 'gain'
  final String? notes; // 用户备注

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
  });

  // 将对象转换为Map，用于数据库操作
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'goalType': goalType,
      'notes': notes,
    };
  }

  // 从Map创建对象，用于从数据库读取
  factory HealthGoal.fromMap(Map<String, dynamic> map) {
    return HealthGoal(
      id: map['id'] as int?,
      targetCalories: map['targetCalories'] as double,
      targetProtein: map['targetProtein'] as double,
      targetCarbs: map['targetCarbs'] as double,
      targetFat: map['targetFat'] as double,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      goalType: map['goalType'] as String?,
      notes: map['notes'] as String?,
    );
  }

  // 创建副本，用于更新对象
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
    );
  }

  @override
  String toString() {
    return 'HealthGoal{id: $id, targetCalories: $targetCalories, targetProtein: $targetProtein, targetCarbs: $targetCarbs, targetFat: $targetFat, createdAt: $createdAt, updatedAt: $updatedAt, goalType: $goalType, notes: $notes}';
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
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(id, targetCalories, targetProtein, targetCarbs,
        targetFat, createdAt, updatedAt, goalType, notes);
  }

  // 目标类型显示名称
  String get goalTypeDisplayName {
    switch (goalType) {
      case 'maintain':
        return '维持体重';
      case 'lose':
        return '减重';
      case 'gain':
        return '增重';
      default:
        return goalType ?? '未设定';
    }
  }

  // 总的目标宏量营养素卡路里
  double get totalMacroCalories {
    return (targetProtein * 4) + (targetCarbs * 4) + (targetFat * 9);
  }

  // 蛋白质卡路里百分比
  double get proteinPercentage {
    if (totalMacroCalories == 0) return 0;
    return (targetProtein * 4) / totalMacroCalories * 100;
  }

  // 碳水化合物卡路里百分比
  double get carbsPercentage {
    if (totalMacroCalories == 0) return 0;
    return (targetCarbs * 4) / totalMacroCalories * 100;
  }

  // 脂肪卡路里百分比
  double get fatPercentage {
    if (totalMacroCalories == 0) return 0;
    return (targetFat * 9) / totalMacroCalories * 100;
  }

  // 验证目标是否合理
  bool get isValid {
    return targetCalories > 0 &&
        targetProtein >= 0 &&
        targetCarbs >= 0 &&
        targetFat >= 0;
  }

  // 计算与给定卡路里的差异百分比
  double calculateCalorieDifference(double actualCalories) {
    if (targetCalories == 0) return 0;
    return ((actualCalories - targetCalories) / targetCalories) * 100;
  }

  // 创建默认目标（基于TDEE）
  factory HealthGoal.createDefault({
    required double tdee,
    String goalType = 'maintain',
  }) {
    double targetCalories = tdee;

    // 根据目标类型调整卡路里
    switch (goalType) {
      case 'lose':
        targetCalories = tdee - 500; // 每天减少500卡路里
        break;
      case 'gain':
        targetCalories = tdee + 500; // 每天增加500卡路里
        break;
    }

    // 默认宏量营养素分配：30% 蛋白质，40% 碳水，30% 脂肪
    final targetProtein = (targetCalories * 0.30) / 4; // 蛋白质每克4卡路里
    final targetCarbs = (targetCalories * 0.40) / 4; // 碳水每克4卡路里
    final targetFat = (targetCalories * 0.30) / 9; // 脂肪每克9卡路里

    return HealthGoal(
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      createdAt: DateTime.now(),
      goalType: goalType,
    );
  }
}

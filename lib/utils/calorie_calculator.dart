import '../models/user_profile.dart';
import '../models/health_goal.dart';

/// 卡路里和营养计算工具类
class CalorieCalculator {
  // 私有构造函数，防止实例化
  CalorieCalculator._();

  /// 活动水平系数映射
  static const Map<String, double> _activityLevelMultipliers = {
    'sedentary': 1.2, // 久坐：很少或没有运动
    'light': 1.375, // 轻度活跃：轻度运动或工作 1-3 天/周
    'moderate': 1.55, // 中度活跃：中度运动或工作 3-5 天/周
    'active': 1.725, // 活跃：重度运动或工作 6-7 天/周
    'very_active': 1.9, // 非常活跃：非常重度的体力工作或每日运动
  };

  /// 使用 Mifflin-St Jeor 方程计算基础代谢率 (BMR)
  ///
  /// 公式：
  /// 男性: BMR = (10 × 体重kg) + (6.25 × 身高cm) - (5 × 年龄) + 5
  /// 女性: BMR = (10 × 体重kg) + (6.25 × 身高cm) - (5 × 年龄) - 161
  static double calculateBMR(UserProfile profile) {
    if (profile.weight <= 0 || profile.height <= 0 || profile.age <= 0) {
      throw ArgumentError('用户信息中的体重、身高和年龄必须大于0');
    }

    final double baseCalculation =
        (10 * profile.weight) + (6.25 * profile.height) - (5 * profile.age);

    switch (profile.gender.toLowerCase()) {
      case 'male':
        return baseCalculation + 5;
      case 'female':
        return baseCalculation - 161;
      default:
        throw ArgumentError('性别必须是 "male" 或 "female"');
    }
  }

  /// 计算总日常能量消耗 (TDEE)
  /// TDEE = BMR × 活动水平系数
  static double calculateTDEE(UserProfile profile) {
    final double bmr = calculateBMR(profile);
    final double activityMultiplier =
        _activityLevelMultipliers[profile.activityLevel] ?? 1.2;

    return bmr * activityMultiplier;
  }

  /// 根据目标类型计算目标卡路里
  ///
  /// [goalType]: 'maintain' (维持), 'lose' (减重), 'gain' (增重)
  /// [weeklyWeightChange]: 每周体重变化目标 (kg)，正数为增重，负数为减重
  static double calculateTargetCalories(
    UserProfile profile, {
    String goalType = 'maintain',
    double weeklyWeightChange = 0.0,
  }) {
    final double tdee = calculateTDEE(profile);

    // 1kg脂肪约等于7700卡路里
    const double caloriesPerKg = 7700;

    switch (goalType.toLowerCase()) {
      case 'maintain':
        return tdee;
      case 'lose':
        // 健康减重：每周0.5-1kg，对应每日赤字250-500卡路里
        final double dailyDeficit =
            weeklyWeightChange.abs() * caloriesPerKg / 7;
        return (tdee - dailyDeficit).clamp(1200, tdee); // 最低不少于1200卡路里
      case 'gain':
        // 健康增重：每周0.25-0.5kg，对应每日盈余250-500卡路里
        final double dailySurplus = weeklyWeightChange * caloriesPerKg / 7;
        return tdee + dailySurplus;
      default:
        throw ArgumentError('无效的目标类型: $goalType');
    }
  }

  /// 计算推荐的宏量营养素分配
  ///
  /// 返回格式: {'protein': g, 'carbs': g, 'fat': g}
  /// [macroRatio]: 宏量营养素比例 [蛋白质%, 碳水%, 脂肪%]
  static Map<String, double> calculateMacronutrients(
    double targetCalories, {
    List<double> macroRatio = const [25, 45, 30], // 默认: 25% 蛋白质, 45% 碳水, 30% 脂肪
  }) {
    if (macroRatio.length != 3) {
      throw ArgumentError('宏量营养素比例必须包含3个值: [蛋白质%, 碳水%, 脂肪%]');
    }

    final double totalRatio = macroRatio.fold(0, (sum, ratio) => sum + ratio);
    if ((totalRatio - 100).abs() > 0.01) {
      throw ArgumentError('宏量营养素比例总和必须等于100%');
    }

    return {
      'protein': (targetCalories * macroRatio[0] / 100) / 4, // 蛋白质: 4卡路里/克
      'carbs': (targetCalories * macroRatio[1] / 100) / 4, // 碳水: 4卡路里/克
      'fat': (targetCalories * macroRatio[2] / 100) / 9, // 脂肪: 9卡路里/克
    };
  }

  /// 基于用户档案创建健康目标
  static HealthGoal createHealthGoalForUser(
    UserProfile profile, {
    String goalType = 'maintain',
    double weeklyWeightChange = 0.0,
    List<double>? customMacroRatio,
  }) {
    final double targetCalories = calculateTargetCalories(
      profile,
      goalType: goalType,
      weeklyWeightChange: weeklyWeightChange,
    );

    final Map<String, double> macros = calculateMacronutrients(
      targetCalories,
      macroRatio: customMacroRatio ?? _getDefaultMacroRatio(goalType),
    );

    return HealthGoal(
      targetCalories: targetCalories,
      targetProtein: macros['protein']!,
      targetCarbs: macros['carbs']!,
      targetFat: macros['fat']!,
      createdAt: DateTime.now(),
      goalType: goalType,
    );
  }

  /// 根据目标类型获取默认宏量营养素比例
  static List<double> _getDefaultMacroRatio(String goalType) {
    switch (goalType.toLowerCase()) {
      case 'lose':
        return [30, 40, 30]; // 减重: 高蛋白，中碳水，中脂肪
      case 'gain':
        return [25, 45, 30]; // 增重: 中蛋白，高碳水，中脂肪
      case 'maintain':
      default:
        return [25, 45, 30]; // 维持: 均衡分配
    }
  }

  /// 计算理想体重范围 (BMI 18.5-24.9)
  static Map<String, double> calculateIdealWeightRange(double height) {
    if (height <= 0) {
      throw ArgumentError('身高必须大于0');
    }

    // 将身高从厘米转换为米
    final double heightInMeters = height / 100;

    return {
      'min': 18.5 * heightInMeters * heightInMeters,
      'max': 24.9 * heightInMeters * heightInMeters,
    };
  }

  /// 计算BMI
  static double calculateBMI(double weight, double height) {
    if (weight <= 0 || height <= 0) {
      throw ArgumentError('体重和身高必须大于0');
    }

    final double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// 获取BMI分类
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return '体重过轻';
    } else if (bmi < 25) {
      return '正常体重';
    } else if (bmi < 30) {
      return '超重';
    } else {
      return '肥胖';
    }
  }

  /// 计算目标完成百分比
  static double calculateGoalProgress(double actual, double target) {
    if (target <= 0) return 0;
    return (actual / target * 100).clamp(0, 200); // 最高200%
  }

  /// 计算剩余卡路里
  static double calculateRemainingCalories(double consumed, double target) {
    return target - consumed;
  }

  /// 计算一段时间内的平均每日摄入
  static Map<String, double> calculateAverageIntake(
      List<Map<String, double>> dailyIntakes) {
    if (dailyIntakes.isEmpty) {
      return {
        'avgCalories': 0.0,
        'avgProtein': 0.0,
        'avgCarbs': 0.0,
        'avgFat': 0.0,
      };
    }

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var intake in dailyIntakes) {
      totalCalories += intake['totalCalories'] ?? 0;
      totalProtein += intake['totalProtein'] ?? 0;
      totalCarbs += intake['totalCarbs'] ?? 0;
      totalFat += intake['totalFat'] ?? 0;
    }

    final int days = dailyIntakes.length;

    return {
      'avgCalories': totalCalories / days,
      'avgProtein': totalProtein / days,
      'avgCarbs': totalCarbs / days,
      'avgFat': totalFat / days,
    };
  }

  /// 计算达到目标体重所需的时间（天）
  static int calculateTimeToGoal({
    required double currentWeight,
    required double targetWeight,
    required double dailyCalorieDeficitOrSurplus,
  }) {
    if (dailyCalorieDeficitOrSurplus == 0) return -1; // 无法达到目标

    const double caloriesPerKg = 7700;
    final double weightDifference = (targetWeight - currentWeight).abs();
    final double totalCaloriesNeeded = weightDifference * caloriesPerKg;

    return (totalCaloriesNeeded / dailyCalorieDeficitOrSurplus.abs()).ceil();
  }

  /// 验证营养数据的合理性
  static bool validateNutritionData({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    // 检查负值
    if (calories < 0 || protein < 0 || carbs < 0 || fat < 0) {
      return false;
    }

    // 计算宏量营养素总卡路里
    final double macroCalories = (protein * 4) + (carbs * 4) + (fat * 9);

    // 允许±20%的误差范围（考虑到纤维、酒精等其他成分）
    final double tolerance = calories * 0.2;

    return (macroCalories - calories).abs() <= tolerance;
  }

  /// 格式化卡路里显示
  static String formatCalories(double calories) {
    return calories.round().toString();
  }

  /// 格式化宏量营养素显示
  static String formatMacro(double grams, {int decimals = 1}) {
    return grams.toStringAsFixed(decimals);
  }

  /// 格式化百分比显示
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }
}

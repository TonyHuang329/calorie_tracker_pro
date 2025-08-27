// lib/utils/calorie_calculator.dart

import '../models/user_profile.dart';
import '../models/health_goal.dart';

/// Calorie and nutrition calculation utility class
class CalorieCalculator {
  // Private constructor to prevent instantiation
  CalorieCalculator._();

  /// Activity level multiplier mapping
  static const Map<String, double> _activityLevelMultipliers = {
    'sedentary': 1.2, // Sedentary: little or no exercise
    'light': 1.375, // Light activity: light exercise or sports 1-3 days/week
    'moderate':
        1.55, // Moderate activity: moderate exercise or sports 3-5 days/week
    'active': 1.725, // Active: heavy exercise or sports 6-7 days/week
    'very_active':
        1.9, // Very active: very heavy physical work or daily exercise
  };

  /// Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor equation
  ///
  /// Formula:
  /// Male: BMR = (10 × weight kg) + (6.25 × height cm) - (5 × age) + 5
  /// Female: BMR = (10 × weight kg) + (6.25 × height cm) - (5 × age) - 161
  static double calculateBMR(UserProfile profile) {
    if (profile.weight <= 0 || profile.height <= 0 || profile.age <= 0) {
      throw ArgumentError(
          'Weight, height and age must be greater than 0 in user profile');
    }

    final double baseCalculation =
        (10 * profile.weight) + (6.25 * profile.height) - (5 * profile.age);

    switch (profile.gender.toLowerCase()) {
      case 'male':
        return baseCalculation + 5;
      case 'female':
        return baseCalculation - 161;
      default:
        throw ArgumentError('Gender must be "male" or "female"');
    }
  }

  /// Calculate Total Daily Energy Expenditure (TDEE)
  /// TDEE = BMR × activity level multiplier
  static double calculateTDEE(UserProfile profile) {
    final double bmr = calculateBMR(profile);
    final double activityMultiplier =
        _activityLevelMultipliers[profile.activityLevel] ?? 1.2;

    return bmr * activityMultiplier;
  }

  /// Calculate target calories based on goal type
  ///
  /// [goalType]: 'maintain' (maintain), 'lose' (lose weight), 'gain' (gain weight)
  /// [weeklyWeightChange]: weekly weight change goal (kg), positive for gain, negative for loss
  static double calculateTargetCalories(
    UserProfile profile, {
    String goalType = 'maintain',
    double weeklyWeightChange = 0.0,
  }) {
    final double tdee = calculateTDEE(profile);

    // 1kg fat approximately equals 7700 calories
    const double caloriesPerKg = 7700;

    switch (goalType.toLowerCase()) {
      case 'maintain':
        return tdee;
      case 'lose':
        // Healthy weight loss: 0.5-1kg per week, corresponding to 250-500 calorie deficit per day
        final double dailyDeficit =
            weeklyWeightChange.abs() * caloriesPerKg / 7;
        return (tdee - dailyDeficit)
            .clamp(1200, tdee); // Minimum not less than 1200 calories
      case 'gain':
        // Healthy weight gain: 0.25-0.5kg per week, corresponding to 250-500 calorie surplus per day
        final double dailySurplus = weeklyWeightChange * caloriesPerKg / 7;
        return tdee + dailySurplus;
      default:
        throw ArgumentError('Invalid goal type: $goalType');
    }
  }

  /// Calculate recommended macronutrient distribution
  ///
  /// Returns format: {'protein': g, 'carbs': g, 'fat': g}
  /// [macroRatio]: macronutrient ratio [protein%, carbs%, fat%]
  static Map<String, double> calculateMacronutrients(
    double targetCalories, {
    List<double> macroRatio = const [
      25,
      45,
      30
    ], // Default: 25% protein, 45% carbs, 30% fat
  }) {
    if (macroRatio.length != 3) {
      throw ArgumentError(
          'Macro ratio must contain 3 values: [protein%, carbs%, fat%]');
    }

    final double totalRatio = macroRatio.fold(0, (sum, ratio) => sum + ratio);
    if ((totalRatio - 100).abs() > 0.01) {
      throw ArgumentError('Macro ratio total must equal 100%');
    }

    return {
      'protein': (targetCalories * macroRatio[0] / 100) /
          4, // Protein: 4 calories/gram
      'carbs':
          (targetCalories * macroRatio[1] / 100) / 4, // Carbs: 4 calories/gram
      'fat': (targetCalories * macroRatio[2] / 100) / 9, // Fat: 9 calories/gram
    };
  }

  /// Create health goal based on user profile
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

  /// Get default macronutrient ratio based on goal type
  static List<double> _getDefaultMacroRatio(String goalType) {
    switch (goalType.toLowerCase()) {
      case 'lose':
        return [
          30,
          40,
          30
        ]; // Weight loss: high protein, moderate carbs, moderate fat
      case 'gain':
        return [
          25,
          45,
          30
        ]; // Weight gain: moderate protein, high carbs, moderate fat
      case 'maintain':
      default:
        return [25, 45, 30]; // Maintenance: balanced distribution
    }
  }

  /// Calculate ideal weight range (BMI 18.5-24.9)
  static Map<String, double> calculateIdealWeightRange(double height) {
    if (height <= 0) {
      throw ArgumentError('Height must be greater than 0');
    }

    // Convert height from centimeters to meters
    final double heightInMeters = height / 100;

    return {
      'min': 18.5 * heightInMeters * heightInMeters,
      'max': 24.9 * heightInMeters * heightInMeters,
    };
  }

  /// Calculate BMI
  static double calculateBMI(double weight, double height) {
    if (weight <= 0 || height <= 0) {
      throw ArgumentError('Weight and height must be greater than 0');
    }

    final double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Get BMI status for color coding
  static String getBMIStatus(double bmi) {
    if (bmi < 18.5) {
      return 'low';
    } else if (bmi < 25) {
      return 'normal';
    } else if (bmi < 30) {
      return 'high';
    } else {
      return 'very_high';
    }
  }

  /// Calculate goal completion percentage
  static double calculateGoalProgress(double actual, double target) {
    if (target <= 0) return 0;
    return (actual / target * 100).clamp(0, 200); // Maximum 200%
  }

  /// Calculate remaining calories
  static double calculateRemainingCalories(double consumed, double target) {
    return target - consumed;
  }

  /// Calculate average daily intake over a period
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

  /// Calculate time needed to reach target weight (days)
  static int calculateTimeToGoal({
    required double currentWeight,
    required double targetWeight,
    required double dailyCalorieDeficitOrSurplus,
  }) {
    if (dailyCalorieDeficitOrSurplus == 0) return -1; // Cannot reach goal

    const double caloriesPerKg = 7700;
    final double weightDifference = (targetWeight - currentWeight).abs();
    final double totalCaloriesNeeded = weightDifference * caloriesPerKg;

    return (totalCaloriesNeeded / dailyCalorieDeficitOrSurplus.abs()).ceil();
  }

  /// Calculate estimated weight change based on calorie deficit/surplus
  static double calculateWeightChange({
    required double dailyCalorieChange,
    required int days,
  }) {
    const double caloriesPerKg = 7700;
    final double totalCalorieChange = dailyCalorieChange * days;
    return totalCalorieChange / caloriesPerKg;
  }

  /// Validate nutrition data reasonableness
  static bool validateNutritionData({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    // Check for negative values
    if (calories < 0 || protein < 0 || carbs < 0 || fat < 0) {
      return false;
    }

    // Calculate total macro calories
    final double macroCalories = (protein * 4) + (carbs * 4) + (fat * 9);

    // Allow ±20% tolerance (considering fiber, alcohol and other components)
    final double tolerance = calories * 0.2;

    return (macroCalories - calories).abs() <= tolerance;
  }

  /// Calculate protein requirements based on activity level and goals
  static double calculateProteinRequirement(UserProfile profile,
      {String goalType = 'maintain'}) {
    final double weightInKg = profile.weight;

    // Base protein requirement (g/kg body weight)
    double proteinPerKg;

    switch (goalType.toLowerCase()) {
      case 'lose':
        // Higher protein for weight loss to preserve muscle mass
        switch (profile.activityLevel) {
          case 'sedentary':
            proteinPerKg = 1.6;
            break;
          case 'light':
            proteinPerKg = 1.8;
            break;
          case 'moderate':
          case 'active':
          case 'very_active':
            proteinPerKg = 2.0;
            break;
          default:
            proteinPerKg = 1.6;
        }
        break;
      case 'gain':
        // Moderate protein for weight gain
        switch (profile.activityLevel) {
          case 'sedentary':
          case 'light':
            proteinPerKg = 1.4;
            break;
          case 'moderate':
            proteinPerKg = 1.6;
            break;
          case 'active':
          case 'very_active':
            proteinPerKg = 1.8;
            break;
          default:
            proteinPerKg = 1.4;
        }
        break;
      case 'maintain':
      default:
        // Standard protein for maintenance
        switch (profile.activityLevel) {
          case 'sedentary':
            proteinPerKg = 1.2;
            break;
          case 'light':
            proteinPerKg = 1.4;
            break;
          case 'moderate':
            proteinPerKg = 1.6;
            break;
          case 'active':
          case 'very_active':
            proteinPerKg = 1.8;
            break;
          default:
            proteinPerKg = 1.2;
        }
    }

    return weightInKg * proteinPerKg;
  }

  /// Calculate water intake recommendation (liters per day)
  static double calculateWaterIntake(UserProfile profile,
      {double additionalForExercise = 0.0}) {
    final double weightInKg = profile.weight;

    // Base water requirement: 35ml per kg body weight
    double baseWaterLiters = (weightInKg * 35) / 1000;

    // Activity level adjustment
    double activityAdjustment = 0.0;
    switch (profile.activityLevel) {
      case 'light':
        activityAdjustment = 0.3;
        break;
      case 'moderate':
        activityAdjustment = 0.5;
        break;
      case 'active':
        activityAdjustment = 0.7;
        break;
      case 'very_active':
        activityAdjustment = 1.0;
        break;
      default:
        activityAdjustment = 0.0;
    }

    return baseWaterLiters + activityAdjustment + additionalForExercise;
  }

  /// Get health recommendations based on profile and goals
  static List<String> getHealthRecommendations(UserProfile profile,
      {HealthGoal? goal}) {
    final recommendations = <String>[];
    final bmi = calculateBMI(profile.weight, profile.height);

    // BMI-based recommendations
    if (bmi < 18.5) {
      recommendations
          .add('Consider gaining weight through healthy diet and exercise');
      recommendations.add('Increase protein and healthy fat intake');
    } else if (bmi > 25) {
      recommendations
          .add('Consider weight management through balanced diet and exercise');
      recommendations
          .add('Focus on portion control and regular physical activity');
    } else {
      recommendations.add('Maintain your current healthy weight range');
    }

    // Age-based recommendations
    if (profile.age >= 50) {
      recommendations.add('Consider increasing calcium and vitamin D intake');
      recommendations.add('Include low-impact exercises and strength training');
    } else if (profile.age <= 25) {
      recommendations.add('Great time to establish healthy eating habits');
      recommendations
          .add('Vary your exercise routine to build overall fitness');
    }

    // Activity level recommendations
    if (profile.activityLevel == 'sedentary') {
      recommendations.add('Try to increase daily physical activity');
      recommendations.add('Start with 30 minutes of walking daily');
    } else if (profile.activityLevel == 'very_active') {
      recommendations.add('Ensure adequate recovery time between workouts');
      recommendations
          .add('Focus on proper nutrition to support high activity levels');
    }

    // Goal-specific recommendations
    if (goal != null) {
      switch (goal.goalType?.toLowerCase()) {
        case 'lose':
          recommendations.add(
              'Create a moderate calorie deficit for sustainable weight loss');
          recommendations
              .add('Focus on protein-rich foods to preserve muscle mass');
          break;
        case 'gain':
          recommendations
              .add('Eat in a controlled calorie surplus with quality foods');
          recommendations
              .add('Include strength training to build lean muscle mass');
          break;
        case 'maintain':
          recommendations.add('Continue your current balanced approach');
          recommendations.add('Monitor your weight and adjust as needed');
          break;
      }
    }

    return recommendations;
  }

  /// Format calories for display
  static String formatCalories(double calories) {
    return calories.round().toString();
  }

  /// Format macronutrient for display
  static String formatMacro(double grams, {int decimals = 1}) {
    return grams.toStringAsFixed(decimals);
  }

  /// Format percentage for display
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }

  /// Format weight for display
  static String formatWeight(double weight, {int decimals = 1}) {
    return weight % 1 == 0
        ? '${weight.toInt()} kg'
        : '${weight.toStringAsFixed(decimals)} kg';
  }

  /// Calculate calories burned during exercise (basic estimation)
  static double calculateExerciseCalories({
    required double weightKg,
    required int durationMinutes,
    required double metValue, // Metabolic Equivalent of Task
  }) {
    // Calories burned = MET × weight(kg) × duration(hours)
    final double durationHours = durationMinutes / 60.0;
    return metValue * weightKg * durationHours;
  }

  /// Get common MET values for different activities
  static Map<String, double> getCommonMETValues() {
    return {
      'walking_slow': 2.5,
      'walking_moderate': 3.5,
      'walking_fast': 4.3,
      'running_6mph': 9.8,
      'running_8mph': 11.8,
      'cycling_moderate': 5.8,
      'cycling_vigorous': 8.0,
      'swimming_moderate': 5.8,
      'swimming_vigorous': 9.8,
      'strength_training': 3.5,
      'yoga': 2.5,
      'dancing': 4.8,
      'cleaning': 3.3,
      'gardening': 4.0,
    };
  }

  /// Calculate body fat percentage using Navy formula (estimation)
  static double? calculateBodyFatPercentage({
    required UserProfile profile,
    required double neckCircumference, // cm
    required double waistCircumference, // cm
    double? hipCircumference, // cm (required for females)
  }) {
    final height = profile.height;
    final isMale = profile.gender.toLowerCase() == 'male';

    if (isMale) {
      // Male formula: 495 / (1.0324 - 0.19077 × log10(waist - neck) + 0.15456 × log10(height)) - 450
      final value1 = waistCircumference - neckCircumference;
      final value2 = height;

      if (value1 <= 0 || value2 <= 0) return null;

      final logValue1 = (value1 * 0.19077) / 2.302585; // Convert to log10
      final logValue2 = (value2 * 0.15456) / 2.302585;

      final bodyDensity = 1.0324 - logValue1 + logValue2;
      return (495 / bodyDensity) - 450;
    } else {
      // Female formula requires hip measurement
      if (hipCircumference == null) return null;

      final value1 = waistCircumference + hipCircumference - neckCircumference;
      final value2 = height;

      if (value1 <= 0 || value2 <= 0) return null;

      final logValue1 = (value1 * 0.35004) / 2.302585;
      final logValue2 = (value2 * 0.22100) / 2.302585;

      final bodyDensity = 1.29579 - logValue1 + logValue2;
      return (495 / bodyDensity) - 450;
    }
  }
}

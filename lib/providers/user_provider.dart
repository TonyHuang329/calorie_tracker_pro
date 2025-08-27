// lib/providers/user_provider.dart

import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/health_goal.dart';
import '../services/database_service.dart';
import '../utils/calorie_calculator.dart';

/// User-related state management
/// Handles user profile, health goals, and related calculations
class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Private variables
  UserProfile? _userProfile;
  HealthGoal? _currentHealthGoal;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile? get userProfile => _userProfile;
  HealthGoal? get currentHealthGoal => _currentHealthGoal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed properties
  double? get currentBMI {
    if (_userProfile == null) return null;
    return CalorieCalculator.calculateBMI(
        _userProfile!.weight, _userProfile!.height);
  }

  String? get bmiCategory {
    if (currentBMI == null) return null;
    return CalorieCalculator.getBMICategory(currentBMI!);
  }

  double? get currentTDEE {
    if (_userProfile == null) return null;
    return CalorieCalculator.calculateTDEE(_userProfile!);
  }

  Map<String, double>? get idealWeightRange {
    if (_userProfile == null) return null;
    return CalorieCalculator.calculateIdealWeightRange(_userProfile!.height);
  }

  bool get hasCompleteProfile => _userProfile != null;
  bool get hasHealthGoal => _currentHealthGoal != null;

  /// Load user profile
  Future<void> loadUserProfile() async {
    _setLoading(true);
    try {
      _userProfile = await _databaseService.getUserProfile();
      clearError();
    } catch (e) {
      _setError('Failed to load user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save or update user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    _setLoading(true);
    try {
      await _databaseService.insertOrUpdateUserProfile(profile);
      _userProfile = profile;
      clearError();

      // Auto-create default health goal if none exists
      if (_currentHealthGoal == null) {
        await _createDefaultHealthGoal();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to save user profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user weight
  Future<bool> updateWeight(double newWeight) async {
    if (_userProfile == null) return false;

    final updatedProfile = _userProfile!.copyWith(weight: newWeight);
    return await saveUserProfile(updatedProfile);
  }

  /// Update user height
  Future<bool> updateHeight(double newHeight) async {
    if (_userProfile == null) return false;

    final updatedProfile = _userProfile!.copyWith(height: newHeight);
    return await saveUserProfile(updatedProfile);
  }

  /// Update activity level
  Future<bool> updateActivityLevel(String newActivityLevel) async {
    if (_userProfile == null) return false;

    final updatedProfile =
        _userProfile!.copyWith(activityLevel: newActivityLevel);
    final success = await saveUserProfile(updatedProfile);

    // Recalculate health goal after activity level change
    if (success && _currentHealthGoal != null) {
      await _updateHealthGoalBasedOnProfile();
    }

    return success;
  }

  /// Load current health goal
  Future<void> loadCurrentHealthGoal() async {
    _setLoading(true);
    try {
      _currentHealthGoal = await _databaseService.getCurrentHealthGoal();
      clearError();
    } catch (e) {
      _setError('Failed to load health goal: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save or update health goal
  Future<bool> saveHealthGoal(HealthGoal goal) async {
    _setLoading(true);
    try {
      await _databaseService.insertOrUpdateCurrentHealthGoal(goal);
      _currentHealthGoal = goal;
      clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to save health goal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Create default health goal
  Future<void> _createDefaultHealthGoal() async {
    if (_userProfile == null) return;

    try {
      final defaultGoal = CalorieCalculator.createHealthGoalForUser(
        _userProfile!,
        goalType: 'maintain',
      );

      await _databaseService.insertOrUpdateCurrentHealthGoal(defaultGoal);
      _currentHealthGoal = defaultGoal;
    } catch (e) {
      _setError('Failed to create default health goal: $e');
    }
  }

  /// Update health goal based on user profile changes
  Future<void> _updateHealthGoalBasedOnProfile() async {
    if (_userProfile == null || _currentHealthGoal == null) return;

    try {
      final updatedGoal = CalorieCalculator.createHealthGoalForUser(
        _userProfile!,
        goalType: _currentHealthGoal!.goalType ?? 'maintain',
      );

      // Keep original creation time and notes
      final finalGoal = updatedGoal.copyWith(
        id: _currentHealthGoal!.id,
        createdAt: _currentHealthGoal!.createdAt,
        notes: _currentHealthGoal!.notes,
        updatedAt: DateTime.now(),
      );

      await saveHealthGoal(finalGoal);
    } catch (e) {
      _setError('Failed to update health goal: $e');
    }
  }

  /// Set new health goal type
  Future<bool> setGoalType(String goalType,
      {double weeklyWeightChange = 0.0}) async {
    if (_userProfile == null) return false;

    try {
      final newGoal = CalorieCalculator.createHealthGoalForUser(
        _userProfile!,
        goalType: goalType,
        weeklyWeightChange: weeklyWeightChange,
      );

      // Keep existing goal info if available
      if (_currentHealthGoal != null) {
        final updatedGoal = newGoal.copyWith(
          id: _currentHealthGoal!.id,
          createdAt: _currentHealthGoal!.createdAt,
          notes: _currentHealthGoal!.notes,
          updatedAt: DateTime.now(),
        );
        return await saveHealthGoal(updatedGoal);
      } else {
        return await saveHealthGoal(newGoal);
      }
    } catch (e) {
      _setError('Failed to set health goal: $e');
      return false;
    }
  }

  /// Set custom health goal
  Future<bool> setCustomGoal({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
    String? notes,
  }) async {
    try {
      final customGoal = HealthGoal(
        id: _currentHealthGoal?.id,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        createdAt: _currentHealthGoal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        goalType: 'custom',
        notes: notes,
      );

      return await saveHealthGoal(customGoal);
    } catch (e) {
      _setError('Failed to set custom goal: $e');
      return false;
    }
  }

  /// Get health recommendations
  List<String> getHealthRecommendations() {
    final recommendations = <String>[];

    if (_userProfile == null) {
      recommendations.add(
          'Please complete your profile to get personalized recommendations');
      return recommendations;
    }

    final bmi = currentBMI;
    if (bmi != null) {
      if (bmi < 18.5) {
        recommendations.add(
            'Your BMI is below normal range. Consider gaining weight through healthy diet and exercise');
        recommendations
            .add('You may want to increase protein and healthy fat intake');
      } else if (bmi > 25) {
        recommendations.add(
            'Your BMI is above normal range. Consider weight management through balanced diet and exercise');
        recommendations
            .add('Focus on portion control and regular physical activity');
      } else {
        recommendations.add(
            'Your BMI is in the healthy range. Keep up your current lifestyle');
      }
    }

    // Age-based recommendations
    if (_userProfile!.age >= 50) {
      recommendations.add('Consider increasing calcium and vitamin D intake');
      recommendations.add('Include low-impact exercises and strength training');
    } else if (_userProfile!.age <= 25) {
      recommendations.add('Great time to establish healthy eating habits');
      recommendations
          .add('Vary your exercise routine to build overall fitness');
    }

    // Activity level recommendations
    if (_userProfile!.activityLevel == 'sedentary') {
      recommendations.add(
          'Sedentary lifestyle may be harmful to health. Try to increase daily activity');
      recommendations.add('You can start with 30 minutes of walking daily');
    }

    return recommendations;
  }

  /// Calculate goal progress
  Map<String, double> calculateGoalProgress(Map<String, double> dailyIntake) {
    if (_currentHealthGoal == null) {
      return {
        'calorieProgress': 0.0,
        'proteinProgress': 0.0,
        'carbsProgress': 0.0,
        'fatProgress': 0.0,
      };
    }

    return {
      'calorieProgress': CalorieCalculator.calculateGoalProgress(
          dailyIntake['totalCalories'] ?? 0.0,
          _currentHealthGoal!.targetCalories),
      'proteinProgress': CalorieCalculator.calculateGoalProgress(
          dailyIntake['totalProtein'] ?? 0.0,
          _currentHealthGoal!.targetProtein),
      'carbsProgress': CalorieCalculator.calculateGoalProgress(
          dailyIntake['totalCarbs'] ?? 0.0, _currentHealthGoal!.targetCarbs),
      'fatProgress': CalorieCalculator.calculateGoalProgress(
          dailyIntake['totalFat'] ?? 0.0, _currentHealthGoal!.targetFat),
    };
  }

  /// Predict time to reach goal weight
  int? calculateTimeToGoalWeight(double targetWeight) {
    if (_userProfile == null || _currentHealthGoal == null) return null;

    final currentWeight = _userProfile!.weight;
    final tdee = CalorieCalculator.calculateTDEE(_userProfile!);
    final dailyDeficit = tdee - _currentHealthGoal!.targetCalories;

    return CalorieCalculator.calculateTimeToGoal(
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      dailyCalorieDeficitOrSurplus: dailyDeficit,
    );
  }

  /// Validate user profile
  String? validateUserProfile(UserProfile profile) {
    if (profile.name.isEmpty) {
      return 'Name cannot be empty';
    }

    if (profile.age < 13 || profile.age > 120) {
      return 'Age must be between 13 and 120 years';
    }

    if (profile.height < 100 || profile.height > 250) {
      return 'Height must be between 100 and 250 cm';
    }

    if (profile.weight < 30 || profile.weight > 300) {
      return 'Weight must be between 30 and 300 kg';
    }

    if (!['male', 'female'].contains(profile.gender)) {
      return 'Please select a valid gender';
    }

    const validActivityLevels = [
      'sedentary',
      'light',
      'moderate',
      'active',
      'very_active'
    ];
    if (!validActivityLevels.contains(profile.activityLevel)) {
      return 'Please select a valid activity level';
    }

    return null; // Validation passed
  }

  /// Validate health goal
  String? validateHealthGoal(HealthGoal goal) {
    if (goal.targetCalories < 1000 || goal.targetCalories > 5000) {
      return 'Target calories must be between 1000 and 5000';
    }

    if (goal.targetProtein < 0 || goal.targetProtein > 300) {
      return 'Target protein must be between 0 and 300 grams';
    }

    if (goal.targetCarbs < 0 || goal.targetCarbs > 500) {
      return 'Target carbohydrates must be between 0 and 500 grams';
    }

    if (goal.targetFat < 0 || goal.targetFat > 200) {
      return 'Target fat must be between 0 and 200 grams';
    }

    // Validate macro balance
    if (!CalorieCalculator.validateNutritionData(
      calories: goal.targetCalories,
      protein: goal.targetProtein,
      carbs: goal.targetCarbs,
      fat: goal.targetFat,
    )) {
      return 'Macronutrient distribution is unreasonable, please readjust';
    }

    return null; // Validation passed
  }

  /// Get BMI status for UI display
  String get bmiStatus {
    if (currentBMI == null) return 'unknown';

    final bmi = currentBMI!;
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

  /// Get BMI color for UI display
  String get bmiColorStatus {
    if (currentBMI == null) return 'grey';

    final bmi = currentBMI!;
    if (bmi < 18.5) return 'blue';
    if (bmi < 25) return 'green';
    if (bmi < 30) return 'orange';
    return 'red';
  }

  /// Get weight status relative to ideal range
  String get weightStatus {
    if (_userProfile == null || idealWeightRange == null) return 'unknown';

    final weight = _userProfile!.weight;
    final range = idealWeightRange!;

    if (weight < range['min']!) return 'underweight';
    if (weight > range['max']!) return 'overweight';
    return 'normal';
  }

  /// Get personalized protein recommendation
  double? get recommendedProtein {
    if (_userProfile == null) return null;
    return CalorieCalculator.calculateProteinRequirement(_userProfile!,
        goalType: _currentHealthGoal?.goalType ?? 'maintain');
  }

  /// Get personalized water intake recommendation
  double? get recommendedWaterIntake {
    if (_userProfile == null) return null;
    return CalorieCalculator.calculateWaterIntake(_userProfile!);
  }

  /// Reset user data
  Future<void> resetUserData() async {
    _setLoading(true);
    try {
      // Clear database user data
      await _databaseService.clearAllData();

      // Reset state
      _userProfile = null;
      _currentHealthGoal = null;
      clearError();

      notifyListeners();
    } catch (e) {
      _setError('Failed to reset user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      return {
        'exportDate': DateTime.now().toIso8601String(),
        'userProfile': _userProfile?.toMap(),
        'healthGoal': _currentHealthGoal?.toMap(),
      };
    } catch (e) {
      _setError('Failed to export user data: $e');
      return {};
    }
  }

  /// Import user data
  Future<bool> importUserData(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      final profileData = userData['userProfile'] as Map<String, dynamic>?;
      final goalData = userData['healthGoal'] as Map<String, dynamic>?;

      if (profileData != null) {
        final profile = UserProfile.fromMap(profileData);
        await saveUserProfile(profile);
      }

      if (goalData != null) {
        final goal = HealthGoal.fromMap(goalData);
        await saveHealthGoal(goal);
      }

      return true;
    } catch (e) {
      _setError('Failed to import user data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get user progress summary
  Map<String, dynamic> getUserProgressSummary() {
    if (_userProfile == null) return {};

    final summary = <String, dynamic>{
      'profileComplete': true,
      'hasGoal': _currentHealthGoal != null,
      'bmi': currentBMI,
      'bmiCategory': bmiCategory,
      'bmiStatus': bmiStatus,
      'weightStatus': weightStatus,
      'tdee': currentTDEE,
      'idealWeightRange': idealWeightRange,
      'age': _userProfile!.age,
      'ageGroup': _userProfile!.ageGroup,
      'activityLevel': _userProfile!.activityLevel,
      'recommendedProtein': recommendedProtein,
      'recommendedWater': recommendedWaterIntake,
    };

    if (_currentHealthGoal != null) {
      summary.addAll({
        'goalType': _currentHealthGoal!.goalType,
        'targetCalories': _currentHealthGoal!.targetCalories,
        'goalCreated': _currentHealthGoal!.createdAt,
        'goalUpdated': _currentHealthGoal!.updatedAt,
      });
    }

    return summary;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    if (kDebugMode) {
      print('UserProvider Error: $error');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all state
  void clearAll() {
    _userProfile = null;
    _currentHealthGoal = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

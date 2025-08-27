import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/health_goal.dart';
import '../services/database_service.dart';
import '../utils/calorie_calculator.dart';

/// 用户相关状态管理
class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // 私有变量
  UserProfile? _userProfile;
  HealthGoal? _currentHealthGoal;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile? get userProfile => _userProfile;
  HealthGoal? get currentHealthGoal => _currentHealthGoal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 计算属性
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

  /// 加载用户配置
  Future<void> loadUserProfile() async {
    _setLoading(true);
    try {
      _userProfile = await _databaseService.getUserProfile();
      clearError();
    } catch (e) {
      _setError('加载用户配置失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 保存或更新用户配置
  Future<bool> saveUserProfile(UserProfile profile) async {
    _setLoading(true);
    try {
      await _databaseService.insertOrUpdateUserProfile(profile);
      _userProfile = profile;
      clearError();

      // 如果没有健康目标，自动创建默认目标
      if (_currentHealthGoal == null) {
        await _createDefaultHealthGoal();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('保存用户配置失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 更新用户体重
  Future<bool> updateWeight(double newWeight) async {
    if (_userProfile == null) return false;

    final updatedProfile = _userProfile!.copyWith(weight: newWeight);
    return await saveUserProfile(updatedProfile);
  }

  /// 更新用户身高
  Future<bool> updateHeight(double newHeight) async {
    if (_userProfile == null) return false;

    final updatedProfile = _userProfile!.copyWith(height: newHeight);
    return await saveUserProfile(updatedProfile);
  }

  /// 更新活动水平
  Future<bool> updateActivityLevel(String newActivityLevel) async {
    if (_userProfile == null) return false;

    final updatedProfile =
        _userProfile!.copyWith(activityLevel: newActivityLevel);
    final success = await saveUserProfile(updatedProfile);

    // 更新活动水平后，重新计算健康目标
    if (success && _currentHealthGoal != null) {
      await _updateHealthGoalBasedOnProfile();
    }

    return success;
  }

  /// 加载当前健康目标
  Future<void> loadCurrentHealthGoal() async {
    _setLoading(true);
    try {
      _currentHealthGoal = await _databaseService.getCurrentHealthGoal();
      clearError();
    } catch (e) {
      _setError('加载健康目标失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 保存或更新健康目标
  Future<bool> saveHealthGoal(HealthGoal goal) async {
    _setLoading(true);
    try {
      await _databaseService.insertOrUpdateCurrentHealthGoal(goal);
      _currentHealthGoal = goal;
      clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('保存健康目标失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 创建默认健康目标
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
      _setError('创建默认健康目标失败: $e');
    }
  }

  /// 根据用户配置更新健康目标
  Future<void> _updateHealthGoalBasedOnProfile() async {
    if (_userProfile == null || _currentHealthGoal == null) return;

    try {
      final updatedGoal = CalorieCalculator.createHealthGoalForUser(
        _userProfile!,
        goalType: _currentHealthGoal!.goalType ?? 'maintain',
      );

      // 保持原有的创建时间和备注
      final finalGoal = updatedGoal.copyWith(
        id: _currentHealthGoal!.id,
        createdAt: _currentHealthGoal!.createdAt,
        notes: _currentHealthGoal!.notes,
        updatedAt: DateTime.now(),
      );

      await saveHealthGoal(finalGoal);
    } catch (e) {
      _setError('更新健康目标失败: $e');
    }
  }

  /// 设置新的健康目标类型
  Future<bool> setGoalType(String goalType,
      {double weeklyWeightChange = 0.0}) async {
    if (_userProfile == null) return false;

    try {
      final newGoal = CalorieCalculator.createHealthGoalForUser(
        _userProfile!,
        goalType: goalType,
        weeklyWeightChange: weeklyWeightChange,
      );

      // 如果已有目标，保持原有信息
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
      _setError('设置健康目标失败: $e');
      return false;
    }
  }

  /// 自定义健康目标
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
      _setError('设置自定义目标失败: $e');
      return false;
    }
  }

  /// 获取健康建议
  List<String> getHealthRecommendations() {
    final recommendations = <String>[];

    if (_userProfile == null) {
      recommendations.add('请完善个人资料以获取个性化建议');
      return recommendations;
    }

    final bmi = currentBMI;
    if (bmi != null) {
      if (bmi < 18.5) {
        recommendations.add('您的BMI偏低，建议增加健康饮食和适量运动');
        recommendations.add('可以考虑增加蛋白质和健康脂肪的摄入');
      } else if (bmi > 25) {
        recommendations.add('您的BMI偏高，建议控制卡路里摄入并增加运动');
        recommendations.add('推荐采用均衡饮食，减少加工食品');
      } else {
        recommendations.add('您的BMI在正常范围内，继续保持健康的生活方式');
      }
    }

    // 根据年龄给出建议
    if (_userProfile!.age >= 50) {
      recommendations.add('建议增加钙质和维生素D的摄入');
      recommendations.add('可以进行低强度的有氧运动和力量训练');
    } else if (_userProfile!.age <= 25) {
      recommendations.add('年轻时期是建立良好饮食习惯的关键时期');
      recommendations.add('可以进行多样化的运动来提高身体素质');
    }

    // 根据活动水平给出建议
    if (_userProfile!.activityLevel == 'sedentary') {
      recommendations.add('久坐生活方式对健康不利，建议增加日常活动');
      recommendations.add('可以从每天步行30分钟开始');
    }

    return recommendations;
  }

  /// 计算目标达成情况
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

  /// 预测达到目标体重的时间
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

  /// 验证用户输入数据
  String? validateUserProfile(UserProfile profile) {
    if (profile.name.isEmpty) {
      return '姓名不能为空';
    }

    if (profile.age < 10 || profile.age > 120) {
      return '年龄必须在10-120岁之间';
    }

    if (profile.height < 100 || profile.height > 250) {
      return '身高必须在100-250厘米之间';
    }

    if (profile.weight < 20 || profile.weight > 300) {
      return '体重必须在20-300公斤之间';
    }

    if (!['male', 'female'].contains(profile.gender)) {
      return '请选择正确的性别';
    }

    const validActivityLevels = [
      'sedentary',
      'light',
      'moderate',
      'active',
      'very_active'
    ];
    if (!validActivityLevels.contains(profile.activityLevel)) {
      return '请选择正确的活动水平';
    }

    return null; // 验证通过
  }

  /// 验证健康目标数据
  String? validateHealthGoal(HealthGoal goal) {
    if (goal.targetCalories < 1000 || goal.targetCalories > 5000) {
      return '目标卡路里必须在1000-5000之间';
    }

    if (goal.targetProtein < 0 || goal.targetProtein > 300) {
      return '目标蛋白质必须在0-300克之间';
    }

    if (goal.targetCarbs < 0 || goal.targetCarbs > 500) {
      return '目标碳水化合物必须在0-500克之间';
    }

    if (goal.targetFat < 0 || goal.targetFat > 200) {
      return '目标脂肪必须在0-200克之间';
    }

    // 验证宏量营养素是否合理
    if (!CalorieCalculator.validateNutritionData(
      calories: goal.targetCalories,
      protein: goal.targetProtein,
      carbs: goal.targetCarbs,
      fat: goal.targetFat,
    )) {
      return '宏量营养素配比不合理，请重新调整';
    }

    return null; // 验证通过
  }

  /// 重置用户数据
  Future<void> resetUserData() async {
    _setLoading(true);
    try {
      // 清除数据库中的用户数据
      await _databaseService.clearAllData();

      // 重置状态
      _userProfile = null;
      _currentHealthGoal = null;
      clearError();

      notifyListeners();
    } catch (e) {
      _setError('重置用户数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 导出用户数据
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      return {
        'exportDate': DateTime.now().toIso8601String(),
        'userProfile': _userProfile?.toMap(),
        'healthGoal': _currentHealthGoal?.toMap(),
      };
    } catch (e) {
      _setError('导出用户数据失败: $e');
      return {};
    }
  }

  /// 导入用户数据
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
      _setError('导入用户数据失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    if (kDebugMode) {
      print('UserProvider Error: $error');
    }
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 清除所有状态
  void clearAll() {
    _userProfile = null;
    _currentHealthGoal = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
}

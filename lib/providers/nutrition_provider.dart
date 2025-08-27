import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../utils/calorie_calculator.dart';

/// 营养数据状态管理
class NutritionProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // 私有变量
  DateTime _selectedDate = DateTime.now();
  List<FoodItem> _todayFoodItems = [];
  List<FoodItem> _selectedDateFoodItems = [];
  Map<String, double> _todayNutritionSummary = {};
  Map<String, double> _selectedDateNutritionSummary = {};
  Map<String, Map<String, double>> _todayMealSummary = {};
  bool _isLoading = false;
  String? _errorMessage;

  // 缓存数据
  final Map<String, List<FoodItem>> _foodItemsCache = {};
  final Map<String, Map<String, double>> _nutritionSummaryCache = {};

  // Getters
  DateTime get selectedDate => _selectedDate;
  List<FoodItem> get todayFoodItems => _todayFoodItems;
  List<FoodItem> get selectedDateFoodItems => _selectedDateFoodItems;
  Map<String, double> get todayNutritionSummary => _todayNutritionSummary;
  Map<String, double> get selectedDateNutritionSummary =>
      _selectedDateNutritionSummary;
  Map<String, Map<String, double>> get todayMealSummary => _todayMealSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 计算属性
  bool get isSelectedDateToday {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  double get todayTotalCalories =>
      _todayNutritionSummary['totalCalories'] ?? 0.0;
  double get todayTotalProtein => _todayNutritionSummary['totalProtein'] ?? 0.0;
  double get todayTotalCarbs => _todayNutritionSummary['totalCarbs'] ?? 0.0;
  double get todayTotalFat => _todayNutritionSummary['totalFat'] ?? 0.0;

  double get selectedDateTotalCalories =>
      _selectedDateNutritionSummary['totalCalories'] ?? 0.0;
  double get selectedDateTotalProtein =>
      _selectedDateNutritionSummary['totalProtein'] ?? 0.0;
  double get selectedDateTotalCarbs =>
      _selectedDateNutritionSummary['totalCarbs'] ?? 0.0;
  double get selectedDateTotalFat =>
      _selectedDateNutritionSummary['totalFat'] ?? 0.0;

  /// 构造函数
  NutritionProvider() {
    _loadTodayNutrition();
  }

  /// 加载今日营养数据
  Future<void> loadTodayNutrition() async {
    await _loadTodayNutrition();
  }

  Future<void> _loadTodayNutrition() async {
    _setLoading(true);
    try {
      final today = DateTime.now();
      await _loadNutritionForDate(today);

      _todayFoodItems = _selectedDateFoodItems;
      _todayNutritionSummary = _selectedDateNutritionSummary;
      _todayMealSummary = await _databaseService.getDailyNutritionByMeal(today);

      _clearError();
    } catch (e) {
      _setError('加载今日营养数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 设置选定日期并加载数据
  Future<void> setSelectedDate(DateTime date) async {
    if (_isSameDate(_selectedDate, date)) return;

    _selectedDate = date;
    notifyListeners();

    await _loadNutritionForDate(date);
  }

  /// 加载指定日期的营养数据
  Future<void> _loadNutritionForDate(DateTime date) async {
    final dateKey = _formatDateKey(date);

    // 检查缓存
    if (_foodItemsCache.containsKey(dateKey) &&
        _nutritionSummaryCache.containsKey(dateKey)) {
      _selectedDateFoodItems = _foodItemsCache[dateKey]!;
      _selectedDateNutritionSummary = _nutritionSummaryCache[dateKey]!;
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      // 加载食物条目
      _selectedDateFoodItems = await _databaseService.getFoodItemsByDate(date);

      // 加载营养摘要
      _selectedDateNutritionSummary =
          await _databaseService.getDailyNutritionSummary(date);

      // 缓存数据
      _foodItemsCache[dateKey] = _selectedDateFoodItems;
      _nutritionSummaryCache[dateKey] = _selectedDateNutritionSummary;

      _clearError();
    } catch (e) {
      _setError('加载营养数据失败: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 添加食物条目
  Future<bool> addFoodItem(FoodItem foodItem) async {
    _setLoading(true);
    try {
      final id = await _databaseService.insertFoodItem(foodItem);

      // 创建带ID的食物条目
      final savedFoodItem = foodItem.copyWith(id: id);

      // 更新缓存和状态
      await _refreshAfterFoodChange(savedFoodItem.date);

      _clearError();
      return true;
    } catch (e) {
      _setError('添加食物条目失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 更新食物条目
  Future<bool> updateFoodItem(FoodItem foodItem) async {
    if (foodItem.id == null) return false;

    _setLoading(true);
    try {
      await _databaseService.updateFoodItem(foodItem);

      // 更新缓存和状态
      await _refreshAfterFoodChange(foodItem.date);

      _clearError();
      return true;
    } catch (e) {
      _setError('更新食物条目失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 删除食物条目
  Future<bool> deleteFoodItem(int id, DateTime date) async {
    _setLoading(true);
    try {
      await _databaseService.deleteFoodItem(id);

      // 更新缓存和状态
      await _refreshAfterFoodChange(date);

      _clearError();
      return true;
    } catch (e) {
      _setError('删除食物条目失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 批量删除食物条目
  Future<bool> deleteFoodItems(List<int> ids, DateTime date) async {
    _setLoading(true);
    try {
      for (int id in ids) {
        await _databaseService.deleteFoodItem(id);
      }

      await _refreshAfterFoodChange(date);

      _clearError();
      return true;
    } catch (e) {
      _setError('批量删除食物条目失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 获取指定餐次的食物
  List<FoodItem> getFoodItemsByMealType(String mealType) {
    if (isSelectedDateToday) {
      return _todayFoodItems
          .where((item) => item.mealType == mealType)
          .toList();
    } else {
      return _selectedDateFoodItems
          .where((item) => item.mealType == mealType)
          .toList();
    }
  }

  /// 获取指定餐次的营养摘要
  Map<String, double> getMealNutritionSummary(String mealType) {
    final mealItems = getFoodItemsByMealType(mealType);

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var item in mealItems) {
      totalCalories += item.calories;
      totalProtein += item.protein;
      totalCarbs += item.carbs;
      totalFat += item.fat;
    }

    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }

  /// 获取一周的营养数据
  Future<List<Map<String, dynamic>>> getWeeklyNutritionData(
      DateTime startDate) async {
    try {
      _setLoading(true);

      final weeklyData = <Map<String, dynamic>>[];

      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey = _formatDateKey(date);

        Map<String, double> nutritionData;

        // 检查缓存
        if (_nutritionSummaryCache.containsKey(dateKey)) {
          nutritionData = _nutritionSummaryCache[dateKey]!;
        } else {
          nutritionData = await _databaseService.getDailyNutritionSummary(date);
          _nutritionSummaryCache[dateKey] = nutritionData;
        }

        weeklyData.add({
          'date': date,
          'dateString': '${date.month}/${date.day}',
          'weekdayName': _getWeekdayName(date.weekday),
          ...nutritionData,
        });
      }

      return weeklyData;
    } catch (e) {
      _setError('加载周营养数据失败: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// 获取月营养数据
  Future<List<Map<String, dynamic>>> getMonthlyNutritionData(
      DateTime month) async {
    try {
      _setLoading(true);

      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      final foodItems =
          await _databaseService.getFoodItemsByDateRange(startDate, endDate);

      // 按日期分组
      final dailyData = <String, Map<String, double>>{};

      for (var item in foodItems) {
        final dateKey = _formatDateKey(item.date);

        dailyData[dateKey] ??= {
          'totalCalories': 0.0,
          'totalProtein': 0.0,
          'totalCarbs': 0.0,
          'totalFat': 0.0,
        };

        dailyData[dateKey]!['totalCalories'] =
            (dailyData[dateKey]!['totalCalories']! + item.calories);
        dailyData[dateKey]!['totalProtein'] =
            (dailyData[dateKey]!['totalProtein']! + item.protein);
        dailyData[dateKey]!['totalCarbs'] =
            (dailyData[dateKey]!['totalCarbs']! + item.carbs);
        dailyData[dateKey]!['totalFat'] =
            (dailyData[dateKey]!['totalFat']! + item.fat);
      }

      // 转换为列表格式
      final monthlyData = <Map<String, dynamic>>[];

      for (int day = 1; day <= endDate.day; day++) {
        final date = DateTime(month.year, month.month, day);
        final dateKey = _formatDateKey(date);

        final nutritionData = dailyData[dateKey] ??
            {
              'totalCalories': 0.0,
              'totalProtein': 0.0,
              'totalCarbs': 0.0,
              'totalFat': 0.0,
            };

        monthlyData.add({
          'date': date,
          'day': day,
          ...nutritionData,
        });
      }

      return monthlyData;
    } catch (e) {
      _setError('加载月营养数据失败: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// 计算平均营养摄入
  Map<String, double> calculateAverageNutrition(
      List<Map<String, dynamic>> nutritionData) {
    if (nutritionData.isEmpty) {
      return {
        'avgCalories': 0.0,
        'avgProtein': 0.0,
        'avgCarbs': 0.0,
        'avgFat': 0.0,
      };
    }

    final validData = nutritionData
        .where((data) =>
            (data['totalCalories'] as double?) != null &&
            (data['totalCalories'] as double) > 0)
        .toList();

    if (validData.isEmpty) {
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

    for (var data in validData) {
      totalCalories += (data['totalCalories'] as double?) ?? 0.0;
      totalProtein += (data['totalProtein'] as double?) ?? 0.0;
      totalCarbs += (data['totalCarbs'] as double?) ?? 0.0;
      totalFat += (data['totalFat'] as double?) ?? 0.0;
    }

    final days = validData.length;

    return {
      'avgCalories': totalCalories / days,
      'avgProtein': totalProtein / days,
      'avgCarbs': totalCarbs / days,
      'avgFat': totalFat / days,
    };
  }

  /// 搜索食物条目
  Future<List<FoodItem>> searchFoodItems({
    required String query,
    DateTime? startDate,
    DateTime? endDate,
    String? mealType,
  }) async {
    try {
      List<FoodItem> allItems;

      if (startDate != null && endDate != null) {
        allItems =
            await _databaseService.getFoodItemsByDateRange(startDate, endDate);
      } else {
        allItems = await _databaseService.getAllFoodItems();
      }

      // 过滤结果
      var filteredItems = allItems.where((item) {
        final matchesQuery =
            item.name.toLowerCase().contains(query.toLowerCase());
        final matchesMealType = mealType == null || item.mealType == mealType;
        return matchesQuery && matchesMealType;
      }).toList();

      // 按相关性排序
      filteredItems.sort((a, b) {
        final aStartsWith =
            a.name.toLowerCase().startsWith(query.toLowerCase());
        final bStartsWith =
            b.name.toLowerCase().startsWith(query.toLowerCase());

        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        return b.date.compareTo(a.date); // 最新的在前
      });

      return filteredItems.take(50).toList(); // 限制结果数量
    } catch (e) {
      _setError('搜索食物条目失败: $e');
      return [];
    }
  }

  /// 获取常用食物
  Future<List<FoodItem>> getFrequentFoods({int limit = 20}) async {
    try {
      final allItems = await _databaseService.getAllFoodItems();

      // 统计食物出现频率
      final foodFrequency = <String, FoodItem>{};
      final foodCount = <String, int>{};

      for (var item in allItems) {
        final key = item.name.toLowerCase();
        foodCount[key] = (foodCount[key] ?? 0) + 1;

        // 保存最新的食物条目作为模板
        if (!foodFrequency.containsKey(key) ||
            item.date.isAfter(foodFrequency[key]!.date)) {
          foodFrequency[key] = item;
        }
      }

      // 按频率排序
      final sortedFoods = foodFrequency.entries.toList();
      sortedFoods
          .sort((a, b) => foodCount[b.key]!.compareTo(foodCount[a.key]!));

      return sortedFoods.take(limit).map((entry) => entry.value).toList();
    } catch (e) {
      _setError('获取常用食物失败: $e');
      return [];
    }
  }

  /// 获取最近添加的食物
  Future<List<FoodItem>> getRecentFoods({int limit = 10}) async {
    try {
      final allItems = await _databaseService.getAllFoodItems();

      // 按添加时间排序（最新的在前）
      allItems.sort((a, b) => b.date.compareTo(a.date));

      return allItems.take(limit).toList();
    } catch (e) {
      _setError('获取最近食物失败: $e');
      return [];
    }
  }

  /// 复制食物条目到指定日期
  Future<bool> copyFoodItemToDate(
      FoodItem originalItem, DateTime targetDate, String mealType) async {
    try {
      final copiedItem = originalItem.copyWith(
        id: null, // 移除ID，让数据库自动生成
        date: targetDate,
        mealType: mealType,
      );

      return await addFoodItem(copiedItem);
    } catch (e) {
      _setError('复制食物条目失败: $e');
      return false;
    }
  }

  /// 批量添加食物条目
  Future<bool> addMultipleFoodItems(List<FoodItem> foodItems) async {
    _setLoading(true);
    try {
      for (var item in foodItems) {
        await _databaseService.insertFoodItem(item);
      }

      // 刷新相关日期的数据
      final uniqueDates = foodItems.map((item) => item.date).toSet();
      for (var date in uniqueDates) {
        await _refreshAfterFoodChange(date);
      }

      _clearError();
      return true;
    } catch (e) {
      _setError('批量添加食物条目失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 导出营养数据
  Future<Map<String, dynamic>> exportNutritionData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      final foodItems =
          await _databaseService.getFoodItemsByDateRange(start, end);

      return {
        'exportDate': DateTime.now().toIso8601String(),
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
        'foodItems': foodItems.map((item) => item.toMap()).toList(),
      };
    } catch (e) {
      _setError('导出营养数据失败: $e');
      return {};
    }
  }

  /// 获取营养统计信息
  Map<String, dynamic> getNutritionStats() {
    if (isSelectedDateToday) {
      return _calculateNutritionStats(_todayNutritionSummary, _todayFoodItems);
    } else {
      return _calculateNutritionStats(
          _selectedDateNutritionSummary, _selectedDateFoodItems);
    }
  }

  /// 计算营养统计信息
  Map<String, dynamic> _calculateNutritionStats(
    Map<String, double> nutritionSummary,
    List<FoodItem> foodItems,
  ) {
    final totalCalories = nutritionSummary['totalCalories'] ?? 0.0;
    final totalProtein = nutritionSummary['totalProtein'] ?? 0.0;
    final totalCarbs = nutritionSummary['totalCarbs'] ?? 0.0;
    final totalFat = nutritionSummary['totalFat'] ?? 0.0;

    // 计算宏量营养素百分比
    final totalMacroCalories =
        (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9);

    double proteinPercentage = 0;
    double carbsPercentage = 0;
    double fatPercentage = 0;

    if (totalMacroCalories > 0) {
      proteinPercentage = (totalProtein * 4) / totalMacroCalories * 100;
      carbsPercentage = (totalCarbs * 4) / totalMacroCalories * 100;
      fatPercentage = (totalFat * 9) / totalMacroCalories * 100;
    }

    // 按餐次统计
    final mealStats = <String, Map<String, double>>{};
    final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

    for (String mealType in mealTypes) {
      final mealItems = foodItems.where((item) => item.mealType == mealType);
      double mealCalories = 0;
      double mealProtein = 0;
      double mealCarbs = 0;
      double mealFat = 0;

      for (var item in mealItems) {
        mealCalories += item.calories;
        mealProtein += item.protein;
        mealCarbs += item.carbs;
        mealFat += item.fat;
      }

      mealStats[mealType] = {
        'calories': mealCalories,
        'protein': mealProtein,
        'carbs': mealCarbs,
        'fat': mealFat,
        'percentage':
            totalCalories > 0 ? (mealCalories / totalCalories * 100) : 0,
      };
    }

    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'proteinPercentage': proteinPercentage,
      'carbsPercentage': carbsPercentage,
      'fatPercentage': fatPercentage,
      'mealStats': mealStats,
      'foodCount': foodItems.length,
    };
  }

  /// 刷新食物变更后的数据
  Future<void> _refreshAfterFoodChange(DateTime date) async {
    final dateKey = _formatDateKey(date);

    // 清除缓存
    _foodItemsCache.remove(dateKey);
    _nutritionSummaryCache.remove(dateKey);

    // 重新加载数据
    if (_isSameDate(date, DateTime.now())) {
      await _loadTodayNutrition();
    }

    if (_isSameDate(date, _selectedDate)) {
      await _loadNutritionForDate(date);
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
      print('NutritionProvider Error: $error');
    }
  }

  /// 清除错误信息
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 清除缓存
  void clearCache() {
    _foodItemsCache.clear();
    _nutritionSummaryCache.clear();
    notifyListeners();
  }

  /// 格式化日期键
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 检查是否为同一天
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 获取星期名称
  String _getWeekdayName(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '星期${weekdays[weekday - 1]}';
  }

  /// 重置所有数据
  void resetAllData() {
    _selectedDate = DateTime.now();
    _todayFoodItems.clear();
    _selectedDateFoodItems.clear();
    _todayNutritionSummary.clear();
    _selectedDateNutritionSummary.clear();
    _todayMealSummary.clear();
    _foodItemsCache.clear();
    _nutritionSummaryCache.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _foodItemsCache.clear();
    _nutritionSummaryCache.clear();
    super.dispose();
  }
}

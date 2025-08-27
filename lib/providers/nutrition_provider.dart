// lib/providers/nutrition_provider.dart

import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';

/// Nutrition data state management
/// Handles food items, daily nutrition summaries, and related calculations
class NutritionProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Private variables
  DateTime _selectedDate = DateTime.now();
  List<FoodItem> _todayFoodItems = [];
  List<FoodItem> _selectedDateFoodItems = [];
  Map<String, double> _todayNutritionSummary = {};
  Map<String, double> _selectedDateNutritionSummary = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Cache data
  final Map<String, List<FoodItem>> _foodItemsCache = {};
  final Map<String, Map<String, double>> _nutritionSummaryCache = {};

  // Getters
  DateTime get selectedDate => _selectedDate;
  List<FoodItem> get todayFoodItems => _todayFoodItems;
  List<FoodItem> get selectedDateFoodItems => _selectedDateFoodItems;
  Map<String, double> get todayNutritionSummary => _todayNutritionSummary;
  Map<String, double> get selectedDateNutritionSummary =>
      _selectedDateNutritionSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed properties
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

  /// Constructor
  NutritionProvider() {
    _loadTodayNutrition();
  }

  /// Load today's nutrition data
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

      _clearError();
    } catch (e) {
      _setError('Failed to load today\'s nutrition data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set selected date and load data
  Future<void> setSelectedDate(DateTime date) async {
    if (_isSameDate(_selectedDate, date)) return;

    _selectedDate = date;
    notifyListeners();

    await _loadNutritionForDate(date);
  }

  /// Load nutrition data for specific date
  Future<void> _loadNutritionForDate(DateTime date) async {
    final dateKey = _formatDateKey(date);

    // Check cache
    if (_foodItemsCache.containsKey(dateKey) &&
        _nutritionSummaryCache.containsKey(dateKey)) {
      _selectedDateFoodItems = _foodItemsCache[dateKey]!;
      _selectedDateNutritionSummary = _nutritionSummaryCache[dateKey]!;
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      // Load food items
      _selectedDateFoodItems = await _databaseService.getFoodItemsByDate(date);

      // Load nutrition summary
      _selectedDateNutritionSummary =
          await _databaseService.getDailyNutritionSummary(date);

      // Cache data
      _foodItemsCache[dateKey] = _selectedDateFoodItems;
      _nutritionSummaryCache[dateKey] = _selectedDateNutritionSummary;

      _clearError();
    } catch (e) {
      _setError('Failed to load nutrition data: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Add food item
  Future<bool> addFoodItem(FoodItem foodItem) async {
    _setLoading(true);
    try {
      final id = await _databaseService.insertFoodItem(foodItem);

      // Create food item with ID
      final savedFoodItem = foodItem.copyWith(id: id);

      // Update cache and state
      await _refreshAfterFoodChange(savedFoodItem.date);

      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to add food item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update food item
  Future<bool> updateFoodItem(FoodItem foodItem) async {
    if (foodItem.id == null) return false;

    _setLoading(true);
    try {
      await _databaseService.updateFoodItem(foodItem);

      // Update cache and state
      await _refreshAfterFoodChange(foodItem.date);

      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to update food item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete food item
  Future<bool> deleteFoodItem(int id, DateTime date) async {
    _setLoading(true);
    try {
      await _databaseService.deleteFoodItem(id);

      // Update cache and state
      await _refreshAfterFoodChange(date);

      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to delete food item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Batch delete food items
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
      _setError('Failed to batch delete food items: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get food items by meal type
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

  /// Get nutrition summary for specific meal type
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

  /// Get weekly nutrition data
  Future<List<Map<String, dynamic>>> getWeeklyNutritionData(
      DateTime startDate) async {
    try {
      _setLoading(true);

      final weeklyData = <Map<String, dynamic>>[];

      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey = _formatDateKey(date);

        Map<String, double> nutritionData;

        // Check cache
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
      _setError('Failed to load weekly nutrition data: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh data after food changes
  Future<void> _refreshAfterFoodChange(DateTime date) async {
    final dateKey = _formatDateKey(date);

    // Clear cache
    _foodItemsCache.remove(dateKey);
    _nutritionSummaryCache.remove(dateKey);

    // Reload data
    if (_isSameDate(date, DateTime.now())) {
      await _loadTodayNutrition();
    }

    if (_isSameDate(date, _selectedDate)) {
      await _loadNutritionForDate(date);
    }
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
      print('NutritionProvider Error: $error');
    }
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear cache
  void clearCache() {
    _foodItemsCache.clear();
    _nutritionSummaryCache.clear();
    notifyListeners();
  }

  /// Format date key
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if same date
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get weekday name
  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  /// Reset all data
  void resetAllData() {
    _selectedDate = DateTime.now();
    _todayFoodItems.clear();
    _selectedDateFoodItems.clear();
    _todayNutritionSummary.clear();
    _selectedDateNutritionSummary.clear();
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

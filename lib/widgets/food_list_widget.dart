// lib/widgets/food_list_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/nutrition_provider.dart';
import '../utils/app_theme.dart';

/// 食物列表组件 - Food List Widget
/// 用于显示食物条目列表，支持按餐次分组、左滑删除等功能
class FoodListWidget extends StatelessWidget {
  final List<FoodItem> foodItems;
  final bool groupByMealType;
  final bool showDate;
  final bool allowDelete;
  final bool allowEdit;
  final Function(FoodItem)? onEdit;
  final Function(FoodItem)? onDelete;
  final Function(String)? onAddToMeal;

  const FoodListWidget({
    super.key,
    required this.foodItems,
    this.groupByMealType = true,
    this.showDate = false,
    this.allowDelete = true,
    this.allowEdit = true,
    this.onEdit,
    this.onDelete,
    this.onAddToMeal,
  });

  @override
  Widget build(BuildContext context) {
    if (foodItems.isEmpty) {
      return _buildEmptyState(context);
    }

    if (groupByMealType) {
      return _buildGroupedList(context);
    } else {
      return _buildSimpleList(context);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No food entries yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your meals to track your nutrition',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-food');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Food'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(BuildContext context) {
    // 按餐次分组食物
    final groupedFoods = _groupFoodsByMealType(foodItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...groupedFoods.entries.map((entry) {
          final mealType = entry.key;
          final mealFoods = entry.value;

          return _buildMealSection(context, mealType, mealFoods);
        }).toList(),
      ],
    );
  }

  Widget _buildSimpleList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foodItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final foodItem = foodItems[index];
        return _buildFoodTile(context, foodItem);
      },
    );
  }

  Widget _buildMealSection(
      BuildContext context, String mealType, List<FoodItem> mealFoods) {
    final mealInfo = _getMealInfo(mealType);
    final totalCalories =
        mealFoods.fold<double>(0, (sum, item) => sum + item.calories);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 餐次标题
          _buildMealHeader(context, mealInfo, totalCalories, mealType),
          // 食物列表
          ...mealFoods.asMap().entries.map((entry) {
            final index = entry.key;
            final foodItem = entry.value;
            final isLast = index == mealFoods.length - 1;

            return Column(
              children: [
                _buildFoodTile(context, foodItem, showDivider: false),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
              ],
            );
          }).toList(),
          // 添加按钮
          _buildAddToMealButton(context, mealType),
        ],
      ),
    );
  }

  Widget _buildMealHeader(BuildContext context, Map<String, dynamic> mealInfo,
      double totalCalories, String mealType) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mealInfo['color'].withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: mealInfo['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mealInfo['icon'],
              color: mealInfo['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealInfo['name'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: mealInfo['color'],
                  ),
                ),
                Text(
                  '${totalCalories.toStringAsFixed(0)} kcal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onAddToMeal?.call(mealType),
            icon: Icon(
              Icons.add_circle_outline,
              color: mealInfo['color'],
            ),
            tooltip: 'Add to ${mealInfo['name']}',
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTile(BuildContext context, FoodItem foodItem,
      {bool showDivider = true}) {
    final theme = Theme.of(context);

    Widget tile = Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 食物信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildNutrientChip(
                      context,
                      '${foodItem.calories.toStringAsFixed(0)} kcal',
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    if (foodItem.protein > 0)
                      _buildNutrientChip(
                        context,
                        'P: ${foodItem.protein.toStringAsFixed(1)}g',
                        Colors.blue,
                      ),
                    const SizedBox(width: 8),
                    if (foodItem.carbs > 0)
                      _buildNutrientChip(
                        context,
                        'C: ${foodItem.carbs.toStringAsFixed(1)}g',
                        Colors.green,
                      ),
                    const SizedBox(width: 8),
                    if (foodItem.fat > 0)
                      _buildNutrientChip(
                        context,
                        'F: ${foodItem.fat.toStringAsFixed(1)}g',
                        Colors.purple,
                      ),
                  ],
                ),
                if (foodItem.quantity != null && foodItem.unit != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${foodItem.quantity} ${foodItem.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
                if (showDate) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(foodItem.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 操作按钮
          if (allowEdit || allowDelete) ...[
            const SizedBox(width: 8),
            _buildActionButtons(context, foodItem),
          ],
        ],
      ),
    );

    // 如果允许删除，包装在 Dismissible 中
    if (allowDelete) {
      tile = Dismissible(
        key: Key('food_${foodItem.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete,
                color: theme.colorScheme.onError,
              ),
              const SizedBox(height: 4),
              Text(
                'Delete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(context, foodItem);
        },
        onDismissed: (direction) {
          _handleDelete(context, foodItem);
        },
        child: tile,
      );
    }

    return tile;
  }

  Widget _buildNutrientChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FoodItem foodItem) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (allowEdit)
          IconButton(
            onPressed: () => _handleEdit(context, foodItem),
            icon: const Icon(Icons.edit_outlined),
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        if (allowDelete)
          IconButton(
            onPressed: () => _handleDelete(context, foodItem),
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
      ],
    );
  }

  Widget _buildAddToMealButton(BuildContext context, String mealType) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _handleAddToMeal(context, mealType),
          icon: const Icon(Icons.add),
          label: Text('Add to ${_getMealInfo(mealType)['name']}'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // 辅助方法
  Map<String, List<FoodItem>> _groupFoodsByMealType(List<FoodItem> foods) {
    final grouped = <String, List<FoodItem>>{};

    // 初始化所有餐次
    for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      grouped[mealType] = [];
    }

    // 分组食物
    for (final food in foods) {
      grouped[food.mealType]?.add(food);
    }

    // 移除空的餐次分组
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  Map<String, dynamic> _getMealInfo(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return {
          'name': 'Breakfast',
          'icon': Icons.wb_sunny_outlined,
          'color': Colors.orange,
        };
      case 'lunch':
        return {
          'name': 'Lunch',
          'icon': Icons.wb_sunny,
          'color': Colors.amber,
        };
      case 'dinner':
        return {
          'name': 'Dinner',
          'icon': Icons.nightlight_round,
          'color': Colors.indigo,
        };
      case 'snack':
        return {
          'name': 'Snack',
          'icon': Icons.local_cafe,
          'color': Colors.green,
        };
      default:
        return {
          'name': 'Other',
          'icon': Icons.restaurant,
          'color': Colors.grey,
        };
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, FoodItem foodItem) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Food Item'),
          content: Text('Are you sure you want to delete "${foodItem.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _handleEdit(BuildContext context, FoodItem foodItem) {
    if (onEdit != null) {
      onEdit!(foodItem);
    } else {
      Navigator.pushNamed(
        context,
        '/add-food',
        arguments: {
          'isEdit': true,
          'foodItem': foodItem,
        },
      );
    }
  }

  void _handleDelete(BuildContext context, FoodItem foodItem) {
    if (onDelete != null) {
      onDelete!(foodItem);
    } else if (foodItem.id != null) {
      // 使用 Provider 删除
      context.read<NutritionProvider>().deleteFoodItem(
            foodItem.id!,
            foodItem.date,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${foodItem.name}"'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: 实现撤销功能
            },
          ),
        ),
      );
    }
  }

  void _handleAddToMeal(BuildContext context, String mealType) {
    if (onAddToMeal != null) {
      onAddToMeal!(mealType);
    } else {
      Navigator.pushNamed(
        context,
        '/add-food',
        arguments: {
          'mealType': mealType,
        },
      );
    }
  }
}

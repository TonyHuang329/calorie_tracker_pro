import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../utils/app_theme.dart';

class MealSection extends StatelessWidget {
  final String mealType;
  final String title;
  final IconData icon;
  final List<FoodItem> foodItems;
  final VoidCallback onAddFood;
  final Function(FoodItem) onFoodTap;
  final Function(FoodItem) onFoodDelete;

  const MealSection({
    super.key,
    required this.mealType,
    required this.title,
    required this.icon,
    required this.foodItems,
    required this.onAddFood,
    required this.onFoodTap,
    required this.onFoodDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCalories = foodItems.fold<double>(
      0.0,
      (sum, item) => sum + item.calories,
    );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 餐次标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (foodItems.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${totalCalories.toInt()} 卡路里',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onAddFood,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    foregroundColor: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // 食物列表
          if (foodItems.isNotEmpty) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: foodItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final foodItem = foodItems[index];
                return _FoodItemTile(
                  foodItem: foodItem,
                  onTap: () => onFoodTap(foodItem),
                  onDelete: () => onFoodDelete(foodItem),
                );
              },
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 32,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无${title}记录',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '点击 + 添加食物',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FoodItemTile extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FoodItemTile({
    required this.foodItem,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('food_${foodItem.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('删除食物'),
            content: Text('确定要删除 "${foodItem.name}" 吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.restaurant,
            size: 20,
            color: theme.primaryColor,
          ),
        ),
        title: Text(
          foodItem.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: _buildSubtitle(context),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${foodItem.calories.toInt()}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            Text(
              '卡路里',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    final macros = [
      '蛋白质 ${foodItem.protein.toStringAsFixed(1)}g',
      '碳水 ${foodItem.carbs.toStringAsFixed(1)}g',
      '脂肪 ${foodItem.fat.toStringAsFixed(1)}g',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (foodItem.formattedQuantity.isNotEmpty)
          Text(
            foodItem.formattedQuantity,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        Text(
          macros.join(' • '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

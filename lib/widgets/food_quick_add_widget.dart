// lib/widgets/food_quick_add_widget.dart

import 'package:flutter/material.dart';
import '../models/food_database_item.dart';
import '../services/food_database_service.dart';
import '../screens/food_search_screen.dart';
import '../screens/add_food_screen.dart';

/// Quick Add Food Widget for Home Screen
/// Shows popular foods for quick selection
class FoodQuickAddWidget extends StatelessWidget {
  final String? mealType;

  const FoodQuickAddWidget({
    super.key,
    this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    final foodService = FoodDatabaseService.instance;
    final popularFoods = foodService.getPopularFoods(limit: 8);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Quick Add Food',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _navigateToSearch(context),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Search All'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Popular foods grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 8,
              ),
              itemCount: popularFoods.length,
              itemBuilder: (context, index) {
                final food = popularFoods[index];
                return _buildQuickAddTile(context, food);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddTile(BuildContext context, FoodDatabaseItem food) {
    final nutrition = food.standardServingNutrition;

    return InkWell(
      onTap: () => _onFoodSelected(context, food),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Food icon
            _buildFoodIcon(context, food.category),
            const SizedBox(width: 12),
            // Food info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    food.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${nutrition['calories']!.toInt()} kcal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            // Add icon
            Icon(
              Icons.add_circle_outline,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodIcon(BuildContext context, String category) {
    IconData iconData;
    Color color;

    switch (category.toLowerCase()) {
      case 'fruits':
        iconData = Icons.apple;
        color = Colors.red;
        break;
      case 'vegetables':
        iconData = Icons.eco;
        color = Colors.green;
        break;
      case 'grains':
        iconData = Icons.grain;
        color = Colors.amber;
        break;
      case 'proteins':
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'dairy':
        iconData = Icons.local_drink;
        color = Colors.blue;
        break;
      case 'nuts & seeds':
        iconData = Icons.scatter_plot;
        color = Colors.brown;
        break;
      case 'beverages':
        iconData = Icons.local_cafe;
        color = Colors.cyan;
        break;
      case 'snacks':
        iconData = Icons.cookie;
        color = Colors.deepOrange;
        break;
      default:
        iconData = Icons.fastfood;
        color = Colors.grey;
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 16),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodSearchScreen(
          initialMealType: mealType,
          initialDate: DateTime.now(),
        ),
      ),
    );
  }

  void _onFoodSelected(BuildContext context, FoodDatabaseItem food) {
    // Navigate directly to AddFoodScreen with pre-filled data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddFoodScreen(),
        settings: RouteSettings(
          arguments: {
            'foodItem': food.toFoodItem(
              mealType: mealType ?? _getCurrentMealType(),
              date: DateTime.now(),
            ),
            'isEdit': false,
            'fromDatabase': true,
            'databaseItem': food,
          },
        ),
      ),
    );
  }

  String _getCurrentMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Breakfast';
    if (hour < 15) return 'Lunch';
    if (hour < 20) return 'Dinner';
    return 'Snack';
  }
}

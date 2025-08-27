// lib/screens/food_search_screen.dart

import 'package:flutter/material.dart';
import '../models/food_database_item.dart';
import '../services/food_database_service.dart';
import 'add_food_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  final String? initialMealType;
  final DateTime? initialDate;

  const FoodSearchScreen({
    super.key,
    this.initialMealType,
    this.initialDate,
  });

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FoodDatabaseService _foodService = FoodDatabaseService.instance;

  late TabController _tabController;
  List<FoodDatabaseItem> _searchResults = [];
  String _currentCategory = 'All';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    final categories = ['All', ..._foodService.categories];
    _tabController = TabController(length: categories.length, vsync: this);

    // Initialize with popular foods
    _searchResults = _foodService.getPopularFoods();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;

      if (_isSearching) {
        _searchResults = _foodService.searchFoods(_searchController.text);
      } else {
        _updateResultsForCategory();
      }
    });
  }

  void _onTabChanged(String category) {
    setState(() {
      _currentCategory = category;
      if (!_isSearching) {
        _updateResultsForCategory();
      }
    });
  }

  void _updateResultsForCategory() {
    if (_currentCategory == 'All') {
      _searchResults = _foodService.getPopularFoods();
    } else {
      _searchResults = _foodService.getFoodsByCategory(_currentCategory);
    }
  }

  void _onFoodSelected(FoodDatabaseItem food) {
    // Navigate to AddFoodScreen with pre-filled data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddFoodScreen(),
        settings: RouteSettings(
          arguments: {
            'foodItem': food.toFoodItem(
              mealType: widget.initialMealType ?? _getCurrentMealType(),
              date: widget.initialDate ?? DateTime.now(),
            ),
            'isEdit': false,
            'fromDatabase': true,
            'databaseItem':
                food, // Pass original database item for serving adjustment
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

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ..._foodService.categories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Foods'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category tabs
          if (!_isSearching) ...[
            Container(
              height: 50,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                onTap: (index) => _onTabChanged(categories[index]),
                tabs:
                    categories.map((category) => Tab(text: category)).toList(),
              ),
            ),
          ],

          // Results section
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearching ? Icons.search_off : Icons.restaurant_menu,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching ? 'No foods found' : 'No foods in this category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (_isSearching) ...[
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return _buildFoodTile(food);
      },
    );
  }

  Widget _buildFoodTile(FoodDatabaseItem food) {
    final standardNutrition = food.standardServingNutrition;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildFoodIcon(food.category),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Per ${food.servingSize.toInt()}${food.unit} serving',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                _buildNutrientChip(
                  '${standardNutrition['calories']!.toInt()} kcal',
                  Colors.orange,
                ),
                if (standardNutrition['protein']! > 0)
                  _buildNutrientChip(
                    'P: ${standardNutrition['protein']!.toStringAsFixed(1)}g',
                    Colors.blue,
                  ),
                if (standardNutrition['carbs']! > 0)
                  _buildNutrientChip(
                    'C: ${standardNutrition['carbs']!.toStringAsFixed(1)}g',
                    Colors.green,
                  ),
                if (standardNutrition['fat']! > 0)
                  _buildNutrientChip(
                    'F: ${standardNutrition['fat']!.toStringAsFixed(1)}g',
                    Colors.purple,
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.add_circle_outline),
        onTap: () => _onFoodSelected(food),
      ),
    );
  }

  Widget _buildFoodIcon(String category) {
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
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildNutrientChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

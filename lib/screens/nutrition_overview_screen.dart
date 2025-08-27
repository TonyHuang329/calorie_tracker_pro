// lib/screens/nutrition_overview_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/nutrition_card.dart';
import '../widgets/food_list_widget.dart';
import '../utils/app_theme.dart';

/// 营养概览页面 - Nutrition Overview Screen
/// 主页仪表盘，显示今日营养摄入概况和食物列表
class NutritionOverviewScreen extends StatefulWidget {
  const NutritionOverviewScreen({super.key});

  @override
  State<NutritionOverviewScreen> createState() =>
      _NutritionOverviewScreenState();
}

class _NutritionOverviewScreenState extends State<NutritionOverviewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final nutritionProvider = context.read<NutritionProvider>();
    final userProvider = context.read<UserProvider>();

    // 并行加载用户数据和营养数据
    await Future.wait([
      nutritionProvider.loadTodayNutrition(),
      userProvider.loadUserProfile(),
      userProvider.loadCurrentHealthGoal(),
    ]);
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCalorieSection(context),
                  const SizedBox(height: 24),
                  _buildNutritionSection(context),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(context),
                  const SizedBox(height: 24),
                  _buildFoodListSection(context),
                  const SizedBox(height: 80), // 底部导航栏空间
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final userName = userProvider.userProfile?.name ?? 'User';
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  _getDateString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: 'Profile',
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/history'),
          icon: const Icon(Icons.history),
          tooltip: 'History',
        ),
      ],
    );
  }

  Widget _buildCalorieSection(BuildContext context) {
    return Consumer2<UserProvider, NutritionProvider>(
      builder: (context, userProvider, nutritionProvider, child) {
        final goal = userProvider.currentHealthGoal;
        final consumed = nutritionProvider.todayTotalCalories;
        final target = goal?.targetCalories ?? 2000;

        if (nutritionProvider.isLoading) {
          return _buildLoadingCard(context);
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                CircularProgressWidget(
                  current: consumed,
                  target: target,
                  title: 'Daily Calories',
                  unit: 'kcal',
                  size: 180,
                ),
                const SizedBox(height: 16),
                _buildCalorieStats(context, consumed, target),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalorieStats(
      BuildContext context, double consumed, double target) {
    final remaining = (target - consumed).clamp(0, double.infinity);
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          'Consumed',
          '${consumed.toStringAsFixed(0)}',
          'kcal',
          theme.colorScheme.primary,
        ),
        _buildStatItem(
          context,
          'Remaining',
          '${remaining.toStringAsFixed(0)}',
          'kcal',
          remaining > 0 ? Colors.green : Colors.orange,
        ),
        _buildStatItem(
          context,
          'Goal',
          '${target.toStringAsFixed(0)}',
          'kcal',
          theme.colorScheme.outline,
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      String unit, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            children: [
              TextSpan(
                text: ' $unit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSection(BuildContext context) {
    return Consumer2<UserProvider, NutritionProvider>(
      builder: (context, userProvider, nutritionProvider, child) {
        final goal = userProvider.currentHealthGoal;

        if (goal == null) {
          return _buildGoalSetupCard(context);
        }

        if (nutritionProvider.isLoading) {
          return _buildLoadingCard(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NutritionCard(
                    title: 'Protein',
                    current: nutritionProvider.todayTotalProtein,
                    target: goal.targetProtein,
                    unit: 'g',
                    color: AppTheme.getProteinColor(context),
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NutritionCard(
                    title: 'Carbs',
                    current: nutritionProvider.todayTotalCarbs,
                    target: goal.targetCarbs,
                    unit: 'g',
                    color: AppTheme.getCarbsColor(context),
                    icon: Icons.grain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NutritionCard(
                    title: 'Fat',
                    current: nutritionProvider.todayTotalFat,
                    target: goal.targetFat,
                    unit: 'g',
                    color: AppTheme.getFatColor(context),
                    icon: Icons.opacity,
                  ),
                ),
                Expanded(
                  child: Container(), // 占位空间，保持布局平衡
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Add Food',
                'Log detailed meal',
                Icons.restaurant_menu,
                Colors.blue,
                () => Navigator.pushNamed(context, '/add-food'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Quick Add',
                'Fast calorie entry',
                Icons.flash_on,
                Colors.orange,
                () => Navigator.pushNamed(context, '/quick-add'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodListSection(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Meals',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (nutritionProvider.isLoading)
              _buildLoadingCard(context)
            else
              FoodListWidget(
                foodItems: nutritionProvider.todayFoodItems,
                groupByMealType: true,
                allowDelete: true,
                allowEdit: true,
                onAddToMeal: (mealType) {
                  Navigator.pushNamed(
                    context,
                    '/add-food',
                    arguments: {'mealType': mealType},
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildGoalSetupCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.track_changes,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Set Your Health Goals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your daily calorie and nutrition targets to start tracking your progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/goals'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Set Goals'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddFoodOptions(context),
      icon: const Icon(Icons.add),
      label: const Text('Add Food'),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _showAddFoodOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Food',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant_menu, color: Colors.blue),
              ),
              title: const Text('Add Food'),
              subtitle: const Text('Log detailed meal with nutrition info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-food');
              },
            ),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flash_on, color: Colors.orange),
              ),
              title: const Text('Quick Add'),
              subtitle: const Text('Fast calorie entry'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/quick-add');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

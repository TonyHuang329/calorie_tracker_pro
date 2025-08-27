import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/nutrition_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/nutrition_card.dart';
import '../widgets/meal_section.dart';
import '../widgets/quick_add_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final nutritionProvider =
        Provider.of<NutritionProvider>(context, listen: false);

    await Future.wait([
      userProvider.loadUserProfile(),
      userProvider.loadCurrentHealthGoal(),
      nutritionProvider.loadTodayNutrition(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeContent(),
          _HistoryContent(),
          _StatsContent(),
          _ProfileContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton:
          _currentIndex == 0 ? _buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '主页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: '历史',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: '统计',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '设置',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/add-food');
      },
      child: const Icon(Icons.add),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildCalorieProgress(context),
            const SizedBox(height: 24),
            _buildNutritionOverview(context),
            const SizedBox(height: 24),
            const QuickAddButtons(),
            const SizedBox(height: 24),
            _buildMealSections(context),
            const SizedBox(height: 80), // 底部留白，避免被FAB遮挡
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.userProfile?.name ?? '用户';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你好，$userName',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDateString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                // 显示通知或设置
              },
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalorieProgress(BuildContext context) {
    return Consumer2<UserProvider, NutritionProvider>(
      builder: (context, userProvider, nutritionProvider, child) {
        final goal = userProvider.currentHealthGoal;
        final consumed = nutritionProvider.todayTotalCalories;
        final target = goal?.targetCalories ?? 2000;

        return Card(
          child: Padding(
            padding: AppTheme.getCardPadding(context),
            child: CircularProgressWidget(
              current: consumed,
              target: target,
              title: '今日卡路里',
              unit: 'kcal',
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionOverview(BuildContext context) {
    return Consumer2<UserProvider, NutritionProvider>(
      builder: (context, userProvider, nutritionProvider, child) {
        final goal = userProvider.currentHealthGoal;

        if (goal == null) {
          return Card(
            child: Padding(
              padding: AppTheme.getCardPadding(context),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '请先设置健康目标',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/goals');
                    },
                    child: const Text('设置目标'),
                  ),
                ],
              ),
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: NutritionCard(
                title: '蛋白质',
                current: nutritionProvider.todayTotalProtein,
                target: goal.targetProtein,
                unit: 'g',
                color: AppTheme.getProteinColor(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NutritionCard(
                title: '碳水',
                current: nutritionProvider.todayTotalCarbs,
                target: goal.targetCarbs,
                unit: 'g',
                color: AppTheme.getCarbsColor(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NutritionCard(
                title: '脂肪',
                current: nutritionProvider.todayTotalFat,
                target: goal.targetFat,
                unit: 'g',
                color: AppTheme.getFatColor(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealSections(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final mealTypes = [
          {'type': 'breakfast', 'title': '早餐', 'icon': Icons.wb_sunny},
          {'type': 'lunch', 'title': '午餐', 'icon': Icons.wb_sunny_outlined},
          {'type': 'dinner', 'title': '晚餐', 'icon': Icons.nights_stay},
          {'type': 'snack', 'title': '零食', 'icon': Icons.cookie},
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日饮食',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...mealTypes
                .map((meal) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MealSection(
                        mealType: meal['type'] as String,
                        title: meal['title'] as String,
                        icon: meal['icon'] as IconData,
                        foodItems: nutritionProvider
                            .getFoodItemsByMealType(meal['type'] as String),
                        onAddFood: () =>
                            _addFood(context, meal['type'] as String),
                        onFoodTap: (foodItem) => _editFood(context, foodItem),
                        onFoodDelete: (foodItem) =>
                            _deleteFood(context, nutritionProvider, foodItem),
                      ),
                    ))
                .toList(),
          ],
        );
      },
    );
  }

  void _addFood(BuildContext context, String mealType) {
    Navigator.pushNamed(
      context,
      '/add-food',
      arguments: {'mealType': mealType},
    );
  }

  void _editFood(BuildContext context, foodItem) {
    Navigator.pushNamed(
      context,
      '/add-food',
      arguments: {'foodItem': foodItem, 'isEdit': true},
    );
  }

  void _deleteFood(
      BuildContext context, NutritionProvider provider, foodItem) async {
    final result = await showDialog<bool>(
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
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (result == true && foodItem.id != null) {
      final success =
          await provider.deleteFoodItem(foodItem.id!, foodItem.date);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('食物已删除')),
        );
      }
    }
  }

  String _getDateString() {
    final now = DateTime.now();
    final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    final weekday = weekdays[now.weekday - 1];

    return '${now.month}月${now.day}日 $weekday';
  }
}

// 临时的占位页面
class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('历史记录页面', style: TextStyle(fontSize: 18)),
          Text('即将推出...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('数据统计页面', style: TextStyle(fontSize: 18)),
          Text('即将推出...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('个人设置页面', style: TextStyle(fontSize: 18)),
          const Text('即将推出...', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: const Text('编辑个人资料'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/goals');
            },
            child: const Text('设置健康目标'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/user_provider.dart';
import '../screens/chart_display_screen.dart';
import '../widgets/nutrition_charts_widget.dart';

/// Nutrition Summary Widget
/// Displays a compact overview of daily nutrition data
class NutritionSummaryWidget extends StatefulWidget {
  final DateTime? date;
  final bool showTitle;
  final bool showActions;
  final bool isCompact;
  final VoidCallback? onTap;

  const NutritionSummaryWidget({
    super.key,
    this.date,
    this.showTitle = true,
    this.showActions = true,
    this.isCompact = false,
    this.onTap,
  });

  @override
  State<NutritionSummaryWidget> createState() => _NutritionSummaryWidgetState();
}

class _NutritionSummaryWidgetState extends State<NutritionSummaryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NutritionProvider, UserProvider>(
      builder: (context, nutritionProvider, userProvider, child) {
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) {
                  _animationController.reverse();
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                onTapCancel: () => _animationController.reverse(),
                child: Card(
                  elevation: widget.isCompact ? 1 : 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(widget.isCompact ? 12 : 16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(widget.isCompact ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showTitle) _buildHeader(),
                        if (widget.showTitle)
                          SizedBox(height: widget.isCompact ? 12 : 16),
                        _buildCalorieSection(nutritionProvider, userProvider),
                        SizedBox(height: widget.isCompact ? 12 : 16),
                        _buildMacroSection(nutritionProvider, userProvider),
                        if (!widget.isCompact) ...[
                          const SizedBox(height: 16),
                          _buildProgressSection(
                              nutritionProvider, userProvider),
                        ],
                        if (widget.showActions && !widget.isCompact) ...[
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
                size: widget.isCompact ? 16 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDateTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!widget.isCompact)
                  Text(
                    _getDateSubtitle(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
              ],
            ),
          ],
        ),
        if (widget.showActions)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: widget.isCompact ? 16 : 20,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_details',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_food',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add Food'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'set_goal',
                child: Row(
                  children: [
                    Icon(Icons.flag),
                    SizedBox(width: 8),
                    Text('Set Goals'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCalorieSection(
      NutritionProvider nutritionProvider, UserProvider userProvider) {
    final currentCalories = _getCurrentCalories(nutritionProvider);
    final targetCalories =
        userProvider.currentHealthGoal?.targetCalories ?? 2000.0;
    final remaining =
        (targetCalories - currentCalories).clamp(0.0, double.infinity);
    final percentage =
        (currentCalories / targetCalories * 100).clamp(0.0, 100.0);

    return Container(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calories',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${currentCalories.toInt()}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    Text(
                      ' / ${targetCalories.toInt()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
                if (!widget.isCompact) ...[
                  const SizedBox(height: 4),
                  Text(
                    remaining > 0
                        ? '${remaining.toInt()} remaining'
                        : 'Goal reached!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: remaining > 0
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (!widget.isCompact) _buildCalorieProgressCircle(percentage),
        ],
      ),
    );
  }

  Widget _buildCalorieProgressCircle(double percentage) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 6,
            backgroundColor:
                Theme.of(context).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCalorieProgressColor(percentage),
            ),
          ),
          Center(
            child: Text(
              '${percentage.toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSection(
      NutritionProvider nutritionProvider, UserProvider userProvider) {
    final currentProtein = _getCurrentProtein(nutritionProvider);
    final currentCarbs = _getCurrentCarbs(nutritionProvider);
    final currentFat = _getCurrentFat(nutritionProvider);

    final targetProtein =
        userProvider.currentHealthGoal?.targetProtein ?? 150.0;
    final targetCarbs = userProvider.currentHealthGoal?.targetCarbs ?? 250.0;
    final targetFat = userProvider.currentHealthGoal?.targetFat ?? 65.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Macronutrients',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: widget.isCompact ? 8 : 12),
        if (widget.isCompact)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroChip('P', currentProtein, targetProtein, 'g',
                  Theme.of(context).colorScheme.primary),
              _buildMacroChip('C', currentCarbs, targetCarbs, 'g',
                  Theme.of(context).colorScheme.secondary),
              _buildMacroChip('F', currentFat, targetFat, 'g',
                  Theme.of(context).colorScheme.tertiary),
            ],
          )
        else
          Column(
            children: [
              _buildMacroBar('Protein', currentProtein, targetProtein, 'g',
                  Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              _buildMacroBar('Carbs', currentCarbs, targetCarbs, 'g',
                  Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 8),
              _buildMacroBar('Fat', currentFat, targetFat, 'g',
                  Theme.of(context).colorScheme.tertiary),
            ],
          ),
      ],
    );
  }

  Widget _buildMacroChip(
      String label, double current, double target, String unit, Color color) {
    final percentage = (current / target * 100).clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            '${current.toInt()}$unit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            '${percentage.toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(
      String name, double current, double target, String unit, Color color) {
    final percentage = (current / target).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${current.toInt()}$unit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${target.toInt()}$unit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor:
                    Theme.of(context).colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
      NutritionProvider nutritionProvider, UserProvider userProvider) {
    final currentCalories = _getCurrentCalories(nutritionProvider);
    final targetCalories =
        userProvider.currentHealthGoal?.targetCalories ?? 2000.0;
    final foodItemsCount = _getCurrentFoodItems(nutritionProvider).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildProgressItem(
            Icons.restaurant,
            '$foodItemsCount',
            'meals logged',
          ),
          _buildProgressItem(
            Icons.trending_up,
            '${((currentCalories / targetCalories * 100)).toInt()}%',
            'of goal',
          ),
          _buildProgressItem(
            Icons.schedule,
            _getLastMealTime(nutritionProvider),
            'last meal',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToChartDetails(ChartType.dailyMacrosPie),
            icon: const Icon(Icons.pie_chart, size: 18),
            label: const Text('View Charts'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _navigateToAddFood(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Food'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_details':
        _navigateToChartDetails(ChartType.dailyMacrosPie);
        break;
      case 'add_food':
        _navigateToAddFood();
        break;
      case 'set_goal':
        _navigateToGoals();
        break;
    }
  }

  void _navigateToChartDetails(ChartType chartType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartDisplayScreen(
          chartType: chartType,
          title: _getChartTitle(chartType),
        ),
      ),
    );
  }

  void _navigateToAddFood() {
    Navigator.pushNamed(context, '/add-food');
  }

  void _navigateToGoals() {
    Navigator.pushNamed(context, '/goals');
  }

  String _getDateTitle() {
    if (widget.date == null) return 'Today\'s Nutrition';

    final now = DateTime.now();
    final targetDate = widget.date!;

    if (targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day) {
      return 'Today\'s Nutrition';
    } else if (targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day - 1) {
      return 'Yesterday\'s Nutrition';
    } else {
      return 'Nutrition Summary';
    }
  }

  String _getDateSubtitle() {
    if (widget.date == null) return _formatDate(DateTime.now());
    return _formatDate(widget.date!);
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getChartTitle(ChartType chartType) {
    switch (chartType) {
      case ChartType.dailyMacrosPie:
        return 'Macronutrient Distribution';
      case ChartType.weeklyCalories:
        return 'Weekly Calorie Trends';
      case ChartType.weeklyMacros:
        return 'Weekly Macro Trends';
      case ChartType.mealDistribution:
        return 'Meal Distribution';
    }
  }

  double _getCurrentCalories(NutritionProvider provider) {
    return widget.date == null
        ? provider.todayTotalCalories
        : provider.selectedDateTotalCalories;
  }

  double _getCurrentProtein(NutritionProvider provider) {
    return widget.date == null
        ? provider.todayTotalProtein
        : provider.selectedDateTotalProtein;
  }

  double _getCurrentCarbs(NutritionProvider provider) {
    return widget.date == null
        ? provider.todayTotalCarbs
        : provider.selectedDateTotalCarbs;
  }

  double _getCurrentFat(NutritionProvider provider) {
    return widget.date == null
        ? provider.todayTotalFat
        : provider.selectedDateTotalFat;
  }

  List _getCurrentFoodItems(NutritionProvider provider) {
    return widget.date == null
        ? provider.todayFoodItems
        : provider.selectedDateFoodItems;
  }

  String _getLastMealTime(NutritionProvider provider) {
    final foodItems = _getCurrentFoodItems(provider);
    if (foodItems.isEmpty) return 'None';

    // This is a placeholder - in real implementation, you'd get the actual time
    return '2h ago';
  }

  Color _getCalorieProgressColor(double percentage) {
    if (percentage < 50) return Colors.red;
    if (percentage < 80) return Colors.orange;
    if (percentage <= 110) return Colors.green;
    return Colors.orange;
  }
}

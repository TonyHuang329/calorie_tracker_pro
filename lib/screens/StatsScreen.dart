import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/nutrition_charts_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedPeriodStart =
      DateTime.now().subtract(const Duration(days: 6));
  DateTime _selectedPeriodEnd = DateTime.now();
  PeriodType _currentPeriod = PeriodType.week;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final nutritionProvider =
          Provider.of<NutritionProvider>(context, listen: false);
      await nutritionProvider.loadTodayNutrition();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changePeriod(PeriodType periodType) {
    setState(() {
      _currentPeriod = periodType;

      final now = DateTime.now();
      switch (periodType) {
        case PeriodType.week:
          _selectedPeriodStart = now.subtract(const Duration(days: 6));
          _selectedPeriodEnd = now;
        case PeriodType.month:
          _selectedPeriodStart = DateTime(now.year, now.month - 1, now.day);
          _selectedPeriodEnd = now;
        case PeriodType.quarter:
          _selectedPeriodStart = now.subtract(const Duration(days: 90));
          _selectedPeriodEnd = now;
        case PeriodType.custom:
          // Keep current custom dates
          break;
      }
    });
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedPeriodStart,
        end: _selectedPeriodEnd,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedPeriodStart = picked.start;
        _selectedPeriodEnd = picked.end;
        _currentPeriod = PeriodType.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildPeriodSelector(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildTrendsTab(),
                      _buildAnalyticsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Statistics'),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _selectCustomDateRange,
          tooltip: 'Select Date Range',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'export':
                _exportData();
                break;
              case 'share':
                _shareStats();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Export Data'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share Stats'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Period',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodChip('Week', PeriodType.week),
                const SizedBox(width: 8),
                _buildPeriodChip('Month', PeriodType.month),
                const SizedBox(width: 8),
                _buildPeriodChip('3 Months', PeriodType.quarter),
                const SizedBox(width: 8),
                _buildPeriodChip('Custom', PeriodType.custom),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatPeriodRange(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, PeriodType periodType) {
    final isSelected = _currentPeriod == periodType;

    return GestureDetector(
      onTap: () => periodType == PeriodType.custom
          ? _selectCustomDateRange()
          : _changePeriod(periodType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.dashboard),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(Icons.trending_up),
            text: 'Trends',
          ),
          Tab(
            icon: Icon(Icons.analytics),
            text: 'Analytics',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 20),

          // Today's macros pie chart
          const NutritionChartsWidget(
            chartType: ChartType.dailyMacrosPie,
          ),

          const SizedBox(height: 20),

          // Meal distribution
          const NutritionChartsWidget(
            chartType: ChartType.mealDistribution,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekly calories chart
          NutritionChartsWidget(
            chartType: ChartType.weeklyCalories,
            startDate: _selectedPeriodStart,
            endDate: _selectedPeriodEnd,
          ),

          const SizedBox(height: 20),

          // Weekly macros trend
          NutritionChartsWidget(
            chartType: ChartType.weeklyMacros,
            startDate: _selectedPeriodStart,
            endDate: _selectedPeriodEnd,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer2<NutritionProvider, UserProvider>(
      builder: (context, nutritionProvider, userProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreaksCard(),
              const SizedBox(height: 16),
              _buildAveragesCard(),
              const SizedBox(height: 16),
              _buildGoalsProgressCard(),
              const SizedBox(height: 16),
              _buildInsightsCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    return Consumer2<NutritionProvider, UserProvider>(
      builder: (context, nutritionProvider, userProvider, child) {
        final todayCalories = nutritionProvider.todayTotalCalories;
        final todayProtein = nutritionProvider.todayTotalProtein;
        final todayCarbs = nutritionProvider.todayTotalCarbs;
        final todayFat = nutritionProvider.todayTotalFat;
        final targetCalories =
            userProvider.currentHealthGoal?.targetCalories ?? 2000.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Calories',
                    '${todayCalories.toInt()}',
                    'cal',
                    Icons.local_fire_department,
                    Theme.of(context).colorScheme.primary,
                    subtitle: '${targetCalories.toInt()} target',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Protein',
                    '${todayProtein.toInt()}',
                    'g',
                    Icons.fitness_center,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Carbs',
                    '${todayCarbs.toInt()}',
                    'g',
                    Icons.grain,
                    Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Fat',
                    '${todayFat.toInt()}',
                    'g',
                    Icons.opacity,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tracking Streaks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStreakItem('Current', 7, 'days'),
                ),
                Expanded(
                  child: _buildStreakItem('Best', 23, 'days'),
                ),
                Expanded(
                  child: _buildStreakItem('Total', 156, 'days'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(String label, int value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }

  Widget _buildAveragesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Averages (${_getPeriodLabel()})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildAverageItem('Calories', 1850, 'cal/day')),
                Expanded(child: _buildAverageItem('Protein', 95, 'g/day')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildAverageItem('Carbs', 220, 'g/day')),
                Expanded(child: _buildAverageItem('Fat', 65, 'g/day')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageItem(String label, int value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '$value $unit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildGoalsProgressCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final goal = userProvider.currentHealthGoal;
        if (goal == null) return const SizedBox.shrink();

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.track_changes,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Goals Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressItem('Daily Calories', 0.75, '75%'),
                const SizedBox(height: 12),
                _buildProgressItem('Protein Target', 0.65, '65%'),
                const SizedBox(height: 12),
                _buildProgressItem('Carbs Target', 0.80, '80%'),
                const SizedBox(height: 12),
                _buildProgressItem('Fat Target', 0.90, '90%'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(String label, double progress, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              percentage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor:
              Theme.of(context).colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insights & Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              Icons.trending_up,
              'Great job!',
              'You\'ve been consistent with your calorie tracking this week.',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.restaurant,
              'Breakfast boost',
              'Consider adding more protein to your breakfast meals.',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.schedule,
              'Timing tip',
              'Your heaviest meals are typically at dinner. Try balancing throughout the day.',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
      IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPeriodRange() {
    final start = _selectedPeriodStart;
    final end = _selectedPeriodEnd;

    if (start.year == end.year && start.month == end.month) {
      return '${start.month}/${start.day} - ${end.month}/${end.day}/${end.year}';
    } else {
      return '${start.month}/${start.day}/${start.year} - ${end.month}/${end.day}/${end.year}';
    }
  }

  String _getPeriodLabel() {
    switch (_currentPeriod) {
      case PeriodType.week:
        return 'Past Week';
      case PeriodType.month:
        return 'Past Month';
      case PeriodType.quarter:
        return 'Past 3 Months';
      case PeriodType.custom:
        return 'Selected Period';
    }
  }

  void _exportData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
      ),
    );
  }

  void _shareStats() {
    // TODO: Implement stats sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }
}

enum PeriodType {
  week,
  month,
  quarter,
  custom,
}

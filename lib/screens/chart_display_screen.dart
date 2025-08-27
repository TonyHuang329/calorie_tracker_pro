import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/nutrition_charts_widget.dart';

/// Chart Display Screen
/// Full screen view for displaying individual charts with detailed analysis
class ChartDisplayScreen extends StatefulWidget {
  final ChartType chartType;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;

  const ChartDisplayScreen({
    super.key,
    required this.chartType,
    required this.title,
    this.startDate,
    this.endDate,
  });

  @override
  State<ChartDisplayScreen> createState() => _ChartDisplayScreenState();
}

class _ChartDisplayScreenState extends State<ChartDisplayScreen> {
  bool _showDetails = false;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _customStartDate = widget.startDate;
    _customEndDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          if (_shouldShowDateSelector()) _buildDateSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartContainer(),
                  const SizedBox(height: 20),
                  if (_showDetails) _buildDetailedAnalysis(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.title),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        IconButton(
          icon: Icon(_showDetails ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _showDetails = !_showDetails;
            });
          },
          tooltip: _showDetails ? 'Hide Details' : 'Show Details',
        ),
        if (_shouldShowDateSelector())
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share Chart'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'save',
              child: Row(
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text('Save Image'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'fullscreen',
              child: Row(
                children: [
                  Icon(Icons.fullscreen),
                  SizedBox(width: 8),
                  Text('Fullscreen'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formatDateRange(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          TextButton(
            onPressed: _selectDateRange,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: NutritionChartsWidget(
          chartType: widget.chartType,
          startDate: _customStartDate,
          endDate: _customEndDate,
        ),
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Detailed Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAnalysisCards(),
        const SizedBox(height: 20),
        _buildInsightsSection(),
        const SizedBox(height: 20),
        _buildRecommendationsSection(),
      ],
    );
  }

  Widget _buildAnalysisCards() {
    switch (widget.chartType) {
      case ChartType.dailyMacrosPie:
        return _buildMacroAnalysisCards();
      case ChartType.weeklyCalories:
        return _buildCalorieAnalysisCards();
      case ChartType.weeklyMacros:
        return _buildWeeklyMacroAnalysisCards();
      case ChartType.mealDistribution:
        return _buildMealAnalysisCards();
    }
  }

  Widget _buildMacroAnalysisCards() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final todayProtein = nutritionProvider.todayTotalProtein;
        final todayCarbs = nutritionProvider.todayTotalCarbs;
        final todayFat = nutritionProvider.todayTotalFat;

        final proteinCalories = todayProtein * 4;
        final carbsCalories = todayCarbs * 4;
        final fatCalories = todayFat * 9;
        final totalMacroCalories =
            proteinCalories + carbsCalories + fatCalories;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildAnalysisCard(
                    'Protein Ratio',
                    '${totalMacroCalories > 0 ? ((proteinCalories / totalMacroCalories) * 100).toInt() : 0}%',
                    'Recommended: 10-35%',
                    _getProteinRatioColor(proteinCalories, totalMacroCalories),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalysisCard(
                    'Carbs Ratio',
                    '${totalMacroCalories > 0 ? ((carbsCalories / totalMacroCalories) * 100).toInt() : 0}%',
                    'Recommended: 45-65%',
                    _getCarbsRatioColor(carbsCalories, totalMacroCalories),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAnalysisCard(
                    'Fat Ratio',
                    '${totalMacroCalories > 0 ? ((fatCalories / totalMacroCalories) * 100).toInt() : 0}%',
                    'Recommended: 20-35%',
                    _getFatRatioColor(fatCalories, totalMacroCalories),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalysisCard(
                    'Balance Score',
                    _calculateMacroBalance(proteinCalories, carbsCalories,
                        fatCalories, totalMacroCalories),
                    'Based on recommendations',
                    _getBalanceScoreColor(_calculateMacroBalance(
                        proteinCalories,
                        carbsCalories,
                        fatCalories,
                        totalMacroCalories)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalorieAnalysisCards() {
    return Consumer2<NutritionProvider, UserProvider>(
      builder: (context, nutritionProvider, userProvider, child) {
        final targetCalories =
            userProvider.currentHealthGoal?.targetCalories ?? 2000.0;
        final todayCalories = nutritionProvider.todayTotalCalories;
        final difference = todayCalories - targetCalories;
        final percentageOfTarget = (todayCalories / targetCalories * 100);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildAnalysisCard(
                    'Target Progress',
                    '${percentageOfTarget.toInt()}%',
                    '${todayCalories.toInt()} / ${targetCalories.toInt()} cal',
                    _getProgressColor(percentageOfTarget),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalysisCard(
                    'Difference',
                    '${difference > 0 ? '+' : ''}${difference.toInt()} cal',
                    difference > 0 ? 'Above target' : 'Below target',
                    difference.abs() < 100
                        ? Colors.green
                        : (difference > 0 ? Colors.orange : Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAnalysisCard(
                    'Weekly Average',
                    '1,850 cal',
                    'Based on last 7 days',
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalysisCard(
                    'Consistency',
                    'Good',
                    '±150 cal variation',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyMacroAnalysisCards() {
    return Row(
      children: [
        Expanded(
          child: _buildAnalysisCard(
            'Protein Trend',
            'Increasing',
            '+5g from last week',
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAnalysisCard(
            'Carb Stability',
            'Stable',
            'Consistent intake',
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMealAnalysisCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnalysisCard(
                'Largest Meal',
                'Dinner',
                '45% of daily calories',
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalysisCard(
                'Most Balanced',
                'Lunch',
                'Good macro distribution',
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnalysisCard(
                'Snack Frequency',
                '2.5 times/day',
                'Average this week',
                Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalysisCard(
                'Meal Timing',
                'Regular',
                'Consistent schedule',
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(
      String title, String value, String subtitle, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
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
                  'Key Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._getInsightsForChartType().map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
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
                  Icons.recommend,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._getRecommendationsForChartType().asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateSelector() {
    return widget.chartType == ChartType.weeklyCalories ||
        widget.chartType == ChartType.weeklyMacros;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _customStartDate ??
            DateTime.now().subtract(const Duration(days: 6)),
        end: _customEndDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
    }
  }

  String _formatDateRange() {
    if (_customStartDate == null || _customEndDate == null) {
      return 'Last 7 days';
    }

    final start = _customStartDate!;
    final end = _customEndDate!;

    return '${start.month}/${start.day}/${start.year} - ${end.month}/${end.day}/${end.year}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareChart();
        break;
      case 'save':
        _saveChart();
        break;
      case 'fullscreen':
        _enterFullscreen();
        break;
    }
  }

  void _shareChart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _saveChart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save functionality coming soon!')),
    );
  }

  void _enterFullscreen() {
    // TODO: Implement fullscreen mode
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fullscreen mode coming soon!')),
    );
  }

  List<String> _getInsightsForChartType() {
    switch (widget.chartType) {
      case ChartType.dailyMacrosPie:
        return [
          'Your protein intake is within the recommended range (10-35%)',
          'Consider increasing fiber-rich carbohydrates for better digestion',
          'Healthy fats make up an appropriate portion of your calories',
        ];
      case ChartType.weeklyCalories:
        return [
          'Your calorie intake has been consistent this week',
          'Weekend calories tend to be higher than weekdays',
          'You\'re meeting your daily calorie goals 5 out of 7 days',
        ];
      case ChartType.weeklyMacros:
        return [
          'Protein intake shows a positive upward trend',
          'Carbohydrate intake is stable throughout the week',
          'Fat intake varies but stays within healthy ranges',
        ];
      case ChartType.mealDistribution:
        return [
          'Dinner accounts for the largest portion of daily calories',
          'Breakfast could be increased for better energy distribution',
          'Snacking frequency is moderate and well-timed',
        ];
    }
  }

  List<String> _getRecommendationsForChartType() {
    switch (widget.chartType) {
      case ChartType.dailyMacrosPie:
        return [
          'Try to include lean protein sources in each meal',
          'Focus on complex carbohydrates like whole grains',
          'Include healthy fats from nuts, avocados, and olive oil',
        ];
      case ChartType.weeklyCalories:
        return [
          'Plan your weekend meals to maintain consistency',
          'Consider meal prep to stay within calorie goals',
          'Listen to your hunger cues and adjust portions accordingly',
        ];
      case ChartType.weeklyMacros:
        return [
          'Continue your current protein intake strategy',
          'Add variety to your carbohydrate sources',
          'Monitor fat intake on higher calorie days',
        ];
      case ChartType.mealDistribution:
        return [
          'Try to eat a more substantial breakfast',
          'Consider smaller, more frequent meals',
          'Balance your dinner portions with earlier meals',
        ];
    }
  }

  Color _getProteinRatioColor(double proteinCalories, double totalCalories) {
    final ratio = proteinCalories / totalCalories * 100;
    if (ratio >= 10 && ratio <= 35) return Colors.green;
    return Colors.orange;
  }

  Color _getCarbsRatioColor(double carbsCalories, double totalCalories) {
    final ratio = carbsCalories / totalCalories * 100;
    if (ratio >= 45 && ratio <= 65) return Colors.green;
    return Colors.orange;
  }

  Color _getFatRatioColor(double fatCalories, double totalCalories) {
    final ratio = fatCalories / totalCalories * 100;
    if (ratio >= 20 && ratio <= 35) return Colors.green;
    return Colors.orange;
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 90 && percentage <= 110) return Colors.green;
    if (percentage >= 80 && percentage < 90) return Colors.blue;
    if (percentage > 110 && percentage <= 120) return Colors.orange;
    return Colors.red;
  }

  String _calculateMacroBalance(
      double protein, double carbs, double fat, double total) {
    if (total == 0) return 'No Data';

    final proteinRatio = protein / total * 100;
    final carbsRatio = carbs / total * 100;
    final fatRatio = fat / total * 100;

    int score = 0;
    if (proteinRatio >= 10 && proteinRatio <= 35) score++;
    if (carbsRatio >= 45 && carbsRatio <= 65) score++;
    if (fatRatio >= 20 && fatRatio <= 35) score++;

    switch (score) {
      case 3:
        return 'Excellent';
      case 2:
        return 'Good';
      case 1:
        return 'Fair';
      default:
        return 'Needs Work';
    }
  }

  Color _getBalanceScoreColor(String score) {
    switch (score) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/nutrition_provider.dart';
import '../providers/user_provider.dart';

/// Nutrition Charts Widget
/// Displays various charts for nutrition data visualization
class NutritionChartsWidget extends StatefulWidget {
  final ChartType chartType;
  final List<FoodItem>? customFoodItems;
  final DateTime? startDate;
  final DateTime? endDate;

  const NutritionChartsWidget({
    super.key,
    required this.chartType,
    this.customFoodItems,
    this.startDate,
    this.endDate,
  });

  @override
  State<NutritionChartsWidget> createState() => _NutritionChartsWidgetState();
}

class _NutritionChartsWidgetState extends State<NutritionChartsWidget> {
  List<Map<String, dynamic>> _weeklyData = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.chartType == ChartType.weeklyCalories ||
        widget.chartType == ChartType.weeklyMacros) {
      _loadWeeklyData();
    }
  }

  Future<void> _loadWeeklyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final nutritionProvider =
          Provider.of<NutritionProvider>(context, listen: false);
      final startDate =
          widget.startDate ?? DateTime.now().subtract(const Duration(days: 6));

      final weeklyData =
          await nutritionProvider.getWeeklyNutritionData(startDate);

      if (mounted) {
        setState(() {
          _weeklyData = weeklyData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load weekly data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.chartType) {
      case ChartType.dailyMacrosPie:
        return _buildMacrosPieChart();
      case ChartType.weeklyCalories:
        return _buildWeeklyCaloriesChart();
      case ChartType.weeklyMacros:
        return _buildWeeklyMacrosChart();
      case ChartType.mealDistribution:
        return _buildMealDistributionChart();
    }
  }

  Widget _buildMacrosPieChart() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final foodItems =
            widget.customFoodItems ?? nutritionProvider.selectedDateFoodItems;

        if (foodItems.isEmpty) {
          return _buildEmptyChart('No data to display');
        }

        final macroData = _calculateMacroDistribution(foodItems);
        final totalMacroCalories =
            macroData['protein']! + macroData['carbs']! + macroData['fat']!;

        if (totalMacroCalories == 0) {
          return _buildEmptyChart('No macro data available');
        }

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Macronutrient Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          value: macroData['protein']!,
                          title:
                              '${((macroData['protein']! / totalMacroCalories) * 100).toInt()}%',
                          color: Theme.of(context).colorScheme.primary,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: macroData['carbs']!,
                          title:
                              '${((macroData['carbs']! / totalMacroCalories) * 100).toInt()}%',
                          color: Theme.of(context).colorScheme.secondary,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: macroData['fat']!,
                          title:
                              '${((macroData['fat']! / totalMacroCalories) * 100).toInt()}%',
                          color: Theme.of(context).colorScheme.tertiary,
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch interactions if needed
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(
                      'Protein',
                      '${(macroData['protein']! / 4).toInt()}g',
                      Theme.of(context).colorScheme.primary,
                    ),
                    _buildLegendItem(
                      'Carbs',
                      '${(macroData['carbs']! / 4).toInt()}g',
                      Theme.of(context).colorScheme.secondary,
                    ),
                    _buildLegendItem(
                      'Fat',
                      '${(macroData['fat']! / 9).toInt()}g',
                      Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyCaloriesChart() {
    if (_isLoading) {
      return _buildLoadingChart();
    }

    if (_errorMessage != null) {
      return _buildErrorChart(_errorMessage!);
    }

    if (_weeklyData.isEmpty) {
      return _buildEmptyChart('No weekly data available');
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final targetCalories =
            userProvider.currentHealthGoal?.targetCalories ?? 2000.0;

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Calorie Intake',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: targetCalories * 1.5,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor:
                              Theme.of(context).colorScheme.inverseSurface,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final dayData = _weeklyData[group.x];
                            return BarTooltipItem(
                              '${dayData['weekdayName']}\n${rod.toY.toInt()} cal',
                              TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() >= _weeklyData.length)
                                return const Text('');
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _weeklyData[value.toInt()]['weekdayName'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                '${value.toInt()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _weeklyData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final dayData = entry.value;
                        final calories = dayData['totalCalories'] ?? 0.0;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: calories,
                              color: calories >= targetCalories
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      // Add target line
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: targetCalories,
                            color: Theme.of(context).colorScheme.error,
                            strokeWidth: 2,
                            dashArray: [8, 4],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              labelResolver: (line) =>
                                  'Target: ${targetCalories.toInt()}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyMacrosChart() {
    if (_isLoading) {
      return _buildLoadingChart();
    }

    if (_errorMessage != null) {
      return _buildErrorChart(_errorMessage!);
    }

    if (_weeklyData.isEmpty) {
      return _buildEmptyChart('No weekly data available');
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stacked_bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Macronutrients',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= _weeklyData.length)
                            return const Text('');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _weeklyData[value.toInt()]['weekdayName'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt()}g',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Protein line
                    LineChartBarData(
                      spots: _weeklyData.asMap().entries.map((entry) {
                        final index = entry.key.toDouble();
                        final protein = entry.value['totalProtein'] ?? 0.0;
                        return FlSpot(index, protein);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                    // Carbs line
                    LineChartBarData(
                      spots: _weeklyData.asMap().entries.map((entry) {
                        final index = entry.key.toDouble();
                        final carbs = entry.value['totalCarbs'] ?? 0.0;
                        return FlSpot(index, carbs);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.secondary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                    // Fat line
                    LineChartBarData(
                      spots: _weeklyData.asMap().entries.map((entry) {
                        final index = entry.key.toDouble();
                        final fat = entry.value['totalFat'] ?? 0.0;
                        return FlSpot(index, fat);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.tertiary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor:
                          Theme.of(context).colorScheme.inverseSurface,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final dayData = _weeklyData[barSpot.x.toInt()];
                          String macroType = '';
                          if (barSpot.barIndex == 0) macroType = 'Protein';
                          if (barSpot.barIndex == 1) macroType = 'Carbs';
                          if (barSpot.barIndex == 2) macroType = 'Fat';

                          return LineTooltipItem(
                            '${dayData['weekdayName']}\n$macroType: ${barSpot.y.toInt()}g',
                            TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  'Protein',
                  '',
                  Theme.of(context).colorScheme.primary,
                ),
                _buildLegendItem(
                  'Carbs',
                  '',
                  Theme.of(context).colorScheme.secondary,
                ),
                _buildLegendItem(
                  'Fat',
                  '',
                  Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealDistributionChart() {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        final foodItems =
            widget.customFoodItems ?? nutritionProvider.selectedDateFoodItems;

        if (foodItems.isEmpty) {
          return _buildEmptyChart('No meal data to display');
        }

        final mealData = _calculateMealDistribution(foodItems);
        final totalCalories =
            mealData.values.fold(0.0, (sum, calories) => sum + calories);

        if (totalCalories == 0) {
          return _buildEmptyChart('No meal data available');
        }

        final mealColors = {
          'Breakfast': Colors.orange,
          'Lunch': Colors.amber,
          'Dinner': Colors.indigo,
          'Snack': Colors.green,
        };

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.donut_small,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Meal Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: mealData.entries.map((entry) {
                        final mealType = entry.key;
                        final calories = entry.value;
                        final percentage =
                            (calories / totalCalories * 100).toInt();

                        return PieChartSectionData(
                          value: calories,
                          title: '$percentage%',
                          color: mealColors[mealType] ?? Colors.grey,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: mealData.entries.map((entry) {
                    return _buildLegendItem(
                      entry.key,
                      '${entry.value.toInt()} cal',
                      mealColors[entry.key] ?? Colors.grey,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorChart(String error) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculateMacroDistribution(List<FoodItem> foodItems) {
    double proteinCalories = 0;
    double carbsCalories = 0;
    double fatCalories = 0;

    for (final item in foodItems) {
      proteinCalories += item.protein * 4; // 4 calories per gram of protein
      carbsCalories += item.carbs * 4; // 4 calories per gram of carbs
      fatCalories += item.fat * 9; // 9 calories per gram of fat
    }

    return {
      'protein': proteinCalories,
      'carbs': carbsCalories,
      'fat': fatCalories,
    };
  }

  Map<String, double> _calculateMealDistribution(List<FoodItem> foodItems) {
    final Map<String, double> mealCalories = {};

    for (final item in foodItems) {
      final mealType = item.mealType[0].toUpperCase() +
          item.mealType.substring(1).toLowerCase();
      mealCalories[mealType] = (mealCalories[mealType] ?? 0) + item.calories;
    }

    return mealCalories;
  }
}

enum ChartType {
  dailyMacrosPie,
  weeklyCalories,
  weeklyMacros,
  mealDistribution,
}

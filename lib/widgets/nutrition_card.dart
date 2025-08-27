// lib/widgets/nutrition_card.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Nutrition Card Widget
/// Used to display nutrition intake progress for protein, carbs, fat, etc.
class NutritionCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  const NutritionCard({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildProgressSection(context, progress, percentage),
              const SizedBox(height: 12),
              _buildValueSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        Text(
          '$percentage%',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
      BuildContext context, double progress, int percentage) {
    return Column(
      children: [
        // Progress bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                tween: Tween(begin: 0, end: progress),
                builder: (context, animatedProgress, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedProgress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          tween: Tween(begin: 0, end: current),
          builder: (context, animatedCurrent, child) {
            return Text(
              '${animatedCurrent.toStringAsFixed(1)}$unit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            );
          },
        ),
        Text(
          '/ ${target.toStringAsFixed(0)}$unit',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}

/// Compact Nutrition Card
/// Used to display nutrition information in smaller spaces
class CompactNutritionCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final IconData? icon;

  const CompactNutritionCard({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              tween: Tween(begin: 0, end: progress),
              builder: (context, animatedProgress, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedProgress,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0, end: current),
                builder: (context, animatedCurrent, child) {
                  return Text(
                    '${animatedCurrent.toStringAsFixed(0)}$unit',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
              Text(
                '${target.toStringAsFixed(0)}$unit',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Nutrition Circular Progress Card
/// Combines circular progress bar with card design for nutrition display
class NutritionCircularCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final IconData? icon;
  final double size;

  const NutritionCircularCard({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    this.icon,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular progress bar
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.withOpacity(0.2),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: size,
                    height: size,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      tween: Tween(begin: 0, end: progress),
                      builder: (context, animatedProgress, child) {
                        return CircularProgressIndicator(
                          value: animatedProgress,
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          backgroundColor: Colors.transparent,
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(height: 2),
                      ],
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0, end: (progress * 100)),
                        builder: (context, animatedPercentage, child) {
                          return Text(
                            '${animatedPercentage.toInt()}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Value
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0, end: current),
              builder: (context, animatedCurrent, child) {
                return Text(
                  '${animatedCurrent.toStringAsFixed(1)}${unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Nutrition Summary Card
/// Displays comprehensive information for multiple nutrients
class NutritionSummaryCard extends StatelessWidget {
  final Map<String, double> currentValues;
  final Map<String, double> targetValues;
  final Map<String, Color> colors;
  final String title;
  final IconData? icon;

  const NutritionSummaryCard({
    super.key,
    required this.currentValues,
    required this.targetValues,
    required this.colors,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Nutrient list
            ...currentValues.entries.map((entry) {
              final key = entry.key;
              final current = entry.value;
              final target = targetValues[key] ?? 0;
              final color = colors[key] ?? theme.colorScheme.primary;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildNutritionRow(
                  context,
                  key,
                  current,
                  target,
                  color,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(
    BuildContext context,
    String label,
    double current,
    double target,
    Color color,
  ) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatLabel(label),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$percentage%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
            tween: Tween(begin: 0, end: progress),
            builder: (context, animatedProgress, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animatedProgress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // Values
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0, end: current),
              builder: (context, animatedCurrent, child) {
                return Text(
                  '${animatedCurrent.toStringAsFixed(1)}g',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            Text(
              'Goal: ${target.toStringAsFixed(0)}g',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatLabel(String key) {
    switch (key.toLowerCase()) {
      case 'protein':
        return 'Protein';
      case 'carbs':
      case 'carbohydrates':
        return 'Carbs';
      case 'fat':
      case 'fats':
        return 'Fat';
      case 'fiber':
        return 'Fiber';
      case 'sugar':
        return 'Sugar';
      default:
        return key.substring(0, 1).toUpperCase() + key.substring(1);
    }
  }
}

/// Nutrition Comparison Card
/// Used to compare nutrition intake between different periods
class NutritionComparisonCard extends StatelessWidget {
  final String title;
  final Map<String, double> currentPeriod;
  final Map<String, double> previousPeriod;
  final String currentLabel;
  final String previousLabel;

  const NutritionComparisonCard({
    super.key,
    required this.title,
    required this.currentPeriod,
    required this.previousPeriod,
    required this.currentLabel,
    required this.previousLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Current period
                Expanded(
                  child: _buildPeriodColumn(
                    context,
                    currentLabel,
                    currentPeriod,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                // Previous period
                Expanded(
                  child: _buildPeriodColumn(
                    context,
                    previousLabel,
                    previousPeriod,
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodColumn(
    BuildContext context,
    String label,
    Map<String, double> values,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...values.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatNutrientKey(entry.key),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${entry.value.toStringAsFixed(1)}g',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatNutrientKey(String key) {
    switch (key.toLowerCase()) {
      case 'calories':
        return 'Calories';
      case 'protein':
        return 'Protein';
      case 'carbs':
        return 'Carbs';
      case 'fat':
        return 'Fat';
      default:
        return key;
    }
  }
}

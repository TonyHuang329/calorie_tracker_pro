import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NutritionCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final String unit;
  final Color color;

  const NutritionCard({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final remaining = (target - current).clamp(0.0, target);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12), // 减少内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 13, // 稍微减小字体
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _getIconForNutrition(title),
                  size: 16, // 减小图标尺寸
                  color: color.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 数值显示 - 紧凑布局
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 当前值
                Text(
                  current.toStringAsFixed(1),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 18, // 减小字体大小
                  ),
                ),
                // 目标值
                Text(
                  '/ ${target.toStringAsFixed(1)} $unit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 进度条
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(2),
                  minHeight: 4, // 减小进度条高度
                ),
                const SizedBox(height: 4),

                // 进度信息 - 简化显示
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: color,
                        fontSize: 10,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        remaining > 0
                            ? '还需${remaining.toStringAsFixed(0)}'
                            : '已完成',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: remaining > 0
                              ? theme.textTheme.bodySmall?.color
                              : color,
                          fontWeight: remaining > 0
                              ? FontWeight.normal
                              : FontWeight.w500,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForNutrition(String nutrition) {
    switch (nutrition) {
      case '蛋白质':
        return Icons.fitness_center;
      case '碳水':
        return Icons.grain;
      case '脂肪':
        return Icons.opacity;
      default:
        return Icons.restaurant;
    }
  }
}

// lib/widgets/circular_progress_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 环形进度条组件
/// 用于在主页显示卡路里摄入进度
class CircularProgressWidget extends StatelessWidget {
  final double current;
  final double target;
  final String title;
  final String unit;
  final Color? progressColor;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;

  const CircularProgressWidget({
    super.key,
    required this.current,
    required this.target,
    required this.title,
    required this.unit,
    this.progressColor,
    this.backgroundColor,
    this.size = 200,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 计算进度百分比
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    // 确定进度条颜色
    final Color effectiveProgressColor = progressColor ??
        (progress > 1.0
            ? colorScheme.error
            : progress > 0.8
                ? Colors.orange
                : colorScheme.primary);

    final Color effectiveBackgroundColor =
        backgroundColor ?? colorScheme.outline.withOpacity(0.2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆环
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor:
                  AlwaysStoppedAnimation<Color>(effectiveBackgroundColor),
              backgroundColor: Colors.transparent,
            ),
          ),
          // 进度圆环
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
                  strokeWidth: strokeWidth,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(effectiveProgressColor),
                  backgroundColor: Colors.transparent,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // 中心内容
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 当前值
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                tween: Tween(begin: 0, end: current),
                builder: (context, animatedCurrent, child) {
                  return Text(
                    animatedCurrent.toStringAsFixed(0),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              // 单位和目标
              Text(
                '$unit / ${target.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              // 标题
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // 百分比
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: effectiveProgressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentage%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: effectiveProgressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // 超额指示器
          if (progress > 1.0)
            Positioned(
              top: size * 0.15,
              right: size * 0.15,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.error.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.warning,
                  color: colorScheme.onError,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 小尺寸环形进度条组件
/// 用于营养素进度显示
class CompactCircularProgress extends StatelessWidget {
  final double current;
  final double target;
  final String label;
  final Color color;
  final double size;

  const CompactCircularProgress({
    super.key,
    required this.current,
    required this.target,
    required this.label,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆环
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
              // 进度圆环
              SizedBox(
                width: size,
                height: size,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
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
              // 百分比
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: percentage.toDouble()),
                builder: (context, animatedPercentage, child) {
                  return Text(
                    '${animatedPercentage.toInt()}%',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 标签
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        // 数值
        Text(
          '${current.toStringAsFixed(0)}g',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// 线性进度条组件
/// 用于简单的营养素显示
class LinearNutritionProgress extends StatelessWidget {
  final double current;
  final double target;
  final String label;
  final Color color;
  final String unit;

  const LinearNutritionProgress({
    super.key,
    required this.current,
    required this.target,
    required this.label,
    required this.color,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签和数值
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 进度条
        Stack(
          children: [
            // 背景
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 进度
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              tween: Tween(begin: 0, end: progress),
              builder: (context, animatedProgress, child) {
                return FractionallySizedBox(
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
          ],
        ),
        const SizedBox(height: 4),
        // 百分比
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$percentage%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

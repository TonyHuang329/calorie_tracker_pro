import 'package:flutter/material.dart';

class QuickAddButtons extends StatelessWidget {
  const QuickAddButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快速添加',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.camera_alt,
                    title: 'AI识别',
                    subtitle: '拍照识别',
                    color: Colors.blue,
                    onTap: () => _onAICameraPressed(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.search,
                    title: '搜索',
                    subtitle: '查找食物',
                    color: Colors.green,
                    onTap: () => _onSearchPressed(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.flash_on,
                    title: '快速',
                    subtitle: '快速记录',
                    color: Colors.orange,
                    onTap: () => _onQuickAddPressed(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onAICameraPressed(BuildContext context) {
    // TODO: 实现AI相机功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI识别功能即将推出')),
    );
  }

  void _onSearchPressed(BuildContext context) {
    // TODO: 实现搜索功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('搜索功能即将推出')),
    );
  }

  void _onQuickAddPressed(BuildContext context) {
    Navigator.pushNamed(context, '/add-food', arguments: {'quickAdd': true});
  }
}

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

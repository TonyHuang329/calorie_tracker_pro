// lib/screens/redesigned_health_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_goal.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../utils/form_validators.dart';
import '../utils/calorie_calculator.dart';

class RedesignedHealthGoalsScreen extends StatefulWidget {
  const RedesignedHealthGoalsScreen({super.key});

  @override
  State<RedesignedHealthGoalsScreen> createState() =>
      _RedesignedHealthGoalsScreenState();
}

class _RedesignedHealthGoalsScreenState
    extends State<RedesignedHealthGoalsScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 表单控制器
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _notesController = TextEditingController();
  final _weeklyTargetController = TextEditingController();

  // 状态变量
  String _selectedGoalType = 'maintain';
  bool _isInitialized = false;
  bool _hasChanges = false;
  bool _isCalculating = false;

  // 计算结果
  double _estimatedTDEE = 0;
  double _recommendedCalories = 0;
  Map<String, double> _macroBreakdown = {};
  String _timeEstimate = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
    _setupListeners();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  void _setupListeners() {
    _caloriesController.addListener(_onFieldChanged);
    _proteinController.addListener(_onFieldChanged);
    _carbsController.addListener(_onFieldChanged);
    _fatController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
    _weeklyTargetController.addListener(_onFieldChanged);
  }

  void _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadCurrentHealthGoal();

    final goal = userProvider.currentHealthGoal;
    if (goal != null) {
      _caloriesController.text = goal.targetCalories.toStringAsFixed(0);
      _proteinController.text = goal.targetProtein.toStringAsFixed(1);
      _carbsController.text = goal.targetCarbs.toStringAsFixed(1);
      _fatController.text = goal.targetFat.toStringAsFixed(1);
      _notesController.text = goal.notes ?? '';
      _selectedGoalType = goal.goalType ?? 'maintain';
    }

    _calculateRecommendations();

    setState(() {
      _isInitialized = true;
      _hasChanges = false;
    });

    _animationController.forward();
    _slideController.forward();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _calculateRecommendations() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;

    if (profile == null) return;

    setState(() {
      _isCalculating = true;
    });

    // 计算TDEE
    _estimatedTDEE = CalorieCalculator.calculateTDEE(profile);

    // 根据目标类型计算推荐卡路里
    double weeklyChange = 0;
    switch (_selectedGoalType) {
      case 'lose':
        weeklyChange = -0.5; // 默认每周减重0.5kg
        break;
      case 'gain':
        weeklyChange = 0.3; // 默认每周增重0.3kg
        break;
    }

    if (_weeklyTargetController.text.isNotEmpty) {
      final userTarget = double.tryParse(_weeklyTargetController.text);
      if (userTarget != null) {
        weeklyChange = _selectedGoalType == 'lose' ? -userTarget : userTarget;
      }
    }

    _recommendedCalories = CalorieCalculator.calculateTargetCalories(
      profile,
      goalType: _selectedGoalType,
      weeklyWeightChange: weeklyChange,
    );

    // 计算宏量营养素分配
    _macroBreakdown =
        CalorieCalculator.calculateMacronutrients(_recommendedCalories);

    // 计算时间估计
    if (weeklyChange != 0) {
      final dailyDeficit = (_estimatedTDEE - _recommendedCalories).abs();
      final weeksForOneKg = 7700 / (dailyDeficit * 7); // 1kg脂肪 = 7700卡路里
      _timeEstimate = '约${weeksForOneKg.toStringAsFixed(1)}周减/增1kg';
    } else {
      _timeEstimate = '维持当前体重';
    }

    // 自动填充推荐值
    if (_caloriesController.text.isEmpty || !_hasChanges) {
      _caloriesController.text = _recommendedCalories.toStringAsFixed(0);
      _proteinController.text = _macroBreakdown['protein']!.toStringAsFixed(1);
      _carbsController.text = _macroBreakdown['carbs']!.toStringAsFixed(1);
      _fatController.text = _macroBreakdown['fat']!.toStringAsFixed(1);
    }

    setState(() {
      _isCalculating = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    _weeklyTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康目标'),
        elevation: 0,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return TextButton.icon(
                onPressed:
                    _hasChanges && !userProvider.isLoading ? _saveGoal : null,
                icon: userProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('保存'),
                style: TextButton.styleFrom(
                  foregroundColor: _hasChanges
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (!_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.userProfile == null) {
            return _buildNoProfileMessage();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildMainContent(userProvider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoProfileMessage() {
    return Center(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '需要完善个人资料',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '我们需要您的身体信息来计算\n个性化的健康目标',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('设置个人资料'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(UserProvider userProvider) {
    return SingleChildScrollView(
      padding: AppTheme.getScreenPadding(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProvider.errorMessage != null)
              _buildErrorBanner(userProvider.errorMessage!),
            _buildGoalTypeSelector(),
            const SizedBox(height: 24),
            if (_selectedGoalType != 'maintain') _buildWeeklyTargetSection(),
            _buildRecommendationCard(),
            const SizedBox(height: 24),
            _buildNutritionTargets(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                Provider.of<UserProvider>(context, listen: false).clearError(),
            icon: const Icon(Icons.close),
            color: Colors.red.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flag_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '选择您的健康目标',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._getGoalOptions().map((option) {
              final isSelected = _selectedGoalType == option['value'];
              return GestureDetector(
                onTap: () => _selectGoalType(option['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (option['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          option['icon'] as IconData,
                          color: option['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : null,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option['subtitle'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTargetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timeline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '每周目标',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weeklyTargetController,
              decoration: InputDecoration(
                labelText: _selectedGoalType == 'lose' ? '每周减重目标' : '每周增重目标',
                hintText: _selectedGoalType == 'lose' ? '0.5' : '0.3',
                suffixText: 'kg',
                helperText: _selectedGoalType == 'lose'
                    ? '建议：0.3-1.0kg，过快减重可能影响健康'
                    : '建议：0.2-0.5kg，循序渐进更健康',
                prefixIcon: Icon(
                  _selectedGoalType == 'lose'
                      ? Icons.trending_down
                      : Icons.trending_up,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _calculateRecommendations(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '个性化推荐',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isCalculating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricDisplay(
                          'TDEE',
                          _estimatedTDEE.toInt().toString(),
                          'kcal/天',
                          Icons.local_fire_department,
                        ),
                        _buildMetricDisplay(
                          '推荐摄入',
                          _recommendedCalories.toInt().toString(),
                          'kcal/天',
                          Icons.restaurant,
                        ),
                      ],
                    ),
                    if (_timeEstimate.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _timeEstimate,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricDisplay(
      String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildNutritionTargets() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pie_chart_outline,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '营养目标',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: '每日卡路里目标',
                suffixText: 'kcal',
                prefixIcon: Icon(Icons.local_fire_department),
                helperText: '根据您的目标自动计算，也可手动调整',
              ),
              keyboardType: TextInputType.number,
              validator: FormValidators.validateTargetCalories,
            ),
            const SizedBox(height: 20),
            Text(
              '宏量营养素分配',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: InputDecoration(
                      labelText: '蛋白质',
                      suffixText: 'g',
                      prefixIcon: Icon(
                        Icons.fitness_center,
                        color: AppTheme.getProteinColor(context),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateProtein,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: InputDecoration(
                      labelText: '碳水',
                      suffixText: 'g',
                      prefixIcon: Icon(
                        Icons.grain,
                        color: AppTheme.getCarbsColor(context),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateCarbs,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: InputDecoration(
                      labelText: '脂肪',
                      suffixText: 'g',
                      prefixIcon: Icon(
                        Icons.opacity,
                        color: AppTheme.getFatColor(context),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateFat,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMacroVisualization(),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroVisualization() {
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;

    if (calories == 0 || (protein + carbs + fat) == 0) {
      return const SizedBox.shrink();
    }

    final proteinCal = protein * 4;
    final carbsCal = carbs * 4;
    final fatCal = fat * 9;
    final totalMacroCal = proteinCal + carbsCal + fatCal;

    final proteinPercent = (proteinCal / totalMacroCal * 100);
    final carbsPercent = (carbsCal / totalMacroCal * 100);
    final fatPercent = (fatCal / totalMacroCal * 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '营养素占比',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMacroLegend(
                  '蛋白质', proteinPercent, AppTheme.getProteinColor(context)),
              _buildMacroLegend(
                  '碳水', carbsPercent, AppTheme.getCarbsColor(context)),
              _buildMacroLegend(
                  '脂肪', fatPercent, AppTheme.getFatColor(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLegend(String name, double percent, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.note_add,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '备注说明',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: '记录您的目标原因、计划或其他想法...',
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: FormValidators.validateNotes,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getGoalOptions() {
    return [
      {
        'value': 'maintain',
        'title': '维持体重',
        'subtitle': '保持当前体重，均衡营养摄入',
        'icon': Icons.balance,
        'color': Colors.blue,
      },
      {
        'value': 'lose',
        'title': '健康减重',
        'subtitle': '科学减脂，保持肌肉量',
        'icon': Icons.trending_down,
        'color': Colors.orange,
      },
      {
        'value': 'gain',
        'title': '健康增重',
        'subtitle': '增加肌肉和体重',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
    ];
  }

  void _selectGoalType(String goalType) {
    setState(() {
      _selectedGoalType = goalType;
      _hasChanges = true;
    });
    _calculateRecommendations();
  }

  void _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final goal = HealthGoal(
      id: userProvider.currentHealthGoal?.id,
      targetCalories: double.parse(_caloriesController.text.trim()),
      targetProtein: double.parse(_proteinController.text.trim()),
      targetCarbs: double.parse(_carbsController.text.trim()),
      targetFat: double.parse(_fatController.text.trim()),
      createdAt: userProvider.currentHealthGoal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      goalType: _selectedGoalType,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final success = await userProvider.saveHealthGoal(goal);

    if (success && mounted) {
      setState(() {
        _hasChanges = false;
      });

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                '健康目标已保存',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );

      // 延迟返回，让用户看到成功提示
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, true); // 返回true表示已保存
      }
    } else if (mounted) {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                '保存失败，请重试',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: '重试',
            textColor: Colors.white,
            onPressed: _saveGoal,
          ),
        ),
      );
    }
  }
}

// lib/screens/onboarding_flow.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/health_goal.dart';
import '../providers/user_provider.dart';
import '../utils/form_validators.dart';
import '../utils/app_theme.dart';
import '../utils/calorie_calculator.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // 表单数据
  final _userFormKey = GlobalKey<FormState>();
  final _goalFormKey = GlobalKey<FormState>();

  // 用户资料控制器
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderate';

  // 健康目标控制器
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  String _selectedGoalType = 'maintain';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _generateRecommendedGoals() {
    if (_userFormKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        height: double.parse(_heightController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        activityLevel: _selectedActivityLevel,
      );

      final goal = CalorieCalculator.createHealthGoalForUser(
        profile,
        goalType: _selectedGoalType,
      );

      setState(() {
        _caloriesController.text = goal.targetCalories.toStringAsFixed(0);
        _proteinController.text = goal.targetProtein.toStringAsFixed(1);
        _carbsController.text = goal.targetCarbs.toStringAsFixed(1);
        _fatController.text = goal.targetFat.toStringAsFixed(1);
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (!_goalFormKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 创建用户资料
    final profile = UserProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _selectedGender,
      height: double.parse(_heightController.text.trim()),
      weight: double.parse(_weightController.text.trim()),
      activityLevel: _selectedActivityLevel,
    );

    // 创建健康目标
    final goal = HealthGoal(
      targetCalories: double.parse(_caloriesController.text.trim()),
      targetProtein: double.parse(_proteinController.text.trim()),
      targetCarbs: double.parse(_carbsController.text.trim()),
      targetFat: double.parse(_fatController.text.trim()),
      createdAt: DateTime.now(),
      goalType: _selectedGoalType,
    );

    // 保存到数据库
    final profileSuccess = await userProvider.saveUserProfile(profile);
    if (profileSuccess) {
      final goalSuccess = await userProvider.saveHealthGoal(goal);
      if (goalSuccess && mounted) {
        // 标记引导完成
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        await appProvider.completeFirstLaunch();

        // 跳转到主页
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }

    if (!profileSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 进度指示器
            _buildProgressIndicator(),

            // 页面内容
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildUserInfoPage(),
                  _buildGoalTypePage(),
                  _buildGoalDetailsPage(),
                ],
              ),
            ),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(_totalPages, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _totalPages - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: AppTheme.getScreenPadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.restaurant_menu,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 30),
          Text(
            '欢迎使用卡路里追踪',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            '让我们花几分钟时间设置您的个人资料，\n为您提供个性化的健康建议。',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _buildFeatureList(),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      {'icon': Icons.track_changes, 'title': '精准追踪', 'subtitle': '记录每日营养摄入'},
      {'icon': Icons.analytics, 'title': '智能分析', 'subtitle': '可视化数据图表'},
      {'icon': Icons.camera_alt, 'title': 'AI识别', 'subtitle': '拍照快速记录'},
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                feature['icon'] as IconData,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      feature['subtitle'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserInfoPage() {
    return SingleChildScrollView(
      padding: AppTheme.getScreenPadding(context),
      child: Form(
        key: _userFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '个人信息',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '请填写您的基本信息，这将帮助我们计算您的营养需求。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 30),

            // 姓名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                prefixIcon: Icon(Icons.person),
              ),
              validator: FormValidators.validateName,
            ),
            const SizedBox(height: 20),

            // 年龄和性别
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: '年龄',
                      prefixIcon: Icon(Icons.cake),
                      suffixText: '岁',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateAge,
                    onChanged: (value) => _generateRecommendedGoals(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: '性别',
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('男')),
                      DropdownMenuItem(value: 'female', child: Text('女')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                      _generateRecommendedGoals();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 身高和体重
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: '身高',
                      prefixIcon: Icon(Icons.height),
                      suffixText: 'cm',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateHeight,
                    onChanged: (value) => _generateRecommendedGoals(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: '体重',
                      prefixIcon: Icon(Icons.monitor_weight),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateWeight,
                    onChanged: (value) => _generateRecommendedGoals(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 活动水平
            Text(
              '活动水平',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ..._getActivityLevelOptions().map((option) {
              return RadioListTile<String>(
                title: Text(option['title']!),
                subtitle: Text(option['subtitle']!),
                value: option['value']!,
                groupValue: _selectedActivityLevel,
                onChanged: (value) {
                  setState(() {
                    _selectedActivityLevel = value!;
                  });
                  _generateRecommendedGoals();
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTypePage() {
    return SingleChildScrollView(
      padding: AppTheme.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '健康目标',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '选择最符合您当前需求的健康目标。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          const SizedBox(height: 30),
          ..._getGoalTypeOptions().map((option) {
            final isSelected = _selectedGoalType == option['value'];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedGoalType = option['value']!;
                  });
                  _generateRecommendedGoals();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: option['value']!,
                        groupValue: _selectedGoalType,
                        onChanged: (value) {
                          setState(() {
                            _selectedGoalType = value!;
                          });
                          _generateRecommendedGoals();
                        },
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        option['icon'] as IconData,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['title']!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option['subtitle']!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGoalDetailsPage() {
    return SingleChildScrollView(
      padding: AppTheme.getScreenPadding(context),
      child: Form(
        key: _goalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '营养目标',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '基于您的信息，我们为您推荐以下营养目标。您可以根据需要调整。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 30),

            // 目标卡路里
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: '目标卡路里',
                prefixIcon: Icon(Icons.local_fire_department),
                suffixText: 'kcal',
                helperText: '建议的每日卡路里摄入量',
              ),
              keyboardType: TextInputType.number,
              validator: FormValidators.validateTargetCalories,
            ),
            const SizedBox(height: 20),

            // 宏量营养素目标
            Text(
              '宏量营养素目标',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

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
                      labelText: '碳水化合物',
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
            const SizedBox(height: 30),

            // 建议信息卡片
            _buildRecommendationCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '个性化建议',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getPersonalizedTip(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getPersonalizedTip() {
    switch (_selectedGoalType) {
      case 'lose':
        return '为了健康减重，建议每周减重0.5-1公斤。保持充足的蛋白质摄入，有助于维持肌肉量。';
      case 'gain':
        return '健康增重需要循序渐进。建议增加优质蛋白质和复合碳水化合物的摄入。';
      case 'maintain':
      default:
        return '维持当前体重时，保持营养均衡很重要。定期运动和规律作息同样关键。';
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                child: const Text('上一步'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _currentPage == _totalPages - 1
                  ? _completeOnboarding
                  : _handleNext,
              child: Text(_currentPage == _totalPages - 1 ? '完成设置' : '下一步'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    switch (_currentPage) {
      case 1: // 用户信息页面
        if (_userFormKey.currentState!.validate()) {
          _generateRecommendedGoals();
          _nextPage();
        }
        break;
      case 2: // 目标类型页面
        _generateRecommendedGoals();
        _nextPage();
        break;
      default:
        _nextPage();
    }
  }

  List<Map<String, String>> _getActivityLevelOptions() {
    return [
      {
        'value': 'sedentary',
        'title': '久坐',
        'subtitle': '很少或没有运动，主要是办公室工作',
      },
      {
        'value': 'light',
        'title': '轻度活跃',
        'subtitle': '轻度运动或工作，1-3天/周',
      },
      {
        'value': 'moderate',
        'title': '中度活跃',
        'subtitle': '中度运动或工作，3-5天/周',
      },
      {
        'value': 'active',
        'title': '活跃',
        'subtitle': '重度运动或工作，6-7天/周',
      },
      {
        'value': 'very_active',
        'title': '非常活跃',
        'subtitle': '非常重度的体力工作或每日运动',
      },
    ];
  }

  List<Map<String, dynamic>> _getGoalTypeOptions() {
    return [
      {
        'value': 'maintain',
        'title': '维持体重',
        'subtitle': '保持当前体重，均衡营养摄入',
        'icon': Icons.balance,
      },
      {
        'value': 'lose',
        'title': '减重',
        'subtitle': '适度减少卡路里摄入，健康减重',
        'icon': Icons.trending_down,
      },
      {
        'value': 'gain',
        'title': '增重',
        'subtitle': '适度增加卡路里摄入，健康增重',
        'icon': Icons.trending_up,
      },
    ];
  }
}

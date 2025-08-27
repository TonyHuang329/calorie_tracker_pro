// lib/screens/improved_profile_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../utils/form_validators.dart';
import '../utils/calorie_calculator.dart';

class ImprovedProfileSettingsScreen extends StatefulWidget {
  const ImprovedProfileSettingsScreen({super.key});

  @override
  State<ImprovedProfileSettingsScreen> createState() =>
      _ImprovedProfileSettingsScreenState();
}

class _ImprovedProfileSettingsScreenState
    extends State<ImprovedProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 表单控制器
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // 表单状态
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderate';
  bool _isInitialized = false;
  bool _hasChanges = false;

  // BMI相关状态
  double? _currentBMI;
  String? _bmiCategory;
  Color? _bmiColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });

    // 监听输入变化
    _nameController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = true;
    });
    _updateBMICalculation();
  }

  void _updateBMICalculation() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0 && weight > 0) {
      setState(() {
        _currentBMI = CalorieCalculator.calculateBMI(weight, height);
        _bmiCategory = CalorieCalculator.getBMICategory(_currentBMI!);
        _bmiColor = _getBMIColor(_currentBMI!);
      });
    } else {
      setState(() {
        _currentBMI = null;
        _bmiCategory = null;
        _bmiColor = null;
      });
    }
  }

  void _loadUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;

    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _heightController.text = profile.height.toString();
      _weightController.text = profile.weight.toString();
      _selectedGender = profile.gender;
      _selectedActivityLevel = profile.activityLevel;
      _updateBMICalculation();
    }

    setState(() {
      _isInitialized = true;
      _hasChanges = false;
    });

    _animationController.forward();
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('个人资料'),
          actions: [
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return TextButton(
                  onPressed: _hasChanges ? _saveProfile : null,
                  child: Text(
                    '保存',
                    style: TextStyle(
                      color: _hasChanges
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
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

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: AppTheme.getScreenPadding(context),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userProvider.errorMessage != null)
                        _buildErrorCard(userProvider.errorMessage!),
                      const SizedBox(height: 16),
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildPhysicalInfoSection(),
                      const SizedBox(height: 24),
                      _buildActivityLevelSection(),
                      if (_currentBMI != null) ...[
                        const SizedBox(height: 24),
                        _buildHealthMetricsSection(),
                      ],
                      const SizedBox(height: 24),
                      _buildRecommendationsSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          IconButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).clearError();
            },
            icon: const Icon(Icons.close),
            color: Colors.red[700],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: '基本信息',
      icon: Icons.person,
      children: [
        _buildAnimatedTextField(
          controller: _nameController,
          labelText: '姓名',
          prefixIcon: Icons.badge,
          validator: FormValidators.validateName,
          delay: 100,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedTextField(
                controller: _ageController,
                labelText: '年龄',
                prefixIcon: Icons.cake,
                suffixText: '岁',
                keyboardType: TextInputType.number,
                validator: FormValidators.validateAge,
                delay: 200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimatedDropdown(
                value: _selectedGender,
                labelText: '性别',
                prefixIcon: Icons.wc,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('男')),
                  DropdownMenuItem(value: 'female', child: Text('女')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                    _hasChanges = true;
                  });
                },
                delay: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoSection() {
    return _buildSection(
      title: '身体信息',
      icon: Icons.accessibility,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnimatedTextField(
                controller: _heightController,
                labelText: '身高',
                prefixIcon: Icons.height,
                suffixText: 'cm',
                keyboardType: TextInputType.number,
                validator: FormValidators.validateHeight,
                delay: 400,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnimatedTextField(
                controller: _weightController,
                labelText: '体重',
                prefixIcon: Icons.monitor_weight,
                suffixText: 'kg',
                keyboardType: TextInputType.number,
                validator: FormValidators.validateWeight,
                delay: 500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityLevelSection() {
    return _buildSection(
      title: '活动水平',
      icon: Icons.directions_run,
      subtitle: '选择最符合您日常活动情况的选项',
      children: [
        ..._getActivityLevelOptions().asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: RadioListTile<String>(
                      title: Text(option['title']!),
                      subtitle: Text(
                        option['subtitle']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                      value: option['value']!,
                      groupValue: _selectedActivityLevel,
                      onChanged: (value) {
                        setState(() {
                          _selectedActivityLevel = value!;
                          _hasChanges = true;
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHealthMetricsSection() {
    return _buildSection(
      title: '健康指标',
      icon: Icons.health_and_safety,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _bmiColor!.withOpacity(0.1),
                _bmiColor!.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _bmiColor!.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monitor_weight,
                    color: _bmiColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'BMI 指数',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _bmiColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _currentBMI!.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _bmiColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _bmiCategory!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _bmiColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              _buildBMIProgressBar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBMIProgressBar() {
    const ranges = [
      {'min': 0.0, 'max': 18.5, 'color': Colors.blue, 'label': '过轻'},
      {'min': 18.5, 'max': 25.0, 'color': Colors.green, 'label': '正常'},
      {'min': 25.0, 'max': 30.0, 'color': Colors.orange, 'label': '超重'},
      {'min': 30.0, 'max': 40.0, 'color': Colors.red, 'label': '肥胖'},
    ];

    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: ranges.map((range) {
              final isCurrentRange =
                  _currentBMI! >= range['min']! && _currentBMI! < range['max']!;
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrentRange
                        ? range['color'] as Color
                        : (range['color'] as Color).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ranges.map((range) {
            return Text(
              range['label'] as String,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = _getPersonalizedRecommendations();

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: '个性化建议',
      icon: Icons.lightbulb_outline,
      children: [
        ...recommendations.asMap().entries.map((entry) {
          final index = entry.key;
          final recommendation = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: AppTheme.getCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? suffixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
                prefixIcon: Icon(prefixIcon),
                suffixText: suffixText,
              ),
              keyboardType: keyboardType,
              validator: validator,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDropdown({
    required String value,
    required String labelText,
    required IconData prefixIcon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                labelText: labelText,
                prefixIcon: Icon(prefixIcon),
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }

  List<String> _getPersonalizedRecommendations() {
    final recommendations = <String>[];

    if (_currentBMI != null) {
      if (_currentBMI! < 18.5) {
        recommendations.add('您的BMI偏低，建议增加健康饮食和适量运动');
        recommendations.add('可以考虑增加蛋白质和健康脂肪的摄入');
      } else if (_currentBMI! > 25) {
        recommendations.add('您的BMI偏高，建议控制卡路里摄入并增加运动');
        recommendations.add('推荐采用均衡饮食，减少加工食品');
      } else {
        recommendations.add('您的BMI在正常范围内，继续保持健康的生活方式');
      }
    }

    // 根据年龄给出建议
    final age = int.tryParse(_ageController.text);
    if (age != null) {
      if (age >= 50) {
        recommendations.add('建议增加钙质和维生素D的摄入');
        recommendations.add('可以进行低强度的有氧运动和力量训练');
      } else if (age <= 25) {
        recommendations.add('年轻时期是建立良好饮食习惯的关键时期');
        recommendations.add('可以进行多样化的运动来提高身体素质');
      }
    }

    // 根据活动水平给出建议
    if (_selectedActivityLevel == 'sedentary') {
      recommendations.add('久坐生活方式对健康不利，建议增加日常活动');
      recommendations.add('可以从每天步行30分钟开始');
    }

    return recommendations;
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

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('未保存的更改'),
        content: const Text('您有未保存的更改，确定要离开吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('离开'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final profile = UserProfile(
      id: userProvider.userProfile?.id,
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _selectedGender,
      height: double.parse(_heightController.text.trim()),
      weight: double.parse(_weightController.text.trim()),
      activityLevel: _selectedActivityLevel,
    );

    final success = await userProvider.saveUserProfile(profile);

    if (success && mounted) {
      setState(() {
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('个人资料保存成功'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // 如果是新用户，跳转到主页
      if (!Navigator.canPop(context)) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pop(context);
      }
    }
  }
}

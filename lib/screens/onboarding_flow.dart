// lib/screens/onboarding_flow.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/health_goal.dart';
import '../providers/user_provider.dart';
import '../providers/app_provider.dart';
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

  // Form data
  final _userFormKey = GlobalKey<FormState>();
  final _goalFormKey = GlobalKey<FormState>();

  // User profile controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderate';

  // Health goal controllers
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
            'Welcome to Calorie Tracker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Let\'s spend a few minutes setting up your personal profile\nto provide you with personalized health recommendations.',
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
      {
        'icon': Icons.track_changes,
        'title': 'Accurate Tracking',
        'subtitle': 'Record daily nutrition intake'
      },
      {
        'icon': Icons.analytics,
        'title': 'Smart Analysis',
        'subtitle': 'Visualized data charts'
      },
      {
        'icon': Icons.camera_alt,
        'title': 'AI Recognition',
        'subtitle': 'Quick photo logging'
      },
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
              'Personal Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please fill in your basic information to help us calculate your nutrition needs.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 30),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: FormValidators.validateName,
            ),
            const SizedBox(height: 16),

            // Age and Gender row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.cake),
                      suffixText: 'years',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateAge,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGender = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Height and Weight row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      prefixIcon: Icon(Icons.straighten),
                      suffixText: 'cm',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateHeight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      prefixIcon: Icon(Icons.monitor_weight),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validateWeight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Activity level
            Text(
              'Activity Level',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Column(
              children: _getActivityLevelOptions().map((option) {
                return RadioListTile<String>(
                  value: option['value']!,
                  groupValue: _selectedActivityLevel,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedActivityLevel = value;
                      });
                    }
                  },
                  title: Text(option['title']!),
                  subtitle: Text(
                    option['subtitle']!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }).toList(),
            ),
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
            'Health Goal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'What is your primary health goal? This will help us customize your nutrition plan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          const SizedBox(height: 30),
          Column(
            children: _getGoalTypeOptions().map((option) {
              final isSelected = _selectedGoalType == option['value'];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedGoalType = option['value'] as String;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).iconTheme.color,
                          size: 32,
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
                                style: Theme.of(context).textTheme.bodySmall,
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
                ),
              );
            }).toList(),
          ),
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
              'Nutrition Goals',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on your information, we recommend the following nutrition goals. You can adjust them as needed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 30),

            // Target calories
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Target Calories',
                prefixIcon: Icon(Icons.local_fire_department),
                suffixText: 'kcal',
                helperText: 'Recommended daily calorie intake',
              ),
              keyboardType: TextInputType.number,
              validator: FormValidators.validateTargetCalories,
            ),
            const SizedBox(height: 20),

            // Macronutrient goals
            Text(
              'Macronutrient Goals',
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
                      labelText: 'Protein',
                      suffixText: 'g',
                      prefixIcon: Icon(
                        Icons.fitness_center,
                        color: AppTheme.getProteinColor(context),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter protein target';
                      }
                      final protein = double.tryParse(value.trim());
                      if (protein == null || protein < 0) {
                        return 'Please enter a valid value';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: InputDecoration(
                      labelText: 'Carbohydrates',
                      suffixText: 'g',
                      prefixIcon: Icon(
                        Icons.grain,
                        color: AppTheme.getCarbsColor(context),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter carbs target';
                      }
                      final carbs = double.tryParse(value.trim());
                      if (carbs == null || carbs < 0) {
                        return 'Please enter a valid value';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _fatController,
              decoration: InputDecoration(
                labelText: 'Fat',
                suffixText: 'g',
                prefixIcon: Icon(
                  Icons.opacity,
                  color: AppTheme.getFatColor(context),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter fat target';
                }
                final fat = double.tryParse(value.trim());
                if (fat == null || fat < 0) {
                  return 'Please enter a valid value';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Personalized tip
            _buildPersonalizedTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedTip() {
    return Container(
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
                'Personalized Advice',
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
        return 'For healthy weight loss, aim to lose 0.5-1 kg per week. Maintain adequate protein intake to help preserve muscle mass.';
      case 'gain':
        return 'Healthy weight gain requires gradual progress. Consider increasing quality protein and complex carbohydrate intake.';
      case 'maintain':
      default:
        return 'When maintaining current weight, nutritional balance is important. Regular exercise and routine sleep are equally key.';
    }
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

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                child: const Text('Previous'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage > 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _currentPage == _totalPages - 1
                  ? _completeOnboarding
                  : _handleNext,
              child: Text(
                  _currentPage == _totalPages - 1 ? 'Complete Setup' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    switch (_currentPage) {
      case 1: // User info page
        if (_userFormKey.currentState!.validate()) {
          _generateRecommendedGoals();
          _nextPage();
        }
        break;
      case 2: // Goal type page
        _generateRecommendedGoals();
        _nextPage();
        break;
      default:
        _nextPage();
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

    // Create user profile
    final profile = UserProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _selectedGender,
      height: double.parse(_heightController.text.trim()),
      weight: double.parse(_weightController.text.trim()),
      activityLevel: _selectedActivityLevel,
    );

    // Create health goal
    final goal = HealthGoal(
      targetCalories: double.parse(_caloriesController.text.trim()),
      targetProtein: double.parse(_proteinController.text.trim()),
      targetCarbs: double.parse(_carbsController.text.trim()),
      targetFat: double.parse(_fatController.text.trim()),
      createdAt: DateTime.now(),
      goalType: _selectedGoalType,
    );

    // Save to database
    final profileSuccess = await userProvider.saveUserProfile(profile);
    if (profileSuccess) {
      final goalSuccess = await userProvider.saveHealthGoal(goal);
      if (goalSuccess && mounted) {
        // Mark onboarding as complete
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        await appProvider.completeFirstLaunch();

        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }

    if (!profileSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save failed, please try again')),
      );
    }
  }

  List<Map<String, String>> _getActivityLevelOptions() {
    return [
      {
        'value': 'sedentary',
        'title': 'Sedentary',
        'subtitle': 'Little or no exercise, mainly office work',
      },
      {
        'value': 'light',
        'title': 'Lightly Active',
        'subtitle': 'Light exercise or work, 1-3 days/week',
      },
      {
        'value': 'moderate',
        'title': 'Moderately Active',
        'subtitle': 'Moderate exercise or work, 3-5 days/week',
      },
      {
        'value': 'active',
        'title': 'Active',
        'subtitle': 'Heavy exercise or work, 6-7 days/week',
      },
      {
        'value': 'very_active',
        'title': 'Very Active',
        'subtitle': 'Very heavy physical work or daily exercise',
      },
    ];
  }

  List<Map<String, dynamic>> _getGoalTypeOptions() {
    return [
      {
        'value': 'maintain',
        'title': 'Maintain Weight',
        'subtitle': 'Keep current weight, balanced nutrition intake',
        'icon': Icons.balance,
      },
      {
        'value': 'lose',
        'title': 'Lose Weight',
        'subtitle': 'Moderately reduce calorie intake, healthy weight loss',
        'icon': Icons.trending_down,
      },
      {
        'value': 'gain',
        'title': 'Gain Weight',
        'subtitle': 'Moderately increase calorie intake, healthy weight gain',
        'icon': Icons.trending_up,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Page content
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

            // Bottom buttons
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }
}

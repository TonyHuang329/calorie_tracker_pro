// lib/screens/health_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_goal.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../utils/calorie_calculator.dart';

class HealthGoalsScreen extends StatefulWidget {
  const HealthGoalsScreen({super.key});

  @override
  State<HealthGoalsScreen> createState() => _HealthGoalsScreenState();
}

class _HealthGoalsScreenState extends State<HealthGoalsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedGoalType = 'maintain';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHealthGoal();
    });
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadHealthGoal() async {
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
    } else {
      _generateDefaultGoal();
    }

    setState(() {
      _isInitialized = true;
    });
  }

  void _generateDefaultGoal() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;

    if (profile != null) {
      final goal = CalorieCalculator.createHealthGoalForUser(
        profile,
        goalType: _selectedGoalType,
      );

      _caloriesController.text = goal.targetCalories.toStringAsFixed(0);
      _proteinController.text = goal.targetProtein.toStringAsFixed(1);
      _carbsController.text = goal.targetCarbs.toStringAsFixed(1);
      _fatController.text = goal.targetFat.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Goals'),
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
                onPressed: _saveGoal,
                child: const Text('Save'),
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

          return Form(
            key: _formKey,
            child: ListView(
              padding: AppTheme.getScreenPadding(context),
              children: [
                _buildGoalTypeSection(),
                const SizedBox(height: 16),
                _buildCustomGoalSection(),
                const SizedBox(height: 16),
                _buildGoalSummary(),
                const SizedBox(height: 16),
                _buildNotesSection(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalTypeSection() {
    return Card(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Type',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._getGoalTypeOptions().map(
              (option) => RadioListTile<String>(
                title: Text(option['title']!),
                subtitle: Text(option['subtitle']!),
                value: option['value']!,
                groupValue: _selectedGoalType,
                onChanged: (value) {
                  setState(() {
                    _selectedGoalType = value!;
                  });
                  _generateDefaultGoal();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomGoalSection() {
    return Card(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Values',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Calorie target
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Target Calories',
                hintText: '2000',
                prefixIcon: Icon(Icons.local_fire_department),
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter target calories';
                }
                final calories = double.tryParse(value.trim());
                if (calories == null || calories < 1000 || calories > 5000) {
                  return 'Please enter a valid calorie target (1000-5000)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Macronutrient targets
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
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSummary() {
    return Card(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final profile = userProvider.userProfile;
                if (profile == null) {
                  return const Text('Please set up your profile first');
                }

                final bmr = CalorieCalculator.calculateBMR(profile);
                final tdee = CalorieCalculator.calculateTDEE(profile);

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildGoalMetric(
                          'Daily Target',
                          double.tryParse(_caloriesController.text)
                                  ?.toStringAsFixed(0) ??
                              '0',
                          'kcal',
                        ),
                        _buildGoalMetric(
                          'BMR',
                          bmr.toStringAsFixed(0),
                          'kcal',
                        ),
                        _buildGoalMetric(
                          'TDEE',
                          tdee.toStringAsFixed(0),
                          'kcal',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildGoalMetric(
                          'Protein',
                          double.tryParse(_proteinController.text)
                                  ?.toStringAsFixed(1) ??
                              '0',
                          'g',
                        ),
                        _buildGoalMetric(
                          'Carbs',
                          double.tryParse(_carbsController.text)
                                  ?.toStringAsFixed(1) ??
                              '0',
                          'g',
                        ),
                        _buildGoalMetric(
                          'Fat',
                          double.tryParse(_fatController.text)
                                  ?.toStringAsFixed(1) ??
                              '0',
                          'g',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalMetric(String title, String value, String unit) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add some notes (optional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getGoalTypeOptions() {
    return [
      {
        'value': 'maintain',
        'title': 'Maintain Weight',
        'subtitle': 'Keep current weight, balanced nutrition intake',
      },
      {
        'value': 'lose',
        'title': 'Lose Weight',
        'subtitle': 'Moderately reduce calorie intake, healthy weight loss',
      },
      {
        'value': 'gain',
        'title': 'Gain Weight',
        'subtitle': 'Moderately increase calorie intake, healthy weight gain',
      },
    ];
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health goals saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}

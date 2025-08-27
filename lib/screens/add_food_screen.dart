import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/nutrition_provider.dart';
import '../utils/app_theme.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  // 表单控制器
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();

  // 表单状态
  String _selectedMealType = 'breakfast';
  DateTime _selectedDate = DateTime.now();

  // 页面状态
  bool _isEdit = false;
  bool _isQuickAdd = false;
  FoodItem? _editingFood;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromArguments();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _initializeFromArguments() {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      _selectedMealType = arguments['mealType'] ?? _selectedMealType;
      _isQuickAdd = arguments['quickAdd'] ?? false;
      _isEdit = arguments['isEdit'] ?? false;
      _editingFood = arguments['foodItem'];

      if (_editingFood != null) {
        _nameController.text = _editingFood!.name;
        _caloriesController.text = _editingFood!.calories.toString();
        _proteinController.text = _editingFood!.protein.toString();
        _carbsController.text = _editingFood!.carbs.toString();
        _fatController.text = _editingFood!.fat.toString();
        _quantityController.text = _editingFood!.quantity?.toString() ?? '';
        _unitController.text = _editingFood!.unit ?? '';
        _selectedMealType = _editingFood!.mealType;
        _selectedDate = _editingFood!.date;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑食物' : (_isQuickAdd ? '快速添加' : '添加食物')),
        actions: [
          Consumer<NutritionProvider>(
            builder: (context, nutritionProvider, child) {
              if (nutritionProvider.isLoading) {
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
                onPressed: _saveFood,
                child: const Text('保存'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NutritionProvider>(
        builder: (context, nutritionProvider, child) {
          return SingleChildScrollView(
            padding: AppTheme.getScreenPadding(context),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nutritionProvider.errorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        nutritionProvider.errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  if (!_isQuickAdd) ...[
                    _buildNutritionSection(),
                    const SizedBox(height: 24),
                    _buildQuantitySection(),
                    const SizedBox(height: 24),
                  ],
                  _buildMealAndDateSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: AppTheme.getCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '食物名称',
                hintText: '请输入食物名称',
                prefixIcon: Icon(Icons.restaurant),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入食物名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: '卡路里',
                hintText: '请输入卡路里',
                prefixIcon: Icon(Icons.local_fire_department),
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入卡路里';
                }
                final calories = double.tryParse(value.trim());
                if (calories == null || calories < 0) {
                  return '请输入有效的卡路里值';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Card(
      child: Padding(
        padding: AppTheme.getCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '营养成分',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: '蛋白质',
                      hintText: '0',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入蛋白质含量';
                      }
                      final protein = double.tryParse(value.trim());
                      if (protein == null || protein < 0) {
                        return '请输入有效值';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: '碳水化合物',
                      hintText: '0',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入碳水含量';
                      }
                      final carbs = double.tryParse(value.trim());
                      if (carbs == null || carbs < 0) {
                        return '请输入有效值';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: const InputDecoration(
                      labelText: '脂肪',
                      hintText: '0',
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入脂肪含量';
                      }
                      final fat = double.tryParse(value.trim());
                      if (fat == null || fat < 0) {
                        return '请输入有效值';
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

  Widget _buildQuantitySection() {
    return Card(
      child: Padding(
        padding: AppTheme.getCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '份量信息',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: '份量',
                      hintText: '100',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: '单位',
                      hintText: 'g',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealAndDateSection() {
    return Card(
      child: Padding(
        padding: AppTheme.getCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '餐次和日期',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // 餐次选择
            Text(
              '餐次',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _getMealTypeOptions()
                  .map(
                    (meal) => ChoiceChip(
                      label: Text(meal['title']!),
                      selected: _selectedMealType == meal['value'],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMealType = meal['value']!;
                          });
                        }
                      },
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            // 日期选择
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('日期'),
              subtitle: Text(
                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getMealTypeOptions() {
    return [
      {'value': 'breakfast', 'title': '早餐'},
      {'value': 'lunch', 'title': '午餐'},
      {'value': 'dinner', 'title': '晚餐'},
      {'value': 'snack', 'title': '零食'},
    ];
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveFood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nutritionProvider =
        Provider.of<NutritionProvider>(context, listen: false);

    // 为快速添加模式设置默认营养值
    double protein = 0, carbs = 0, fat = 0;
    if (!_isQuickAdd) {
      protein = double.parse(_proteinController.text.trim());
      carbs = double.parse(_carbsController.text.trim());
      fat = double.parse(_fatController.text.trim());
    }

    final foodItem = FoodItem(
      id: _editingFood?.id,
      name: _nameController.text.trim(),
      calories: double.parse(_caloriesController.text.trim()),
      protein: protein,
      carbs: carbs,
      fat: fat,
      mealType: _selectedMealType,
      date: _selectedDate,
      quantity: _quantityController.text.trim().isNotEmpty
          ? double.tryParse(_quantityController.text.trim())
          : null,
      unit: _unitController.text.trim().isNotEmpty
          ? _unitController.text.trim()
          : null,
    );

    bool success;
    if (_isEdit && _editingFood != null) {
      success = await nutritionProvider.updateFoodItem(foodItem);
    } else {
      success = await nutritionProvider.addFoodItem(foodItem);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? '食物更新成功' : '食物添加成功'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}

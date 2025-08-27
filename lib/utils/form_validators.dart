// lib/utils/form_validators.dart

class FormValidators {
  // 私有构造函数，防止实例化
  FormValidators._();

  /// 验证姓名
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入姓名';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return '姓名至少需要2个字符';
    }

    if (trimmedValue.length > 20) {
      return '姓名不能超过20个字符';
    }

    // 检查是否包含特殊字符（可选）
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(trimmedValue)) {
      return '姓名不能包含特殊字符';
    }

    return null;
  }

  /// 验证年龄
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入年龄';
    }

    final age = int.tryParse(value.trim());
    if (age == null) {
      return '请输入有效的数字';
    }

    if (age < 10 || age > 120) {
      return '年龄必须在10-120岁之间';
    }

    return null;
  }

  /// 验证身高
  static String? validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入身高';
    }

    final height = double.tryParse(value.trim());
    if (height == null) {
      return '请输入有效的数字';
    }

    if (height < 100 || height > 250) {
      return '身高必须在100-250厘米之间';
    }

    return null;
  }

  /// 验证体重
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入体重';
    }

    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return '请输入有效的数字';
    }

    if (weight < 20 || weight > 300) {
      return '体重必须在20-300公斤之间';
    }

    return null;
  }

  /// 验证目标卡路里
  static String? validateTargetCalories(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入目标卡路里';
    }

    final calories = double.tryParse(value.trim());
    if (calories == null) {
      return '请输入有效的数字';
    }

    if (calories < 800 || calories > 5000) {
      return '目标卡路里必须在800-5000之间';
    }

    return null;
  }

  /// 验证宏量营养素（蛋白质）
  static String? validateProtein(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入蛋白质目标';
    }

    final protein = double.tryParse(value.trim());
    if (protein == null) {
      return '请输入有效的数字';
    }

    if (protein < 0 || protein > 400) {
      return '蛋白质必须在0-400克之间';
    }

    return null;
  }

  /// 验证宏量营养素（碳水化合物）
  static String? validateCarbs(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入碳水目标';
    }

    final carbs = double.tryParse(value.trim());
    if (carbs == null) {
      return '请输入有效的数字';
    }

    if (carbs < 0 || carbs > 600) {
      return '碳水化合物必须在0-600克之间';
    }

    return null;
  }

  /// 验证宏量营养素（脂肪）
  static String? validateFat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入脂肪目标';
    }

    final fat = double.tryParse(value.trim());
    if (fat == null) {
      return '请输入有效的数字';
    }

    if (fat < 0 || fat > 250) {
      return '脂肪必须在0-250克之间';
    }

    return null;
  }

  /// 验证食物名称
  static String? validateFoodName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入食物名称';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 50) {
      return '食物名称不能超过50个字符';
    }

    return null;
  }

  /// 验证卡路里输入
  static String? validateCalories(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入卡路里';
    }

    final calories = double.tryParse(value.trim());
    if (calories == null) {
      return '请输入有效的数字';
    }

    if (calories < 0 || calories > 2000) {
      return '单份食物卡路里必须在0-2000之间';
    }

    return null;
  }

  /// 验证营养成分（用于食物录入）
  static String? validateNutrientAmount(String? value, String nutrientName) {
    if (value == null || value.trim().isEmpty) {
      return '请输入${nutrientName}含量';
    }

    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return '请输入有效的数字';
    }

    if (amount < 0) {
      return '${nutrientName}含量不能为负数';
    }

    // 设置合理的上限
    double maxAmount = 200; // 默认最大值
    switch (nutrientName) {
      case '蛋白质':
      case '碳水化合物':
        maxAmount = 200;
        break;
      case '脂肪':
        maxAmount = 100;
        break;
      default:
        maxAmount = 200;
    }

    if (amount > maxAmount) {
      return '${nutrientName}含量不能超过${maxAmount.toInt()}克';
    }

    return null;
  }

  /// 验证数量
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 数量是可选的
    }

    final quantity = double.tryParse(value.trim());
    if (quantity == null) {
      return '请输入有效的数字';
    }

    if (quantity <= 0) {
      return '数量必须大于0';
    }

    if (quantity > 10000) {
      return '数量不能超过10000';
    }

    return null;
  }

  /// 验证单位
  static String? validateUnit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 单位是可选的
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 10) {
      return '单位不能超过10个字符';
    }

    return null;
  }

  /// 验证备注
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 备注是可选的
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 200) {
      return '备注不能超过200个字符';
    }

    return null;
  }

  /// 综合验证用户资料
  static Map<String, String> validateUserProfile({
    required String name,
    required String age,
    required String height,
    required String weight,
    required String gender,
    required String activityLevel,
  }) {
    final errors = <String, String>{};

    final nameError = validateName(name);
    if (nameError != null) errors['name'] = nameError;

    final ageError = validateAge(age);
    if (ageError != null) errors['age'] = ageError;

    final heightError = validateHeight(height);
    if (heightError != null) errors['height'] = heightError;

    final weightError = validateWeight(weight);
    if (weightError != null) errors['weight'] = weightError;

    if (!['male', 'female'].contains(gender)) {
      errors['gender'] = '请选择性别';
    }

    const validActivityLevels = [
      'sedentary',
      'light',
      'moderate',
      'active',
      'very_active'
    ];
    if (!validActivityLevels.contains(activityLevel)) {
      errors['activityLevel'] = '请选择活动水平';
    }

    return errors;
  }

  /// 综合验证健康目标
  static Map<String, String> validateHealthGoal({
    required String targetCalories,
    required String targetProtein,
    required String targetCarbs,
    required String targetFat,
    String? notes,
  }) {
    final errors = <String, String>{};

    final caloriesError = validateTargetCalories(targetCalories);
    if (caloriesError != null) errors['targetCalories'] = caloriesError;

    final proteinError = validateProtein(targetProtein);
    if (proteinError != null) errors['targetProtein'] = proteinError;

    final carbsError = validateCarbs(targetCarbs);
    if (carbsError != null) errors['targetCarbs'] = carbsError;

    final fatError = validateFat(targetFat);
    if (fatError != null) errors['targetFat'] = fatError;

    final notesError = validateNotes(notes);
    if (notesError != null) errors['notes'] = notesError;

    // 验证宏量营养素比例是否合理
    if (errors.isEmpty) {
      final calories = double.parse(targetCalories);
      final protein = double.parse(targetProtein);
      final carbs = double.parse(targetCarbs);
      final fat = double.parse(targetFat);

      final macroCalories = (protein * 4) + (carbs * 4) + (fat * 9);
      final difference = (macroCalories - calories).abs();
      final tolerance = calories * 0.15; // 允许15%的误差

      if (difference > tolerance) {
        errors['macroBalance'] = '宏量营养素配比与总卡路里不匹配，请检查数值';
      }
    }

    return errors;
  }

  /// 实时验证（用于输入时的即时反馈）
  static String? validateRealTime(String? value, String fieldType) {
    if (value == null || value.trim().isEmpty) {
      return null; // 实时验证时不显示"必填"错误
    }

    switch (fieldType.toLowerCase()) {
      case 'age':
        final age = int.tryParse(value.trim());
        if (age != null && (age < 10 || age > 120)) {
          return '年龄范围：10-120岁';
        }
        break;
      case 'height':
        final height = double.tryParse(value.trim());
        if (height != null && (height < 100 || height > 250)) {
          return '身高范围：100-250cm';
        }
        break;
      case 'weight':
        final weight = double.tryParse(value.trim());
        if (weight != null && (weight < 20 || weight > 300)) {
          return '体重范围：20-300kg';
        }
        break;
      case 'calories':
        final calories = double.tryParse(value.trim());
        if (calories != null && (calories < 0 || calories > 2000)) {
          return '卡路里范围：0-2000';
        }
        break;
    }

    return null;
  }
}

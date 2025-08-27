// lib/utils/form_validators.dart

/// Form validation utility class
/// Provides validation methods for all form inputs in the application
class FormValidators {
  // Private constructor to prevent instantiation
  FormValidators._();

  /// Validate name input
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (trimmedValue.length > 50) {
      return 'Name cannot exceed 50 characters';
    }

    // Check for invalid characters (optional)
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(trimmedValue)) {
      return 'Name cannot contain special characters';
    }

    return null;
  }

  /// Validate age input
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your age';
    }

    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Please enter a valid number';
    }

    if (age < 13 || age > 120) {
      return 'Age must be between 13 and 120 years';
    }

    return null;
  }

  /// Validate height input
  static String? validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your height';
    }

    final height = double.tryParse(value.trim());
    if (height == null) {
      return 'Please enter a valid number';
    }

    if (height < 100 || height > 250) {
      return 'Height must be between 100 and 250 cm';
    }

    return null;
  }

  /// Validate weight input
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your weight';
    }

    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (weight < 30 || weight > 300) {
      return 'Weight must be between 30 and 300 kg';
    }

    return null;
  }

  /// Validate target calories input
  static String? validateTargetCalories(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter target calories';
    }

    final calories = double.tryParse(value.trim());
    if (calories == null) {
      return 'Please enter a valid number';
    }

    if (calories < 1000 || calories > 5000) {
      return 'Target calories must be between 1000 and 5000';
    }

    return null;
  }

  /// Validate protein target input
  static String? validateProtein(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter protein target';
    }

    final protein = double.tryParse(value.trim());
    if (protein == null) {
      return 'Please enter a valid number';
    }

    if (protein < 0 || protein > 400) {
      return 'Protein must be between 0 and 400 grams';
    }

    return null;
  }

  /// Validate carbohydrate target input
  static String? validateCarbs(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter carbs target';
    }

    final carbs = double.tryParse(value.trim());
    if (carbs == null) {
      return 'Please enter a valid number';
    }

    if (carbs < 0 || carbs > 600) {
      return 'Carbohydrates must be between 0 and 600 grams';
    }

    return null;
  }

  /// Validate fat target input
  static String? validateFat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter fat target';
    }

    final fat = double.tryParse(value.trim());
    if (fat == null) {
      return 'Please enter a valid number';
    }

    if (fat < 0 || fat > 250) {
      return 'Fat must be between 0 and 250 grams';
    }

    return null;
  }

  /// Validate food name input
  static String? validateFoodName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter food name';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 100) {
      return 'Food name cannot exceed 100 characters';
    }

    return null;
  }

  /// Validate calories input for food items
  static String? validateCalories(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter calories';
    }

    final calories = double.tryParse(value.trim());
    if (calories == null) {
      return 'Please enter a valid number';
    }

    if (calories < 0 || calories > 2000) {
      return 'Calories per serving must be between 0 and 2000';
    }

    return null;
  }

  /// Validate nutrient amount input (for food entry)
  static String? validateNutrientAmount(String? value, String nutrientName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $nutrientName content';
    }

    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount < 0) {
      return '$nutrientName content cannot be negative';
    }

    // Set reasonable upper limits
    double maxAmount = 200; // Default maximum
    switch (nutrientName.toLowerCase()) {
      case 'protein':
      case 'carbs':
      case 'carbohydrates':
        maxAmount = 200;
        break;
      case 'fat':
        maxAmount = 100;
        break;
      default:
        maxAmount = 200;
    }

    if (amount > maxAmount) {
      return '$nutrientName content cannot exceed ${maxAmount.toInt()} grams';
    }

    return null;
  }

  /// Validate quantity input
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Quantity is optional
    }

    final quantity = double.tryParse(value.trim());
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    if (quantity > 10000) {
      return 'Quantity cannot exceed 10000';
    }

    return null;
  }

  /// Validate unit input
  static String? validateUnit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Unit is optional
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 20) {
      return 'Unit cannot exceed 20 characters';
    }

    return null;
  }

  /// Validate notes input
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Notes are optional
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 500) {
      return 'Notes cannot exceed 500 characters';
    }

    return null;
  }

  /// Validate email input
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final trimmedValue = value.trim();
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password input
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (value.length > 128) {
      return 'Password cannot exceed 128 characters';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate phone number input
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone number is optional
    }

    final trimmedValue = value.trim();
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');

    if (!phoneRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid phone number';
    }

    // Remove non-digit characters to check length
    final digitsOnly = trimmedValue.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Phone number must be between 10 and 15 digits';
    }

    return null;
  }

  /// Validate water intake input
  static String? validateWaterIntake(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter water intake';
    }

    final water = double.tryParse(value.trim());
    if (water == null) {
      return 'Please enter a valid number';
    }

    if (water < 0 || water > 10) {
      return 'Water intake must be between 0 and 10 liters';
    }

    return null;
  }

  /// Validate exercise duration input
  static String? validateExerciseDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter exercise duration';
    }

    final duration = int.tryParse(value.trim());
    if (duration == null) {
      return 'Please enter a valid number';
    }

    if (duration < 1 || duration > 600) {
      return 'Duration must be between 1 and 600 minutes';
    }

    return null;
  }

  /// Comprehensive user profile validation
  static Map<String, String> validateUserProfile({
    required String name,
    required String age,
    required String height,
    required String weight,
    required String gender,
    required String activityLevel,
    String? email,
    String? phone,
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

    if (!['male', 'female'].contains(gender.toLowerCase())) {
      errors['gender'] = 'Please select a valid gender';
    }

    const validActivityLevels = [
      'sedentary',
      'light',
      'moderate',
      'active',
      'very_active'
    ];
    if (!validActivityLevels.contains(activityLevel)) {
      errors['activityLevel'] = 'Please select a valid activity level';
    }

    if (email != null && email.isNotEmpty) {
      final emailError = validateEmail(email);
      if (emailError != null) errors['email'] = emailError;
    }

    if (phone != null && phone.isNotEmpty) {
      final phoneError = validatePhoneNumber(phone);
      if (phoneError != null) errors['phone'] = phoneError;
    }

    return errors;
  }

  /// Comprehensive health goal validation
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

    // Validate macro balance if all fields are valid
    if (errors.isEmpty) {
      final calories = double.parse(targetCalories);
      final protein = double.parse(targetProtein);
      final carbs = double.parse(targetCarbs);
      final fat = double.parse(targetFat);

      final macroCalories = (protein * 4) + (carbs * 4) + (fat * 9);
      final difference = (macroCalories - calories).abs();
      final tolerance = calories * 0.15; // Allow 15% tolerance

      if (difference > tolerance) {
        errors['macroBalance'] =
            'Macronutrient distribution doesn\'t match total calories';
      }
    }

    return errors;
  }

  /// Comprehensive food item validation
  static Map<String, String> validateFoodItem({
    required String name,
    required String calories,
    required String protein,
    required String carbs,
    required String fat,
    String? quantity,
    String? unit,
    String? notes,
  }) {
    final errors = <String, String>{};

    final nameError = validateFoodName(name);
    if (nameError != null) errors['name'] = nameError;

    final caloriesError = validateCalories(calories);
    if (caloriesError != null) errors['calories'] = caloriesError;

    final proteinError = validateNutrientAmount(protein, 'Protein');
    if (proteinError != null) errors['protein'] = proteinError;

    final carbsError = validateNutrientAmount(carbs, 'Carbs');
    if (carbsError != null) errors['carbs'] = carbsError;

    final fatError = validateNutrientAmount(fat, 'Fat');
    if (fatError != null) errors['fat'] = fatError;

    final quantityError = validateQuantity(quantity);
    if (quantityError != null) errors['quantity'] = quantityError;

    final unitError = validateUnit(unit);
    if (unitError != null) errors['unit'] = unitError;

    final notesError = validateNotes(notes);
    if (notesError != null) errors['notes'] = notesError;

    return errors;
  }

  /// Real-time validation (for input field feedback)
  static String? validateRealTime(String? value, String fieldType) {
    if (value == null || value.trim().isEmpty) {
      return null; // Don't show "required" errors during real-time validation
    }

    switch (fieldType.toLowerCase()) {
      case 'age':
        final age = int.tryParse(value.trim());
        if (age != null && (age < 13 || age > 120)) {
          return 'Age range: 13-120 years';
        }
        break;
      case 'height':
        final height = double.tryParse(value.trim());
        if (height != null && (height < 100 || height > 250)) {
          return 'Height range: 100-250 cm';
        }
        break;
      case 'weight':
        final weight = double.tryParse(value.trim());
        if (weight != null && (weight < 30 || weight > 300)) {
          return 'Weight range: 30-300 kg';
        }
        break;
      case 'calories':
        final calories = double.tryParse(value.trim());
        if (calories != null && (calories < 0 || calories > 2000)) {
          return 'Calories range: 0-2000';
        }
        break;
      case 'target_calories':
        final calories = double.tryParse(value.trim());
        if (calories != null && (calories < 1000 || calories > 5000)) {
          return 'Target calories range: 1000-5000';
        }
        break;
      case 'protein':
        final protein = double.tryParse(value.trim());
        if (protein != null && (protein < 0 || protein > 400)) {
          return 'Protein range: 0-400g';
        }
        break;
      case 'carbs':
        final carbs = double.tryParse(value.trim());
        if (carbs != null && (carbs < 0 || carbs > 600)) {
          return 'Carbs range: 0-600g';
        }
        break;
      case 'fat':
        final fat = double.tryParse(value.trim());
        if (fat != null && (fat < 0 || fat > 250)) {
          return 'Fat range: 0-250g';
        }
        break;
      case 'water':
        final water = double.tryParse(value.trim());
        if (water != null && (water < 0 || water > 10)) {
          return 'Water range: 0-10L';
        }
        break;
    }

    return null;
  }

  /// Check if field is required
  static bool isFieldRequired(String fieldType) {
    const requiredFields = [
      'name',
      'age',
      'height',
      'weight',
      'gender',
      'activityLevel',
      'targetCalories',
      'targetProtein',
      'targetCarbs',
      'targetFat',
      'foodName',
      'calories',
      'protein',
      'carbs',
      'fat',
    ];

    return requiredFields.contains(fieldType);
  }

  /// Get field display name for error messages
  static String getFieldDisplayName(String fieldType) {
    const fieldNames = {
      'name': 'Name',
      'age': 'Age',
      'height': 'Height',
      'weight': 'Weight',
      'gender': 'Gender',
      'activityLevel': 'Activity Level',
      'targetCalories': 'Target Calories',
      'targetProtein': 'Target Protein',
      'targetCarbs': 'Target Carbs',
      'targetFat': 'Target Fat',
      'foodName': 'Food Name',
      'calories': 'Calories',
      'protein': 'Protein',
      'carbs': 'Carbohydrates',
      'fat': 'Fat',
      'quantity': 'Quantity',
      'unit': 'Unit',
      'notes': 'Notes',
      'email': 'Email',
      'phone': 'Phone Number',
      'password': 'Password',
      'water': 'Water Intake',
      'exercise_duration': 'Exercise Duration',
    };

    return fieldNames[fieldType] ?? fieldType;
  }

  /// Get input hints for different field types
  static String? getInputHint(String fieldType) {
    const hints = {
      'age': 'Enter your age (13-120)',
      'height': 'Enter height in cm (100-250)',
      'weight': 'Enter weight in kg (30-300)',
      'targetCalories': 'Enter daily calorie target (1000-5000)',
      'calories': 'Enter calories per serving (0-2000)',
      'protein': 'Enter protein content in grams',
      'carbs': 'Enter carbs content in grams',
      'fat': 'Enter fat content in grams',
      'quantity': 'Enter portion size (optional)',
      'unit': 'Enter unit (g, ml, cup, etc.)',
      'email': 'Enter your email address',
      'phone': 'Enter your phone number',
      'water': 'Enter daily water intake in liters',
      'exercise_duration': 'Enter duration in minutes',
    };

    return hints[fieldType];
  }
}

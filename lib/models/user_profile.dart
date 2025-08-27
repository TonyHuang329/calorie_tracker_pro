// lib/models/user_profile.dart

/// User profile data model
/// Stores basic user information including physical characteristics and activity level
class UserProfile {
  final int? id;
  final String name;
  final int age;
  final String gender; // 'male' or 'female'
  final double height; // cm
  final double weight; // kg
  final String
      activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert object to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Create object from Map for database reading
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
      activityLevel: map['activityLevel'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create copy for updating object
  UserProfile copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, name: $name, age: $age, gender: $gender, '
        'height: $height, weight: $weight, activityLevel: $activityLevel}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.age == age &&
        other.gender == gender &&
        other.height == height &&
        other.weight == weight &&
        other.activityLevel == activityLevel;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, age, gender, height, weight, activityLevel);
  }

  /// Activity level display name
  String get activityLevelDisplayName {
    switch (activityLevel) {
      case 'sedentary':
        return 'Sedentary (Little to no exercise)';
      case 'light':
        return 'Lightly Active (Light exercise 1-3 days/week)';
      case 'moderate':
        return 'Moderately Active (Moderate exercise 3-5 days/week)';
      case 'active':
        return 'Active (Heavy exercise 6-7 days/week)';
      case 'very_active':
        return 'Very Active (Very heavy physical work or daily exercise)';
      default:
        return activityLevel;
    }
  }

  /// Gender display name
  String get genderDisplayName {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return gender;
    }
  }

  /// Calculate BMI (Body Mass Index)
  double get bmi {
    if (height <= 0 || weight <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal weight';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Get BMI status color indicator
  String get bmiStatus {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'low';
    if (bmiValue < 25) return 'normal';
    if (bmiValue < 30) return 'high';
    return 'very_high';
  }

  /// Calculate ideal weight range based on BMI
  Map<String, double> get idealWeightRange {
    if (height <= 0) return {'min': 0, 'max': 0};

    final heightInMeters = height / 100;
    final minWeight = 18.5 * heightInMeters * heightInMeters;
    final maxWeight = 24.9 * heightInMeters * heightInMeters;

    return {
      'min': minWeight,
      'max': maxWeight,
    };
  }

  /// Check if current weight is in ideal range
  bool get isWeightInIdealRange {
    final range = idealWeightRange;
    return weight >= range['min']! && weight <= range['max']!;
  }

  /// Get weight status relative to ideal range
  String get weightStatus {
    final range = idealWeightRange;
    if (weight < range['min']!) return 'underweight';
    if (weight > range['max']!) return 'overweight';
    return 'normal';
  }

  /// Get activity level multiplier for TDEE calculation
  double get activityMultiplier {
    switch (activityLevel) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.2;
    }
  }

  /// Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor equation
  double get bmr {
    if (weight <= 0 || height <= 0 || age <= 0) return 0;

    final baseCalculation = (10 * weight) + (6.25 * height) - (5 * age);

    switch (gender.toLowerCase()) {
      case 'male':
        return baseCalculation + 5;
      case 'female':
        return baseCalculation - 161;
      default:
        return baseCalculation; // Default calculation
    }
  }

  /// Calculate Total Daily Energy Expenditure (TDEE)
  double get tdee {
    return bmr * activityMultiplier;
  }

  /// Get formatted height string
  String get formattedHeight {
    return '${height.toInt()} cm';
  }

  /// Get formatted weight string
  String get formattedWeight {
    return weight % 1 == 0
        ? '${weight.toInt()} kg'
        : '${weight.toStringAsFixed(1)} kg';
  }

  /// Get formatted BMI string
  String get formattedBmi {
    return bmi.toStringAsFixed(1);
  }

  /// Get age group classification
  String get ageGroup {
    if (age < 18) return 'Under 18';
    if (age < 25) return '18-24';
    if (age < 35) return '25-34';
    if (age < 45) return '35-44';
    if (age < 55) return '45-54';
    if (age < 65) return '55-64';
    return '65+';
  }

  /// Check if profile is complete
  bool get isComplete {
    return name.isNotEmpty &&
        age > 0 &&
        height > 0 &&
        weight > 0 &&
        gender.isNotEmpty &&
        activityLevel.isNotEmpty;
  }

  /// Validate user profile data
  List<String> validate() {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Name cannot be empty');
    }

    if (name.trim().length < 2) {
      errors.add('Name must be at least 2 characters');
    }

    if (age < 10 || age > 120) {
      errors.add('Age must be between 10 and 120 years');
    }

    if (height < 100 || height > 250) {
      errors.add('Height must be between 100 and 250 cm');
    }

    if (weight < 20 || weight > 300) {
      errors.add('Weight must be between 20 and 300 kg');
    }

    if (!['male', 'female'].contains(gender.toLowerCase())) {
      errors.add('Please select a valid gender');
    }

    const validActivityLevels = [
      'sedentary',
      'light',
      'moderate',
      'active',
      'very_active'
    ];
    if (!validActivityLevels.contains(activityLevel)) {
      errors.add('Please select a valid activity level');
    }

    return errors;
  }

  /// Get health recommendations based on profile
  List<String> getHealthRecommendations() {
    final recommendations = <String>[];

    // BMI-based recommendations
    final bmiValue = bmi;
    if (bmiValue < 18.5) {
      recommendations
          .add('Consider gaining weight through healthy diet and exercise');
      recommendations.add('Increase protein and healthy fat intake');
    } else if (bmiValue > 25) {
      recommendations
          .add('Consider weight management through balanced diet and exercise');
      recommendations
          .add('Focus on portion control and regular physical activity');
    } else {
      recommendations.add('Maintain your current healthy weight range');
    }

    // Age-based recommendations
    if (age >= 50) {
      recommendations.add('Consider increasing calcium and vitamin D intake');
      recommendations.add('Include low-impact exercises and strength training');
    } else if (age <= 25) {
      recommendations.add('Great time to establish healthy eating habits');
      recommendations
          .add('Vary your exercise routine to build overall fitness');
    }

    // Activity level recommendations
    if (activityLevel == 'sedentary') {
      recommendations.add('Try to increase daily physical activity');
      recommendations.add('Start with 30 minutes of walking daily');
    } else if (activityLevel == 'very_active') {
      recommendations.add('Ensure adequate recovery time between workouts');
      recommendations
          .add('Focus on proper nutrition to support high activity levels');
    }

    return recommendations;
  }

  /// Create sample user profile (for testing)
  static UserProfile createSample({String name = 'John Doe'}) {
    return UserProfile(
      id: 1,
      name: name,
      age: 30,
      gender: 'male',
      height: 175.0,
      weight: 70.0,
      activityLevel: 'moderate',
      createdAt: DateTime.now(),
    );
  }

  /// Get all valid activity level options
  static List<Map<String, String>> getActivityLevelOptions() {
    return [
      {
        'value': 'sedentary',
        'title': 'Sedentary',
        'subtitle': 'Little to no exercise, mostly desk work',
      },
      {
        'value': 'light',
        'title': 'Lightly Active',
        'subtitle': 'Light exercise or sports 1-3 days/week',
      },
      {
        'value': 'moderate',
        'title': 'Moderately Active',
        'subtitle': 'Moderate exercise or sports 3-5 days/week',
      },
      {
        'value': 'active',
        'title': 'Active',
        'subtitle': 'Heavy exercise or sports 6-7 days/week',
      },
      {
        'value': 'very_active',
        'title': 'Very Active',
        'subtitle': 'Very heavy physical work or daily exercise',
      },
    ];
  }

  /// Get all valid gender options
  static List<Map<String, String>> getGenderOptions() {
    return [
      {'value': 'male', 'title': 'Male'},
      {'value': 'female', 'title': 'Female'},
    ];
  }

  /// Convert to JSON format (for export/import)
  Map<String, dynamic> toJson() {
    return toMap();
  }

  /// Create instance from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile.fromMap(json);
  }
}

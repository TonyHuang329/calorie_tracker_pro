class UserProfile {
  final int? id;
  final String name;
  final int age;
  final String gender; // 'male' or 'female'
  final double height; // cm
  final double weight; // kg
  final String
      activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'

  const UserProfile({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
  });

  // 将对象转换为Map，用于数据库操作
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
    };
  }

  // 从Map创建对象，用于从数据库读取
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      height: map['height'] as double,
      weight: map['weight'] as double,
      activityLevel: map['activityLevel'] as String,
    );
  }

  // 创建副本，用于更新对象
  UserProfile copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, name: $name, age: $age, gender: $gender, height: $height, weight: $weight, activityLevel: $activityLevel}';
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

  // 活动水平的显示名称
  String get activityLevelDisplayName {
    switch (activityLevel) {
      case 'sedentary':
        return '久坐 (很少运动)';
      case 'light':
        return '轻度活跃 (轻度运动1-3天/周)';
      case 'moderate':
        return '中度活跃 (中度运动3-5天/周)';
      case 'active':
        return '活跃 (重度运动6-7天/周)';
      case 'very_active':
        return '非常活跃 (重体力劳动或每日运动)';
      default:
        return activityLevel;
    }
  }

  // 性别显示名称
  String get genderDisplayName {
    switch (gender) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      default:
        return gender;
    }
  }
}

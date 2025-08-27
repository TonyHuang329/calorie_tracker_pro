import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_profile.dart';
import '../models/food_item.dart';
import '../models/health_goal.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  // 私有构造函数，实现单例模式
  DatabaseService._internal();

  // 获取单例实例
  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  // 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDB() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'calorie_tracker.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  // 创建数据库表
  Future<void> _createDB(Database db, int version) async {
    try {
      // 创建用户配置表
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          age INTEGER NOT NULL,
          gender TEXT NOT NULL,
          height REAL NOT NULL,
          weight REAL NOT NULL,
          activityLevel TEXT NOT NULL
        )
      ''');

      // 创建食物条目表
      await db.execute('''
        CREATE TABLE food_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          calories REAL NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          mealType TEXT NOT NULL,
          date TEXT NOT NULL,
          quantity REAL,
          unit TEXT
        )
      ''');

      // 创建健康目标表
      await db.execute('''
        CREATE TABLE health_goals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          targetCalories REAL NOT NULL,
          targetProtein REAL NOT NULL,
          targetCarbs REAL NOT NULL,
          targetFat REAL NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT,
          goalType TEXT,
          notes TEXT
        )
      ''');

      // 创建索引以提高查询性能
      await db.execute('CREATE INDEX idx_food_items_date ON food_items(date)');
      await db.execute(
          'CREATE INDEX idx_food_items_meal_type ON food_items(mealType)');
    } catch (e) {
      throw Exception('Failed to create database tables: $e');
    }
  }

  // 数据库升级
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级时的逻辑
    if (oldVersion < newVersion) {
      // 执行升级脚本
    }
  }

  // === 用户配置相关操作 ===

  // 插入或更新用户配置（只保留一个用户）
  Future<int> insertOrUpdateUserProfile(UserProfile profile) async {
    try {
      final db = await database;

      // 先检查是否已有用户
      final existingUsers = await db.query('users');

      if (existingUsers.isEmpty) {
        // 插入新用户
        return await db.insert('users', profile.toMap());
      } else {
        // 更新现有用户
        return await db.update(
          'users',
          profile.toMap(),
          where: 'id = ?',
          whereArgs: [existingUsers.first['id']],
        );
      }
    } catch (e) {
      throw Exception('Failed to insert/update user profile: $e');
    }
  }

  // 获取用户配置
  Future<UserProfile?> getUserProfile() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('users');

      if (maps.isEmpty) return null;

      return UserProfile.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // === 食物条目相关操作 ===

  // 插入食物条目
  Future<int> insertFoodItem(FoodItem foodItem) async {
    try {
      final db = await database;
      return await db.insert('food_items', foodItem.toMap());
    } catch (e) {
      throw Exception('Failed to insert food item: $e');
    }
  }

  // 更新食物条目
  Future<int> updateFoodItem(FoodItem foodItem) async {
    try {
      final db = await database;
      return await db.update(
        'food_items',
        foodItem.toMap(),
        where: 'id = ?',
        whereArgs: [foodItem.id],
      );
    } catch (e) {
      throw Exception('Failed to update food item: $e');
    }
  }

  // 删除食物条目
  Future<int> deleteFoodItem(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'food_items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete food item: $e');
    }
  }

  // 根据日期获取食物条目
  Future<List<FoodItem>> getFoodItemsByDate(DateTime date) async {
    try {
      final db = await database;
      final dateString = date.toIso8601String().substring(0, 10); // YYYY-MM-DD

      final List<Map<String, dynamic>> maps = await db.query(
        'food_items',
        where: 'date LIKE ?',
        whereArgs: ['$dateString%'],
        orderBy: 'mealType, name',
      );

      return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get food items by date: $e');
    }
  }

  // 根据日期范围获取食物条目
  Future<List<FoodItem>> getFoodItemsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final db = await database;
      final startDateString = startDate.toIso8601String().substring(0, 10);
      final endDateString = endDate.toIso8601String().substring(0, 10);

      final List<Map<String, dynamic>> maps = await db.query(
        'food_items',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startDateString, '$endDateString 23:59:59'],
        orderBy: 'date DESC, mealType',
      );

      return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get food items by date range: $e');
    }
  }

  // 根据餐次类型获取食物条目
  Future<List<FoodItem>> getFoodItemsByMealType(
      DateTime date, String mealType) async {
    try {
      final db = await database;
      final dateString = date.toIso8601String().substring(0, 10);

      final List<Map<String, dynamic>> maps = await db.query(
        'food_items',
        where: 'date LIKE ? AND mealType = ?',
        whereArgs: ['$dateString%', mealType],
        orderBy: 'name',
      );

      return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get food items by meal type: $e');
    }
  }

  // 获取所有食物条目
  Future<List<FoodItem>> getAllFoodItems() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'food_items',
        orderBy: 'date DESC, mealType',
      );

      return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get all food items: $e');
    }
  }

  // === 健康目标相关操作 ===

  // 插入健康目标
  Future<int> insertHealthGoal(HealthGoal goal) async {
    try {
      final db = await database;
      return await db.insert('health_goals', goal.toMap());
    } catch (e) {
      throw Exception('Failed to insert health goal: $e');
    }
  }

  // 更新健康目标
  Future<int> updateHealthGoal(HealthGoal goal) async {
    try {
      final db = await database;
      return await db.update(
        'health_goals',
        goal.toMap(),
        where: 'id = ?',
        whereArgs: [goal.id],
      );
    } catch (e) {
      throw Exception('Failed to update health goal: $e');
    }
  }

  // 插入或更新当前健康目标（只保留最新的一个）
  Future<int> insertOrUpdateCurrentHealthGoal(HealthGoal goal) async {
    try {
      final db = await database;

      // 先删除所有旧的目标
      await db.delete('health_goals');

      // 插入新目标
      return await db.insert('health_goals', goal.toMap());
    } catch (e) {
      throw Exception('Failed to insert/update current health goal: $e');
    }
  }

  // 获取当前健康目标
  Future<HealthGoal?> getCurrentHealthGoal() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'health_goals',
        orderBy: 'createdAt DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;

      return HealthGoal.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get current health goal: $e');
    }
  }

  // 删除健康目标
  Future<int> deleteHealthGoal(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'health_goals',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete health goal: $e');
    }
  }

  // === 统计和分析相关操作 ===

  // 获取指定日期的营养摄入总计
  Future<Map<String, double>> getDailyNutritionSummary(DateTime date) async {
    try {
      final db = await database;
      final dateString = date.toIso8601String().substring(0, 10);

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT 
          SUM(calories) as totalCalories,
          SUM(protein) as totalProtein,
          SUM(carbs) as totalCarbs,
          SUM(fat) as totalFat
        FROM food_items 
        WHERE date LIKE ?
      ''', ['$dateString%']);

      if (result.isEmpty || result.first['totalCalories'] == null) {
        return {
          'totalCalories': 0.0,
          'totalProtein': 0.0,
          'totalCarbs': 0.0,
          'totalFat': 0.0,
        };
      }

      return {
        'totalCalories':
            (result.first['totalCalories'] as num?)?.toDouble() ?? 0.0,
        'totalProtein':
            (result.first['totalProtein'] as num?)?.toDouble() ?? 0.0,
        'totalCarbs': (result.first['totalCarbs'] as num?)?.toDouble() ?? 0.0,
        'totalFat': (result.first['totalFat'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get daily nutrition summary: $e');
    }
  }

  // 获取按餐次分组的营养摄入
  Future<Map<String, Map<String, double>>> getDailyNutritionByMeal(
      DateTime date) async {
    try {
      final db = await database;
      final dateString = date.toIso8601String().substring(0, 10);

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT 
          mealType,
          SUM(calories) as totalCalories,
          SUM(protein) as totalProtein,
          SUM(carbs) as totalCarbs,
          SUM(fat) as totalFat
        FROM food_items 
        WHERE date LIKE ?
        GROUP BY mealType
      ''', ['$dateString%']);

      Map<String, Map<String, double>> mealSummary = {};

      for (var row in result) {
        mealSummary[row['mealType'] as String] = {
          'totalCalories': (row['totalCalories'] as num?)?.toDouble() ?? 0.0,
          'totalProtein': (row['totalProtein'] as num?)?.toDouble() ?? 0.0,
          'totalCarbs': (row['totalCarbs'] as num?)?.toDouble() ?? 0.0,
          'totalFat': (row['totalFat'] as num?)?.toDouble() ?? 0.0,
        };
      }

      return mealSummary;
    } catch (e) {
      throw Exception('Failed to get daily nutrition by meal: $e');
    }
  }

  // 获取一周的卡路里摄入数据
  Future<List<Map<String, dynamic>>> getWeeklyCalorieData(
      DateTime startDate) async {
    try {
      final db = await database;
      final endDate = startDate.add(const Duration(days: 6));
      final startDateString = startDate.toIso8601String().substring(0, 10);
      final endDateString = endDate.toIso8601String().substring(0, 10);

      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT 
          DATE(date) as date,
          SUM(calories) as totalCalories
        FROM food_items 
        WHERE date >= ? AND date <= ?
        GROUP BY DATE(date)
        ORDER BY date
      ''', [startDateString, '$endDateString 23:59:59']);

      return result
          .map((row) => {
                'date': row['date'] as String,
                'totalCalories':
                    (row['totalCalories'] as num?)?.toDouble() ?? 0.0,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get weekly calorie data: $e');
    }
  }

  // === 数据库维护操作 ===

  // 清理数据库
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('users');
      await db.delete('food_items');
      await db.delete('health_goals');
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  // 关闭数据库连接
  Future<void> closeDatabase() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
    } catch (e) {
      throw Exception('Failed to close database: $e');
    }
  }

  // 检查数据库是否存在
  Future<bool> databaseExists() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'calorie_tracker.db');
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  // 获取数据库路径（用于调试）
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, 'calorie_tracker.db');
  }

  // 备份数据库
  Future<void> backupDatabase(String backupPath) async {
    try {
      final currentPath = await getDatabasePath();
      final currentFile = File(currentPath);

      if (await currentFile.exists()) {
        await currentFile.copy(backupPath);
      } else {
        throw Exception('Database file does not exist');
      }
    } catch (e) {
      throw Exception('Failed to backup database: $e');
    }
  }

  // 恢复数据库
  Future<void> restoreDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist');
      }

      // 关闭当前数据库连接
      await closeDatabase();

      // 复制备份文件到数据库位置
      final currentPath = await getDatabasePath();
      await backupFile.copy(currentPath);

      // 重新初始化数据库
      _database = await _initDB();
    } catch (e) {
      throw Exception('Failed to restore database: $e');
    }
  }
}

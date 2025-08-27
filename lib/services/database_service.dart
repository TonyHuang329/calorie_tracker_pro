// lib/services/database_service.dart

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

  // Private constructor to implement singleton pattern
  DatabaseService._internal();

  // Get singleton instance
  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  // Initialize database
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

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    try {
      // Create user profile table
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

      // Create food items table
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

      // Create health goals table
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

      // Create indexes to improve query performance
      await db.execute('CREATE INDEX idx_food_items_date ON food_items(date)');
      await db.execute(
          'CREATE INDEX idx_food_items_meal_type ON food_items(mealType)');
    } catch (e) {
      throw Exception('Failed to create database tables: $e');
    }
  }

  // Database upgrade
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Logic for future version upgrades
    if (oldVersion < newVersion) {
      // Execute upgrade scripts
    }
  }

  // === User profile related operations ===

  // Insert or update user profile (keep only one user)
  Future<int> insertOrUpdateUserProfile(UserProfile profile) async {
    try {
      final db = await database;

      // Check if user already exists
      final existingUsers = await db.query('users');

      if (existingUsers.isEmpty) {
        // Insert new user
        return await db.insert('users', profile.toMap());
      } else {
        // Update existing user
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

  // Get user profile
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

  // === Food item related operations ===

  // Insert food item
  Future<int> insertFoodItem(FoodItem foodItem) async {
    try {
      final db = await database;
      return await db.insert('food_items', foodItem.toMap());
    } catch (e) {
      throw Exception('Failed to insert food item: $e');
    }
  }

  // Update food item
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

  // Delete food item
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

  // Get food items by date
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

  // Get food items by date range
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

  // Get food items by meal type
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

  // Get all food items
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

  // === Health goal related operations ===

  // Insert health goal
  Future<int> insertHealthGoal(HealthGoal goal) async {
    try {
      final db = await database;
      return await db.insert('health_goals', goal.toMap());
    } catch (e) {
      throw Exception('Failed to insert health goal: $e');
    }
  }

  // Update health goal
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

  // Insert or update current health goal (keep only the latest one)
  Future<int> insertOrUpdateCurrentHealthGoal(HealthGoal goal) async {
    try {
      final db = await database;

      // Delete all old goals first
      await db.delete('health_goals');

      // Insert new goal
      return await db.insert('health_goals', goal.toMap());
    } catch (e) {
      throw Exception('Failed to insert/update current health goal: $e');
    }
  }

  // Get current health goal
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

  // Delete health goal
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

  // === Statistics and analysis related operations ===

  // Get daily nutrition summary for specified date
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

  // Get weekly calorie data
  Future<List<Map<String, dynamic>>> getWeeklyCalorieData(
      DateTime startDate, DateTime endDate) async {
    try {
      final db = await database;
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

  // === Database maintenance operations ===

  // Clear database
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

  // Close database connection
  Future<void> closeDatabase() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
    } catch (e) {
      throw Exception('Failed to close database: $e');
    }
  }

  // Check if database exists
  Future<bool> databaseExists() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'calorie_tracker.db');
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  // Get database path (for debugging)
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, 'calorie_tracker.db');
  }

  // Backup database
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

  // Restore database
  Future<void> restoreDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);

      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist');
      }

      // Close current database connection
      await closeDatabase();

      // Copy backup file to database location
      final currentPath = await getDatabasePath();
      await backupFile.copy(currentPath);

      // Reinitialize database
      _database = await _initDB();
    } catch (e) {
      throw Exception('Failed to restore database: $e');
    }
  }

  // Check database integrity
  Future<bool> checkIntegrity() async {
    try {
      final db = await database;
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first.values.first == 'ok';
    } catch (e) {
      return false;
    }
  }

  // Optimize database (clean up fragmentation)
  Future<void> optimizeDatabase() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
      await db.execute('PRAGMA optimize');
    } catch (e) {
      throw Exception('Failed to optimize database: $e');
    }
  }

  // Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final db = await database;

      final userCount = await _getTableRowCount(db, 'users');
      final foodItemCount = await _getTableRowCount(db, 'food_items');
      final healthGoalCount = await _getTableRowCount(db, 'health_goals');

      return {
        'userCount': userCount,
        'foodItemCount': foodItemCount,
        'healthGoalCount': healthGoalCount,
      };
    } catch (e) {
      throw Exception('Failed to get database statistics: $e');
    }
  }

  // Helper method to get table row count
  Future<int> _getTableRowCount(Database db, String tableName) async {
    try {
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Export data to JSON format
  Future<Map<String, dynamic>> exportToJson() async {
    try {
      final db = await database;

      final users = await db.query('users');
      final foodItems = await db.query('food_items');
      final goals = await db.query('health_goals');

      return {
        'exportDate': DateTime.now().toIso8601String(),
        'version': 1,
        'users': users,
        'foodItems': foodItems,
        'healthGoals': goals,
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Import data from JSON format
  Future<void> importFromJson(Map<String, dynamic> jsonData) async {
    try {
      final db = await database;

      await db.transaction((txn) async {
        // Clear existing data
        await clearAllData();

        // Import user data
        final users = jsonData['users'] as List<dynamic>?;
        if (users != null) {
          for (final user in users) {
            await txn.insert('users', user as Map<String, dynamic>);
          }
        }

        // Import food items data
        final foodItems = jsonData['foodItems'] as List<dynamic>?;
        if (foodItems != null) {
          for (final item in foodItems) {
            await txn.insert('food_items', item as Map<String, dynamic>);
          }
        }

        // Import health goals data
        final goals = jsonData['healthGoals'] as List<dynamic>?;
        if (goals != null) {
          for (final goal in goals) {
            await txn.insert('health_goals', goal as Map<String, dynamic>);
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}

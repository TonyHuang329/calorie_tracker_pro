// lib/services/database_helper.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/food_item.dart';
import '../models/user_profile.dart';
import '../models/health_goal.dart';

/// Database helper utility class
/// Provides advanced features like database version management, migration, backup and restore
class DatabaseHelper {
  static const String _databaseName = 'calorie_tracker.db';
  static const int _databaseVersion = 2;

  // Database table names
  static const String tableUsers = 'users';
  static const String tableFoodItems = 'food_items';
  static const String tableHealthGoals = 'health_goals';
  static const String tableFoodTemplates = 'food_templates';
  static const String tableNutritionCache = 'nutrition_cache';

  /// Get database file path
  static Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  /// Get backup database file path
  static Future<String> getBackupPath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return join(documentsDirectory.path, 'backup_${timestamp}_$_databaseName');
  }

  /// Check if database exists
  static Future<bool> databaseExists() async {
    final path = await getDatabasePath();
    return await File(path).exists();
  }

  /// Get database file size
  static Future<int> getDatabaseSize() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Create all database tables
  static Future<void> createTables(Database db) async {
    // Create users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableUsers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        activityLevel TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create food items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableFoodItems(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL NOT NULL DEFAULT 0,
        protein REAL NOT NULL DEFAULT 0,
        carbs REAL NOT NULL DEFAULT 0,
        fat REAL NOT NULL DEFAULT 0,
        mealType TEXT NOT NULL,
        date TEXT NOT NULL,
        quantity REAL DEFAULT 1,
        unit TEXT DEFAULT 'serving',
        notes TEXT,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create health goals table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableHealthGoals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        targetCalories REAL NOT NULL,
        targetProtein REAL NOT NULL,
        targetCarbs REAL NOT NULL,
        targetFat REAL NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        goalType TEXT,
        notes TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');

    // Create food templates table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableFoodTemplates(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL NOT NULL DEFAULT 0,
        protein REAL NOT NULL DEFAULT 0,
        carbs REAL NOT NULL DEFAULT 0,
        fat REAL NOT NULL DEFAULT 0,
        category TEXT,
        brand TEXT,
        servingSize REAL,
        servingUnit TEXT,
        barcode TEXT,
        frequency INTEGER DEFAULT 0,
        lastUsed TEXT,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(name, brand)
      )
    ''');

    // Create nutrition cache table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableNutritionCache(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        totalCalories REAL DEFAULT 0,
        totalProtein REAL DEFAULT 0,
        totalCarbs REAL DEFAULT 0,
        totalFat REAL DEFAULT 0,
        mealBreakfast TEXT,
        mealLunch TEXT,
        mealDinner TEXT,
        mealSnack TEXT,
        lastUpdated TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(date)
      )
    ''');
  }

  /// Create database indexes
  static Future<void> createIndexes(Database db) async {
    // Food items table indexes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_items_date ON $tableFoodItems(date)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_items_meal_type ON $tableFoodItems(mealType)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_items_date_meal ON $tableFoodItems(date, mealType)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_items_name ON $tableFoodItems(name)');

    // Health goals table indexes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_health_goals_active ON $tableHealthGoals(isActive)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_health_goals_created ON $tableHealthGoals(createdAt)');

    // Food templates table indexes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_templates_name ON $tableFoodTemplates(name)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_templates_frequency ON $tableFoodTemplates(frequency DESC)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_food_templates_last_used ON $tableFoodTemplates(lastUsed DESC)');

    // Nutrition cache table indexes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_nutrition_cache_date ON $tableNutritionCache(date)');
  }

  /// Database version upgrade
  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Upgrade from version 1 to version 2
    if (oldVersion < 2) {
      await _upgradeToVersion2(db);
    }

    // Future version upgrade logic can be added here
  }

  /// Upgrade to version 2
  static Future<void> _upgradeToVersion2(Database db) async {
    try {
      // Add new columns to existing tables
      await db.execute(
          'ALTER TABLE $tableUsers ADD COLUMN createdAt TEXT DEFAULT CURRENT_TIMESTAMP');
      await db.execute(
          'ALTER TABLE $tableUsers ADD COLUMN updatedAt TEXT DEFAULT CURRENT_TIMESTAMP');
      await db.execute('ALTER TABLE $tableFoodItems ADD COLUMN notes TEXT');
      await db.execute(
          'ALTER TABLE $tableFoodItems ADD COLUMN createdAt TEXT DEFAULT CURRENT_TIMESTAMP');
      await db.execute(
          'ALTER TABLE $tableFoodItems ADD COLUMN updatedAt TEXT DEFAULT CURRENT_TIMESTAMP');
      await db.execute(
          'ALTER TABLE $tableHealthGoals ADD COLUMN isActive INTEGER DEFAULT 1');

      // Create new tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableFoodTemplates(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          calories REAL NOT NULL DEFAULT 0,
          protein REAL NOT NULL DEFAULT 0,
          carbs REAL NOT NULL DEFAULT 0,
          fat REAL NOT NULL DEFAULT 0,
          category TEXT,
          brand TEXT,
          servingSize REAL,
          servingUnit TEXT,
          barcode TEXT,
          frequency INTEGER DEFAULT 0,
          lastUsed TEXT,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(name, brand)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableNutritionCache(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          totalCalories REAL DEFAULT 0,
          totalProtein REAL DEFAULT 0,
          totalCarbs REAL DEFAULT 0,
          totalFat REAL DEFAULT 0,
          mealBreakfast TEXT,
          mealLunch TEXT,
          mealDinner TEXT,
          mealSnack TEXT,
          lastUpdated TEXT DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(date)
        )
      ''');

      // Create new indexes
      await createIndexes(db);

      print('Database upgrade to version 2 completed');
    } catch (e) {
      print('Database upgrade failed: $e');
      throw Exception('Database upgrade failed: $e');
    }
  }

  /// Backup database
  static Future<String> backupDatabase() async {
    try {
      final currentPath = await getDatabasePath();
      final backupPath = await getBackupPath();

      final currentFile = File(currentPath);
      if (!await currentFile.exists()) {
        throw Exception('Database file does not exist');
      }

      await currentFile.copy(backupPath);
      return backupPath;
    } catch (e) {
      throw Exception('Failed to backup database: $e');
    }
  }

  /// Restore database
  static Future<void> restoreDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist');
      }

      final currentPath = await getDatabasePath();
      await backupFile.copy(currentPath);
    } catch (e) {
      throw Exception('Failed to restore database: $e');
    }
  }

  /// Clear all data (preserve table structure)
  static Future<void> clearAllData(DatabaseExecutor executor) async {
    try {
      await executor.delete(tableFoodItems);
      await executor.delete(tableUsers);
      await executor.delete(tableHealthGoals);
      await executor.delete(tableFoodTemplates);
      await executor.delete(tableNutritionCache);

      // Reset auto-increment IDs
      await executor.delete('sqlite_sequence');
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  /// Delete database file
  static Future<void> deleteDatabase() async {
    try {
      final path = await getDatabasePath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete database: $e');
    }
  }

  /// Check database integrity
  static Future<bool> checkIntegrity(Database db) async {
    try {
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first.values.first == 'ok';
    } catch (e) {
      return false;
    }
  }

  /// Optimize database (clean up fragmentation)
  static Future<void> optimizeDatabase(Database db) async {
    try {
      await db.execute('VACUUM');
      await db.execute('PRAGMA optimize');
    } catch (e) {
      throw Exception('Failed to optimize database: $e');
    }
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats(Database db) async {
    try {
      final userCount = await _getTableRowCount(db, tableUsers);
      final foodItemCount = await _getTableRowCount(db, tableFoodItems);
      final goalCount = await _getTableRowCount(db, tableHealthGoals);
      final templateCount = await _getTableRowCount(db, tableFoodTemplates);
      final cacheCount = await _getTableRowCount(db, tableNutritionCache);

      final dbSize = await getDatabaseSize();

      // Get earliest and latest food record dates
      final dateRange = await _getFoodItemDateRange(db);

      return {
        'databaseSize': dbSize,
        'userCount': userCount,
        'foodItemCount': foodItemCount,
        'goalCount': goalCount,
        'templateCount': templateCount,
        'cacheCount': cacheCount,
        'earliestFoodDate': dateRange['earliest'],
        'latestFoodDate': dateRange['latest'],
        'version': _databaseVersion,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Get table row count
  static Future<int> _getTableRowCount(Database db, String tableName) async {
    try {
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  /// Get food items date range
  static Future<Map<String, String?>> _getFoodItemDateRange(Database db) async {
    try {
      final result = await db.rawQuery('''
        SELECT 
          MIN(date) as earliest,
          MAX(date) as latest
        FROM $tableFoodItems
      ''');

      if (result.isNotEmpty) {
        return {
          'earliest': result.first['earliest'] as String?,
          'latest': result.first['latest'] as String?,
        };
      }

      return {'earliest': null, 'latest': null};
    } catch (e) {
      return {'earliest': null, 'latest': null};
    }
  }

  /// Clean up expired cache
  static Future<void> cleanupCache(Database db,
      {int retentionDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
      final cutoffString = cutoffDate.toIso8601String().substring(0, 10);

      await db.delete(
        tableNutritionCache,
        where: 'date < ?',
        whereArgs: [cutoffString],
      );
    } catch (e) {
      throw Exception('Failed to cleanup cache: $e');
    }
  }

  /// Update food template usage frequency
  static Future<void> updateFoodTemplateFrequency(
      Database db, String foodName) async {
    try {
      await db.execute('''
        UPDATE $tableFoodTemplates 
        SET frequency = frequency + 1, lastUsed = ? 
        WHERE name = ?
      ''', [DateTime.now().toIso8601String(), foodName]);
    } catch (e) {
      // If update fails, it might be because the template doesn't exist, which is normal
    }
  }

  /// Insert or update nutrition cache
  static Future<void> upsertNutritionCache(
    Database db,
    String date,
    Map<String, double> nutritionSummary,
    Map<String, Map<String, double>>? mealSummary,
  ) async {
    try {
      await db.execute('''
        INSERT OR REPLACE INTO $tableNutritionCache(
          date, totalCalories, totalProtein, totalCarbs, totalFat,
          mealBreakfast, mealLunch, mealDinner, mealSnack, lastUpdated
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        date,
        nutritionSummary['totalCalories'] ?? 0.0,
        nutritionSummary['totalProtein'] ?? 0.0,
        nutritionSummary['totalCarbs'] ?? 0.0,
        nutritionSummary['totalFat'] ?? 0.0,
        mealSummary?['breakfast']?.toString(),
        mealSummary?['lunch']?.toString(),
        mealSummary?['dinner']?.toString(),
        mealSummary?['snack']?.toString(),
        DateTime.now().toIso8601String(),
      ]);
    } catch (e) {
      throw Exception('Failed to update nutrition cache: $e');
    }
  }

  /// Get nutrition cache
  static Future<Map<String, double>?> getNutritionCache(
      Database db, String date) async {
    try {
      final result = await db.query(
        tableNutritionCache,
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final row = result.first;
        return {
          'totalCalories': (row['totalCalories'] as num?)?.toDouble() ?? 0.0,
          'totalProtein': (row['totalProtein'] as num?)?.toDouble() ?? 0.0,
          'totalCarbs': (row['totalCarbs'] as num?)?.toDouble() ?? 0.0,
          'totalFat': (row['totalFat'] as num?)?.toDouble() ?? 0.0,
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Export data to JSON format
  static Future<Map<String, dynamic>> exportToJson(Database db) async {
    try {
      final users = await db.query(tableUsers);
      final foodItems = await db.query(tableFoodItems);
      final goals = await db.query(tableHealthGoals);
      final templates = await db.query(tableFoodTemplates);

      return {
        'exportDate': DateTime.now().toIso8601String(),
        'version': _databaseVersion,
        'users': users,
        'foodItems': foodItems,
        'healthGoals': goals,
        'foodTemplates': templates,
      };
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Import data from JSON format
  static Future<void> importFromJson(
      Database db, Map<String, dynamic> jsonData) async {
    try {
      await db.transaction((txn) async {
        // Clear existing data
        await clearAllData(txn);

        // Import user data
        final users = jsonData['users'] as List<dynamic>?;
        if (users != null) {
          for (final user in users) {
            await txn.insert(tableUsers, user as Map<String, dynamic>);
          }
        }

        // Import food items data
        final foodItems = jsonData['foodItems'] as List<dynamic>?;
        if (foodItems != null) {
          for (final item in foodItems) {
            await txn.insert(tableFoodItems, item as Map<String, dynamic>);
          }
        }

        // Import health goals data
        final goals = jsonData['healthGoals'] as List<dynamic>?;
        if (goals != null) {
          for (final goal in goals) {
            await txn.insert(tableHealthGoals, goal as Map<String, dynamic>);
          }
        }

        // Import food templates data
        final templates = jsonData['foodTemplates'] as List<dynamic>?;
        if (templates != null) {
          for (final template in templates) {
            await txn.insert(
                tableFoodTemplates, template as Map<String, dynamic>);
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Get most frequently used food templates
  static Future<List<Map<String, dynamic>>> getFrequentlyUsedFoodTemplates(
      Database db,
      {int limit = 10}) async {
    try {
      final result = await db.query(
        tableFoodTemplates,
        orderBy: 'frequency DESC, lastUsed DESC',
        limit: limit,
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  /// Search food templates by name
  static Future<List<Map<String, dynamic>>> searchFoodTemplates(
      Database db, String searchQuery,
      {int limit = 20}) async {
    try {
      final result = await db.query(
        tableFoodTemplates,
        where: 'name LIKE ?',
        whereArgs: ['%$searchQuery%'],
        orderBy: 'frequency DESC, name ASC',
        limit: limit,
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  /// Get nutrition summary for date range
  static Future<Map<String, dynamic>> getNutritionSummaryForDateRange(
      Database db, DateTime startDate, DateTime endDate) async {
    try {
      final startDateString = startDate.toIso8601String().substring(0, 10);
      final endDateString = endDate.toIso8601String().substring(0, 10);

      final result = await db.rawQuery('''
        SELECT 
          AVG(totalCalories) as avgCalories,
          SUM(totalCalories) as totalCalories,
          AVG(totalProtein) as avgProtein,
          SUM(totalProtein) as totalProtein,
          AVG(totalCarbs) as avgCarbs,
          SUM(totalCarbs) as totalCarbs,
          AVG(totalFat) as avgFat,
          SUM(totalFat) as totalFat,
          COUNT(*) as dayCount
        FROM $tableNutritionCache 
        WHERE date >= ? AND date <= ?
      ''', [startDateString, endDateString]);

      if (result.isNotEmpty && result.first['dayCount'] != 0) {
        final row = result.first;
        return {
          'avgCalories': (row['avgCalories'] as num?)?.toDouble() ?? 0.0,
          'totalCalories': (row['totalCalories'] as num?)?.toDouble() ?? 0.0,
          'avgProtein': (row['avgProtein'] as num?)?.toDouble() ?? 0.0,
          'totalProtein': (row['totalProtein'] as num?)?.toDouble() ?? 0.0,
          'avgCarbs': (row['avgCarbs'] as num?)?.toDouble() ?? 0.0,
          'totalCarbs': (row['totalCarbs'] as num?)?.toDouble() ?? 0.0,
          'avgFat': (row['avgFat'] as num?)?.toDouble() ?? 0.0,
          'totalFat': (row['totalFat'] as num?)?.toDouble() ?? 0.0,
          'dayCount': row['dayCount'] as int,
        };
      }

      return {
        'avgCalories': 0.0,
        'totalCalories': 0.0,
        'avgProtein': 0.0,
        'totalProtein': 0.0,
        'avgCarbs': 0.0,
        'totalCarbs': 0.0,
        'avgFat': 0.0,
        'totalFat': 0.0,
        'dayCount': 0,
      };
    } catch (e) {
      throw Exception('Failed to get nutrition summary for date range: $e');
    }
  }
}

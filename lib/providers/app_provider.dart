// lib/providers/app_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global application state management
/// Handles theme mode, first launch status, navigation state, and app-wide settings
class AppProvider extends ChangeNotifier {
  // Private variables
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstLaunch = true;
  int _selectedBottomNavIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isFirstLaunch => _isFirstLaunch;
  int get selectedBottomNavIndex => _selectedBottomNavIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Constructor - Initialize app state
  AppProvider() {
    _loadAppSettings();
  }

  /// Load app settings from local storage
  Future<void> _loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeIndex];

      // Check if first launch
      _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

      // Load bottom navigation selected index
      _selectedBottomNavIndex = prefs.getInt('selected_nav_index') ?? 0;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load app settings: $e');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      notifyListeners();

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
    } catch (e) {
      _setError('Failed to save theme settings: $e');
    }
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }

  /// Get current theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'Follow System';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  /// Mark app as completed first launch
  Future<void> completeFirstLaunch() async {
    try {
      _isFirstLaunch = false;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_launch', false);
    } catch (e) {
      _setError('Failed to save first launch status: $e');
    }
  }

  /// Check if onboarding should be shown
  Future<bool> shouldShowOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('show_onboarding') ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_onboarding', false);
      _isFirstLaunch = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to save onboarding status: $e');
    }
  }

  /// Set bottom navigation selected index
  Future<void> setBottomNavIndex(int index) async {
    if (index >= 0 && index <= 3) {
      _selectedBottomNavIndex = index;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('selected_nav_index', index);
      } catch (e) {
        _setError('Failed to save navigation state: $e');
      }
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null; // Clear previous errors
    }
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();

    // Log errors in debug mode
    if (kDebugMode) {
      print('AppProvider Error: $error');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset app state (for debugging or user logout)
  Future<void> resetAppState() async {
    try {
      _themeMode = ThemeMode.system;
      _isFirstLaunch = true;
      _selectedBottomNavIndex = 0;
      _isLoading = false;
      _errorMessage = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      _setError('Failed to reset app state: $e');
    }
  }

  /// Get app version information
  Future<Map<String, String>> getAppInfo() async {
    // This can integrate with package_info_plus to get actual app info
    return {
      'appName': 'Calorie Tracker Pro',
      'packageName': 'com.example.calorie_tracker_app_pro',
      'version': '1.0.0',
      'buildNumber': '1',
    };
  }

  /// Check if feature introduction should be shown
  Future<bool> shouldShowFeatureIntroduction(String featureName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'feature_intro_$featureName';
      return prefs.getBool(key) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Mark feature introduction as shown
  Future<void> markFeatureIntroductionShown(String featureName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'feature_intro_$featureName';
      await prefs.setBool(key, false);
    } catch (e) {
      _setError('Failed to save feature introduction status: $e');
    }
  }

  /// Get app usage statistics
  Future<Map<String, dynamic>> getAppUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final installDate =
          prefs.getString('install_date') ?? DateTime.now().toIso8601String();

      final launchCount = prefs.getInt('launch_count') ?? 0;
      final lastLaunchDate = prefs.getString('last_launch_date');

      return {
        'installDate': installDate,
        'launchCount': launchCount,
        'lastLaunchDate': lastLaunchDate,
        'daysUsed': _calculateDaysUsed(installDate),
      };
    } catch (e) {
      return {
        'installDate': DateTime.now().toIso8601String(),
        'launchCount': 0,
        'lastLaunchDate': null,
        'daysUsed': 0,
      };
    }
  }

  /// Record app launch
  Future<void> recordAppLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Set install date (if first time)
      if (!prefs.containsKey('install_date')) {
        await prefs.setString('install_date', DateTime.now().toIso8601String());
      }

      // Increment launch count
      final launchCount = (prefs.getInt('launch_count') ?? 0) + 1;
      await prefs.setInt('launch_count', launchCount);

      // Record last launch date
      await prefs.setString(
          'last_launch_date', DateTime.now().toIso8601String());
    } catch (e) {
      _setError('Failed to record app launch: $e');
    }
  }

  /// Calculate days of app usage
  int _calculateDaysUsed(String installDate) {
    try {
      final install = DateTime.parse(installDate);
      final now = DateTime.now();
      return now.difference(install).inDays + 1;
    } catch (e) {
      return 1;
    }
  }

  /// Handle app shortcuts or deep links
  void handleAppShortcut(String shortcutType) {
    switch (shortcutType) {
      case 'add_food':
        setBottomNavIndex(0); // Navigate to home
        // Additional navigation logic can be added here
        break;
      case 'view_stats':
        setBottomNavIndex(2); // Navigate to history
        break;
      case 'settings':
        setBottomNavIndex(3); // Navigate to settings
        break;
      default:
        setBottomNavIndex(0); // Default to home
    }
  }

  /// Check for app updates (can integrate with app store APIs)
  Future<Map<String, dynamic>> checkForUpdates() async {
    // Implementation for checking app updates
    // Can integrate with app store APIs or custom server

    return {
      'hasUpdate': false,
      'latestVersion': '1.0.0',
      'updateDescription': '',
      'isMandatory': false,
    };
  }

  /// Export app settings
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final settings = <String, dynamic>{};

      for (String key in keys) {
        settings[key] = prefs.get(key);
      }

      return {
        'exportDate': DateTime.now().toIso8601String(),
        'settings': settings,
      };
    } catch (e) {
      _setError('Failed to export settings: $e');
      return {};
    }
  }

  /// Import app settings
  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = settingsData['settings'] as Map<String, dynamic>?;

      if (settings != null) {
        for (String key in settings.keys) {
          final value = settings[key];
          if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is String) {
            await prefs.setString(key, value);
          } else if (value is List<String>) {
            await prefs.setStringList(key, value);
          }
        }

        // Reload settings
        await _loadAppSettings();
      }
    } catch (e) {
      _setError('Failed to import settings: $e');
    }
  }

  /// Get localization preferences
  Future<Map<String, dynamic>> getLocalizationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'language': prefs.getString('language') ?? 'en',
        'country': prefs.getString('country') ?? 'US',
        'dateFormat': prefs.getString('date_format') ?? 'MM/dd/yyyy',
        'timeFormat': prefs.getString('time_format') ?? '12h',
        'measurementSystem':
            prefs.getString('measurement_system') ?? 'imperial',
      };
    } catch (e) {
      return {
        'language': 'en',
        'country': 'US',
        'dateFormat': 'MM/dd/yyyy',
        'timeFormat': '12h',
        'measurementSystem': 'imperial',
      };
    }
  }

  /// Set localization preference
  Future<void> setLocalizationSetting(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      notifyListeners();
    } catch (e) {
      _setError('Failed to save localization setting: $e');
    }
  }

  /// Get notification preferences
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'dailyReminders': prefs.getBool('daily_reminders') ?? true,
        'mealReminders': prefs.getBool('meal_reminders') ?? true,
        'goalAchievements': prefs.getBool('goal_achievements') ?? true,
        'weeklyReports': prefs.getBool('weekly_reports') ?? false,
        'reminderTime': prefs.getString('reminder_time') ?? '09:00',
      };
    } catch (e) {
      return {
        'dailyReminders': true,
        'mealReminders': true,
        'goalAchievements': true,
        'weeklyReports': false,
        'reminderTime': '09:00',
      };
    }
  }

  /// Set notification preference
  Future<void> setNotificationSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to save notification setting: $e');
    }
  }

  /// Get data and privacy settings
  Future<Map<String, dynamic>> getPrivacySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'analyticsEnabled': prefs.getBool('analytics_enabled') ?? false,
        'crashReportingEnabled':
            prefs.getBool('crash_reporting_enabled') ?? true,
        'dataBackupEnabled': prefs.getBool('data_backup_enabled') ?? true,
        'dataRetentionDays': prefs.getInt('data_retention_days') ?? 365,
      };
    } catch (e) {
      return {
        'analyticsEnabled': false,
        'crashReportingEnabled': true,
        'dataBackupEnabled': true,
        'dataRetentionDays': 365,
      };
    }
  }

  /// Set privacy preference
  Future<void> setPrivacySetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to save privacy setting: $e');
    }
  }

  /// Get accessibility settings
  Future<Map<String, dynamic>> getAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'highContrast': prefs.getBool('high_contrast') ?? false,
        'largeText': prefs.getBool('large_text') ?? false,
        'reducedMotion': prefs.getBool('reduced_motion') ?? false,
        'screenReader': prefs.getBool('screen_reader') ?? false,
      };
    } catch (e) {
      return {
        'highContrast': false,
        'largeText': false,
        'reducedMotion': false,
        'screenReader': false,
      };
    }
  }

  /// Set accessibility preference
  Future<void> setAccessibilitySetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      notifyListeners();
    } catch (e) {
      _setError('Failed to save accessibility setting: $e');
    }
  }

  /// Clear all user data (for account deletion or reset)
  Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Keep only essential app settings
      final themeMode = prefs.getInt('theme_mode') ?? 0;
      final language = prefs.getString('language') ?? 'en';

      await prefs.clear();

      // Restore essential settings
      await prefs.setInt('theme_mode', themeMode);
      await prefs.setString('language', language);
      await prefs.setBool('is_first_launch', true);

      // Reset state
      _isFirstLaunch = true;
      _selectedBottomNavIndex = 0;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _setError('Failed to clear user data: $e');
    }
  }

  /// Get app performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'averageStartupTime': prefs.getDouble('avg_startup_time') ?? 0.0,
        'crashCount': prefs.getInt('crash_count') ?? 0,
        'lastCrashDate': prefs.getString('last_crash_date'),
        'memoryUsage': prefs.getDouble('memory_usage') ?? 0.0,
      };
    } catch (e) {
      return {
        'averageStartupTime': 0.0,
        'crashCount': 0,
        'lastCrashDate': null,
        'memoryUsage': 0.0,
      };
    }
  }

  /// Record performance metric
  Future<void> recordPerformanceMetric(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to record performance metric: $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

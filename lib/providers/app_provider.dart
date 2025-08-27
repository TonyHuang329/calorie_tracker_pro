import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用全局状态管理
class AppProvider extends ChangeNotifier {
  // 私有变量
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

  /// 构造函数，初始化应用状态
  AppProvider() {
    _loadAppSettings();
  }

  /// 从本地存储加载应用设置
  Future<void> _loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载主题模式
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeIndex];

      // 检查是否首次启动
      _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

      // 加载底部导航栏选中索引
      _selectedBottomNavIndex = prefs.getInt('selected_nav_index') ?? 0;

      notifyListeners();
    } catch (e) {
      _setError('加载应用设置失败: $e');
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      notifyListeners();

      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
    } catch (e) {
      _setError('保存主题设置失败: $e');
    }
  }

  /// 切换主题模式
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

  /// 获取当前主题模式的显示名称
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  /// 标记应用已完成首次启动
  Future<void> completeFirstLaunch() async {
    try {
      _isFirstLaunch = false;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_launch', false);
    } catch (e) {
      _setError('保存首次启动状态失败: $e');
    }
  }

  /// 设置底部导航栏选中索引
  Future<void> setBottomNavIndex(int index) async {
    if (index >= 0 && index <= 3) {
      _selectedBottomNavIndex = index;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('selected_nav_index', index);
      } catch (e) {
        _setError('保存导航栏状态失败: $e');
      }
    }
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null; // 清除之前的错误信息
    }
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();

    // 可以在这里添加错误日志记录
    if (kDebugMode) {
      print('AppProvider Error: $error');
    }
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 重置应用状态（用于调试或用户注销）
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
      _setError('重置应用状态失败: $e');
    }
  }

  /// 获取应用版本信息
  Future<Map<String, String>> getAppInfo() async {
    // 这里可以集成 package_info_plus 包来获取实际的应用信息
    return {
      'appName': '卡路里追踪专业版',
      'packageName': 'com.example.calorie_tracker_app_pro',
      'version': '1.0.0',
      'buildNumber': '1',
    };
  }

  /// 检查是否需要显示新功能引导
  Future<bool> shouldShowFeatureIntroduction(String featureName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'feature_intro_$featureName';
      return prefs.getBool(key) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// 标记功能引导已显示
  Future<void> markFeatureIntroductionShown(String featureName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'feature_intro_$featureName';
      await prefs.setBool(key, false);
    } catch (e) {
      _setError('保存功能引导状态失败: $e');
    }
  }

  /// 获取应用使用统计
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

  /// 记录应用启动
  Future<void> recordAppLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 设置安装日期（如果是第一次）
      if (!prefs.containsKey('install_date')) {
        await prefs.setString('install_date', DateTime.now().toIso8601String());
      }

      // 增加启动次数
      final launchCount = (prefs.getInt('launch_count') ?? 0) + 1;
      await prefs.setInt('launch_count', launchCount);

      // 记录最后启动日期
      await prefs.setString(
          'last_launch_date', DateTime.now().toIso8601String());
    } catch (e) {
      _setError('记录应用启动失败: $e');
    }
  }

  /// 计算应用使用天数
  int _calculateDaysUsed(String installDate) {
    try {
      final install = DateTime.parse(installDate);
      final now = DateTime.now();
      return now.difference(install).inDays + 1;
    } catch (e) {
      return 1;
    }
  }

  /// 处理深链接或应用快捷方式
  void handleAppShortcut(String shortcutType) {
    switch (shortcutType) {
      case 'add_food':
        setBottomNavIndex(0); // 跳转到主页
        // 这里可以添加额外的导航逻辑
        break;
      case 'view_stats':
        setBottomNavIndex(2); // 跳转到历史页面
        break;
      case 'settings':
        setBottomNavIndex(3); // 跳转到设置页面
        break;
      default:
        setBottomNavIndex(0); // 默认跳转到主页
    }
  }

  /// 检查应用更新（可以与应用商店API集成）
  Future<Map<String, dynamic>> checkForUpdates() async {
    // 这里可以实现检查应用更新的逻辑
    // 例如：与应用商店API或自己的服务器通信

    return {
      'hasUpdate': false,
      'latestVersion': '1.0.0',
      'updateDescription': '',
      'isMandatory': false,
    };
  }

  /// 导出应用设置
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
      _setError('导出设置失败: $e');
      return {};
    }
  }

  /// 导入应用设置
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

        // 重新加载设置
        await _loadAppSettings();
      }
    } catch (e) {
      _setError('导入设置失败: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

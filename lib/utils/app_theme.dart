// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

/// Application theme configuration class
/// Defines color schemes, text styles, and component themes for the entire app
class AppTheme {
  // Application color constants
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(primaryGreen),
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundLight,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        primaryContainer: primaryGreenLight,
        secondary: accentOrange,
        secondaryContainer: Color(0xFFFFE0B2),
        surface: surfaceLight,
        background: backgroundLight,
        error: accentRed,
        onPrimary: textLight,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: textLight,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Input field theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textLight,
          elevation: 2,
          shadowColor: primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: textLight,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // BottomNavigationBar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.normal),
        bodyMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.normal),
        bodySmall:
            TextStyle(color: textSecondary, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        labelMedium:
            TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        labelSmall:
            TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),

      // ListTile theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: primaryGreenLight,
        secondarySelectedColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(primaryGreen),
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundDark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGreenLight,
        primaryContainer: primaryGreen,
        secondary: accentOrange,
        secondaryContainer: Color(0xFFBF360C),
        surface: surfaceDark,
        background: backgroundDark,
        error: accentRed,
        onPrimary: textPrimary,
        onSecondary: textLight,
        onSurface: textLight,
        onBackground: textLight,
        onError: textLight,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        foregroundColor: textLight,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),

      // Input field theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreenLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textLight,
          elevation: 4,
          shadowColor: primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: textLight,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // BottomNavigationBar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryGreenLight,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textLight, fontWeight: FontWeight.w600),
        headlineMedium:
            TextStyle(color: textLight, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textLight, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textLight, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textLight, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textLight, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textLight, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(color: textLight, fontWeight: FontWeight.normal),
        bodySmall:
            TextStyle(color: textSecondary, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(color: textLight, fontWeight: FontWeight.w500),
        labelMedium:
            TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        labelSmall:
            TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: textLight,
        size: 24,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade700,
        thickness: 1,
        space: 1,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ), // RoundedRectangleBorder
        color: surfaceDark,
      ), // CardThemeData

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade800,
        selectedColor: primaryGreen,
        secondarySelectedColor: primaryGreenLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Create Material Color
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  // Custom shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(20), // Updated for newer Flutter
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primaryGreen.withAlpha(76), // 30% opacity
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  // Custom decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: cardShadow,
      );

  static BoxDecoration get darkCardDecoration => BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76), // 30% opacity
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // Common color getters for nutrition components
  static Color getProteinColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFE57373)
          : const Color(0xFFEF5350);

  static Color getCarbsColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF64B5F6)
          : const Color(0xFF42A5F5);

  static Color getFatColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFFFB74D)
          : const Color(0xFFFF9800);

  // Status colors
  static Color get successColor => const Color(0xFF4CAF50);
  static Color get warningColor => const Color(0xFFFF9800);
  static Color get errorColor => const Color(0xFFE53935);
  static Color get infoColor => const Color(0xFF2196F3);

  // BMI status colors
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return infoColor;
    if (bmi < 25) return successColor;
    if (bmi < 30) return warningColor;
    return errorColor;
  }

  // Goal progress colors
  static Color getProgressColor(double progress) {
    if (progress < 50) return errorColor;
    if (progress < 80) return warningColor;
    if (progress <= 100) return successColor;
    return infoColor; // Over 100%
  }

  // Responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      // Tablet or large screen
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else {
      // Phone screen
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Responsive text sizes
  static double getHeadingFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 32;
    } else {
      return 24;
    }
  }

  static double getBodyFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 18;
    } else {
      return 16;
    }
  }

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Border radius values
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Spacing values
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Common UI measurements
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  static const double fabSize = 56.0;
  static const double listItemHeight = 72.0;
  static const double buttonHeight = 48.0;
  static const double inputFieldHeight = 56.0;

  // Meal type colors
  static Color getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFB74D); // Orange
      case 'lunch':
        return const Color(0xFF4FC3F7); // Blue
      case 'dinner':
        return const Color(0xFFAED581); // Green
      case 'snack':
        return const Color(0xFFBA68C8); // Purple
      default:
        return Colors.grey;
    }
  }

  // Activity level colors
  static Color getActivityLevelColor(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return const Color(0xFFE57373); // Light red
      case 'light':
        return const Color(0xFFFFB74D); // Orange
      case 'moderate':
        return const Color(0xFFAED581); // Light green
      case 'active':
        return const Color(0xFF4CAF50); // Green
      case 'very_active':
        return const Color(0xFF2E7D32); // Dark green
      default:
        return Colors.grey;
    }
  }

  // Goal type colors
  static Color getGoalTypeColor(String? goalType) {
    switch (goalType?.toLowerCase()) {
      case 'lose':
        return const Color(0xFFE53935); // Red
      case 'gain':
        return const Color(0xFF1976D2); // Blue
      case 'maintain':
        return const Color(0xFF4CAF50); // Green
      case 'custom':
        return const Color(0xFF9C27B0); // Purple
      default:
        return Colors.grey;
    }
  }

  // Helper method to get contrasting text color
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calculate relative luminance
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Theme-aware color methods
  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textPrimary
        : textLight;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return textSecondary;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? backgroundLight
        : backgroundDark;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? surfaceLight
        : surfaceDark;
  }
}

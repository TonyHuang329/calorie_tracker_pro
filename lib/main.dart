// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'services/database_service.dart';
import 'providers/app_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/user_provider.dart';
import 'providers/ai_provider.dart'; // NEW: AI Provider
import 'screens/home_screen.dart';
import 'screens/profile_settings_screen.dart';
import 'screens/health_goals_screen.dart';
import 'screens/history_screen.dart';
import 'screens/add_food_screen.dart';
import 'screens/ai_camera_screen.dart'; // NEW: AI Camera Screen
import 'screens/food_search_screen.dart'; // NEW: Food Search Screen
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService().database;

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()), // NEW: AI Provider
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Calorie Tracker Pro',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/profile': (context) => const ProfileSettingsScreen(),
              '/goals': (context) => const HealthGoalsScreen(),
              '/history': (context) => const HistoryScreen(),
              '/add-food': (context) => const AddFoodScreen(),
              '/ai-camera': (context) =>
                  const AICameraScreen(), // NEW: AI Camera route
              '/food-search': (context) =>
                  const FoodSearchScreen(), // NEW: Food Search route
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();

    // Initialize services and check user status
    if (!mounted) return;

    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Load user profile
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserProfile();

      // Initialize AI service in background (non-blocking)
      final aiProvider = Provider.of<AIProvider>(context, listen: false);
      aiProvider.initializeAI(); // Don't await - runs in background

      if (!mounted) return;

      // Navigate based on user profile status
      if (userProvider.userProfile == null) {
        // New user, navigate to profile setup
        Navigator.of(context).pushReplacementNamed('/profile');
      } else {
        // Existing user, load today's nutrition and navigate to home
        final nutritionProvider =
            Provider.of<NutritionProvider>(context, listen: false);
        await nutritionProvider.loadTodayNutrition();

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      // Handle initialization errors
      if (mounted) {
        _showErrorAndNavigate('Failed to initialize app: $e');
      }
    }
  }

  void _showErrorAndNavigate(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to home anyway after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon with rotation animation
                        RotationTransition(
                          turns: _rotationAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 60,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App Title
                        Text(
                          'Calorie Tracker Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle with AI emphasis
                        Text(
                          'AI-Powered Nutrition Tracking',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Feature highlights
                        Text(
                          'Smart • Simple • Accurate',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.0,
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Loading animation
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                            strokeWidth: 3,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Loading text
                        Text(
                          'Initializing AI models...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),

                        const SizedBox(height: 100),

                        // Version info
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

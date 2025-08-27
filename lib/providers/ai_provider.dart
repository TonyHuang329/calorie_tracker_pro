// lib/providers/ai_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/ai_food_recognition_service.dart';
import '../models/food_item.dart';

/// AI Provider for managing AI food recognition state
/// Handles model initialization, recognition requests, and results
class AIProvider extends ChangeNotifier {
  final AIFoodRecognitionService _aiService = AIFoodRecognitionService.instance;

  // State variables
  bool _isModelLoaded = false;
  bool _isLoading = false;
  bool _isRecognizing = false;
  String? _errorMessage;

  File? _currentImage;
  List<RecognitionResult> _recognitionResults = [];
  Map<String, Map<String, double>> _nutritionCache = {};

  // Getters
  bool get isModelLoaded => _isModelLoaded;
  bool get isLoading => _isLoading;
  bool get isRecognizing => _isRecognizing;
  String? get errorMessage => _errorMessage;
  File? get currentImage => _currentImage;
  List<RecognitionResult> get recognitionResults => _recognitionResults;
  bool get hasResults => _recognitionResults.isNotEmpty;

  /// Initialize AI service
  Future<bool> initializeAI() async {
    if (_isModelLoaded) return true;

    _setLoading(true);
    _clearError();

    try {
      debugPrint('🤖 AIProvider: Initializing AI service...');

      final success = await _aiService.initialize();
      _isModelLoaded = success;

      if (success) {
        debugPrint('✅ AIProvider: AI service initialized successfully');
      } else {
        _setError('Failed to initialize AI service');
      }

      return success;
    } catch (e) {
      debugPrint('❌ AIProvider: Initialization failed: $e');
      _setError('AI initialization error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Recognize food from image file
  Future<List<RecognitionResult>> recognizeFood(File imageFile,
      {int topK = 5}) async {
    if (!_isModelLoaded) {
      throw Exception('AI model not loaded. Call initializeAI() first.');
    }

    _setRecognizing(true);
    _clearError();
    _currentImage = imageFile;

    try {
      debugPrint('🍎 AIProvider: Starting food recognition...');

      final results = await _aiService.recognizeFood(imageFile, topK: topK);

      _recognitionResults = results;

      // Cache nutrition data for recognized foods
      for (final result in results) {
        if (!_nutritionCache.containsKey(result.label)) {
          _nutritionCache[result.label] =
              _aiService.getEstimatedNutrition(result.label);
        }
      }

      debugPrint(
          '✅ AIProvider: Recognition completed with ${results.length} results');
      return results;
    } catch (e) {
      debugPrint('❌ AIProvider: Recognition failed: $e');
      _setError('Food recognition failed: $e');
      _recognitionResults.clear();
      rethrow;
    } finally {
      _setRecognizing(false);
    }
  }

  /// Get nutrition data for a food item
  Map<String, double> getNutritionData(String foodLabel) {
    if (_nutritionCache.containsKey(foodLabel)) {
      return _nutritionCache[foodLabel]!;
    }

    final nutrition = _aiService.getEstimatedNutrition(foodLabel);
    _nutritionCache[foodLabel] = nutrition;
    return nutrition;
  }

  /// Create FoodItem from recognition result
  FoodItem createFoodItemFromResult(
    RecognitionResult result, {
    String? customName,
    String? mealType,
    DateTime? date,
    double? quantity,
    String? unit,
  }) {
    final nutrition = getNutritionData(result.label);

    return FoodItem(
      name: customName ?? _formatFoodName(result.label),
      calories: nutrition['calories'] ?? 100.0,
      protein: nutrition['protein'] ?? 5.0,
      carbs: nutrition['carbs'] ?? 15.0,
      fat: nutrition['fat'] ?? 3.0,
      mealType: mealType ?? _getCurrentMealType(),
      date: date ?? DateTime.now(),
      quantity: quantity,
      unit: unit,
    );
  }

  /// Get current meal type based on time
  String _getCurrentMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Breakfast';
    if (hour < 15) return 'Lunch';
    if (hour < 20) return 'Dinner';
    return 'Snack';
  }

  /// Format food name for display
  String _formatFoodName(String label) {
    return label
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Clear current recognition session
  void clearSession() {
    _currentImage = null;
    _recognitionResults.clear();
    _clearError();
    notifyListeners();
  }

  /// Retry last recognition
  Future<List<RecognitionResult>> retryRecognition() async {
    if (_currentImage == null) {
      throw Exception('No image to retry recognition');
    }
    return recognizeFood(_currentImage!);
  }

  /// Get recognition confidence level description
  String getConfidenceDescription(double confidence) {
    if (confidence >= 0.8) return 'High confidence';
    if (confidence >= 0.6) return 'Medium confidence';
    if (confidence >= 0.4) return 'Low confidence';
    return 'Very low confidence';
  }

  /// Get confidence color for UI
  Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    if (confidence >= 0.4) return Colors.deepOrange;
    return Colors.red;
  }

  /// Get statistics about recognition results
  Map<String, dynamic> getRecognitionStats() {
    if (_recognitionResults.isEmpty) {
      return {
        'totalResults': 0,
        'averageConfidence': 0.0,
        'highConfidenceCount': 0,
      };
    }

    final totalResults = _recognitionResults.length;
    final averageConfidence = _recognitionResults.fold<double>(
            0.0, (sum, result) => sum + result.confidence) /
        totalResults;

    final highConfidenceCount =
        _recognitionResults.where((result) => result.confidence >= 0.8).length;

    return {
      'totalResults': totalResults,
      'averageConfidence': averageConfidence,
      'highConfidenceCount': highConfidenceCount,
    };
  }

  /// Export recognition session data
  Map<String, dynamic> exportSessionData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'hasImage': _currentImage != null,
      'imagePath': _currentImage?.path,
      'resultsCount': _recognitionResults.length,
      'results': _recognitionResults
          .map((r) => {
                'label': r.label,
                'confidence': r.confidence,
                'index': r.index,
                'nutrition': getNutritionData(r.label),
              })
          .toList(),
      'stats': getRecognitionStats(),
    };
  }

  /// Dispose resources
  void disposeAI() {
    _aiService.dispose();
    _isModelLoaded = false;
    clearSession();
    _nutritionCache.clear();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setRecognizing(bool recognizing) {
    _isRecognizing = recognizing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disposeAI();
    super.dispose();
  }
}

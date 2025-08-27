// lib/services/ai_food_recognition_service.dart

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Recognition result model
class RecognitionResult {
  final String label;
  final double confidence;
  final int index;

  const RecognitionResult({
    required this.label,
    required this.confidence,
    required this.index,
  });

  @override
  String toString() =>
      'RecognitionResult(label: $label, confidence: ${confidence.toStringAsFixed(3)})';
}

/// AI Food Recognition Service
/// Handles TensorFlow Lite model loading, image preprocessing, and food recognition
class AIFoodRecognitionService {
  static AIFoodRecognitionService? _instance;
  static AIFoodRecognitionService get instance =>
      _instance ??= AIFoodRecognitionService._();

  AIFoodRecognitionService._();

  // Model configuration - MUST match training script exactly
  static const String _modelPath =
      'assets/models/food_recognition_efficientnet_b0.tflite';
  static const String _labelsPath = 'assets/labels/food_labels.txt';
  static const int _inputSize = 224; // EfficientNet-B0 input size
  static const int _outputSize = 101; // Food-101 classes - MUST match training
  static const double _threshold = 0.01; // Lower threshold for better results

  // TensorFlow Lite interpreter
  Interpreter? _interpreter;
  List<String>? _labels;

  // Model status
  bool _isModelLoaded = false;
  bool _isLoading = false;

  /// Get model loading status
  bool get isModelLoaded => _isModelLoaded;
  bool get isLoading => _isLoading;

  /// Initialize the AI service
  /// Load TensorFlow Lite model and labels
  Future<bool> initialize() async {
    if (_isModelLoaded) return true;
    if (_isLoading) return false;

    _isLoading = true;

    try {
      debugPrint('🤖 Initializing AI Food Recognition Service...');

      // Load model
      await _loadModel();

      // Load labels
      await _loadLabels();

      _isModelLoaded = true;
      debugPrint('✅ AI Service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to initialize AI Service: $e');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Load TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      // Check if model file exists
      final modelData = await rootBundle.load(_modelPath);

      // Create interpreter options
      final options = InterpreterOptions();

      // Enable GPU acceleration if available (optional)
      // options.addDelegate(GpuDelegate());

      // Create interpreter from asset
      _interpreter = Interpreter.fromBuffer(modelData.buffer.asUint8List(),
          options: options);

      debugPrint(
          '📱 Model loaded: ${_interpreter?.getInputTensors().length} inputs, ${_interpreter?.getOutputTensors().length} outputs');

      // Verify input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      debugPrint('🔍 Input shape: $inputShape');
      debugPrint('🔍 Output shape: $outputShape');
    } catch (e) {
      debugPrint('❌ Error loading model: $e');
      rethrow;
    }
  }

  /// Load food labels from text file
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      debugPrint('🏷️ Loaded ${_labels?.length} food labels');
    } catch (e) {
      debugPrint('❌ Error loading labels: $e');
      // Fallback to default labels if file not found
      _labels = _getDefaultFoodLabels();
    }
  }

  /// Recognize food from image file
  /// Returns list of recognition results sorted by confidence
  Future<List<RecognitionResult>> recognizeFood(File imageFile,
      {int topK = 5}) async {
    if (!_isModelLoaded) {
      throw Exception('AI model not loaded. Call initialize() first.');
    }

    if (_interpreter == null || _labels == null) {
      throw Exception('Model or labels not available');
    }

    try {
      debugPrint('🍎 Starting food recognition...');

      // Load and decode image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Preprocess image
      final preprocessedImage = _preprocessImage(image);

      // Prepare input/output tensors
      final input = [preprocessedImage];
      final output = [List.filled(_outputSize, 0.0)];

      // Run inference
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(input, output);
      stopwatch.stop();

      debugPrint('⚡ Inference completed in ${stopwatch.elapsedMilliseconds}ms');

      // Process results
      final results = _processResults(output[0], topK);

      debugPrint('🎯 Top predictions:');
      for (int i = 0; i < min(3, results.length); i++) {
        debugPrint(
            '   ${i + 1}. ${results[i].label}: ${(results[i].confidence * 100).toStringAsFixed(1)}%');
      }

      return results;
    } catch (e) {
      debugPrint('❌ Recognition failed: $e');
      rethrow;
    }
  }

  /// Preprocess image for model input
  /// Resize to model input size and normalize pixel values to [0, 1]
  /// MUST match the training preprocessing exactly
  List<List<List<double>>> _preprocessImage(img.Image image) {
    // Resize image to model input size
    final resized =
        img.copyResize(image, width: _inputSize, height: _inputSize);

    // Convert to RGB and normalize to [0, 1] - MATCHING training preprocessing
    final input = List.generate(_inputSize,
        (y) => List.generate(_inputSize, (x) => List.filled(3, 0.0)));

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);

        // CRITICAL: Use [0, 1] normalization to match training (rescale=1./255)
        input[y][x][0] = pixel.r / 255.0; // Red
        input[y][x][1] = pixel.g / 255.0; // Green
        input[y][x][2] = pixel.b / 255.0; // Blue
      }
    }

    return input;
  }

  /// Process model output to recognition results
  List<RecognitionResult> _processResults(List<double> outputs, int topK) {
    final results = <RecognitionResult>[];

    for (int i = 0; i < outputs.length && i < _labels!.length; i++) {
      if (outputs[i] > _threshold) {
        results.add(RecognitionResult(
          label: _labels![i],
          confidence: outputs[i],
          index: i,
        ));
      }
    }

    // Sort by confidence (descending)
    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Return top-K results
    return results.take(topK).toList();
  }

  /// Get estimated nutritional values for recognized food
  /// This is a simplified implementation - in production, you'd use a food database
  Map<String, double> getEstimatedNutrition(String foodName) {
    // Simplified nutrition mapping - replace with actual food database
    final nutritionData = _getDefaultNutritionData();

    // Try exact match first
    if (nutritionData.containsKey(foodName.toLowerCase())) {
      return nutritionData[foodName.toLowerCase()]!;
    }

    // Try partial match
    for (final key in nutritionData.keys) {
      if (foodName.toLowerCase().contains(key) ||
          key.contains(foodName.toLowerCase())) {
        return nutritionData[key]!;
      }
    }

    // Default values if not found
    return {
      'calories': 100.0,
      'protein': 5.0,
      'carbs': 15.0,
      'fat': 3.0,
    };
  }

  /// Default food labels (fallback)
  List<String> _getDefaultFoodLabels() {
    return [
      'apple_pie',
      'baby_back_ribs',
      'baklava',
      'beef_carpaccio',
      'beef_tartare',
      'beet_salad',
      'beignets',
      'bibimbap',
      'bread_pudding',
      'breakfast_burrito',
      'bruschetta',
      'caesar_salad',
      'cannoli',
      'caprese_salad',
      'carrot_cake',
      'ceviche',
      'cheese_plate',
      'cheesecake',
      'chicken_curry',
      'chicken_quesadilla',
      'chicken_wings',
      'chocolate_cake',
      'chocolate_mousse',
      'churros',
      'clam_chowder',
      'club_sandwich',
      'crab_cakes',
      'creme_brulee',
      'croque_madame',
      'cup_cakes',
      'deviled_eggs',
      'donuts',
      'dumplings',
      'eggs_benedict',
      'escargots',
      'falafel',
      'filet_mignon',
      'fish_and_chips',
      'foie_gras',
      'french_fries',
      'french_onion_soup',
      'french_toast',
      'fried_calamari',
      'fried_rice',
      'frozen_yogurt',
      'garlic_bread',
      'gnocchi',
      'greek_salad',
      'grilled_cheese_sandwich',
      'grilled_salmon',
      'guacamole',
      'gyoza',
      'hamburger',
      'hot_and_sour_soup',
      'hot_dog',
      'huevos_rancheros',
      'hummus',
      'ice_cream',
      'lasagna',
      'lobster_bisque',
      'lobster_roll_sandwich',
      'macaroni_and_cheese',
      'macarons',
      'miso_soup',
      'mussels',
      'nachos',
      'omelette',
      'onion_rings',
      'oysters',
      'pad_thai',
      'paella',
      'pancakes',
      'panna_cotta',
      'peking_duck',
      'pho',
      'pizza',
      'pork_chop',
      'poutine',
      'prime_rib',
      'pulled_pork_sandwich',
      'ramen',
      'ravioli',
      'red_velvet_cake',
      'risotto',
      'samosa',
      'sashimi',
      'scallops',
      'seaweed_salad',
      'shrimp_and_grits',
      'spaghetti_bolognese',
      'spaghetti_carbonara',
      'spring_rolls',
      'steak',
      'strawberry_shortcake',
      'sushi',
      'tacos',
      'takoyaki',
      'tiramisu',
      'tuna_tartare',
      'waffles'
    ];
  }

  /// Default nutrition data (simplified)
  Map<String, Map<String, double>> _getDefaultNutritionData() {
    return {
      'apple_pie': {
        'calories': 237.0,
        'protein': 2.4,
        'carbs': 34.0,
        'fat': 11.0
      },
      'baby_back_ribs': {
        'calories': 315.0,
        'protein': 25.0,
        'carbs': 5.0,
        'fat': 22.0
      },
      'baklava': {
        'calories': 330.0,
        'protein': 5.0,
        'carbs': 29.0,
        'fat': 23.0
      },
      'beef_carpaccio': {
        'calories': 158.0,
        'protein': 22.0,
        'carbs': 2.0,
        'fat': 7.0
      },
      'beef_tartare': {
        'calories': 201.0,
        'protein': 20.0,
        'carbs': 3.0,
        'fat': 12.0
      },
      'pizza': {'calories': 266.0, 'protein': 11.0, 'carbs': 33.0, 'fat': 10.0},
      'hamburger': {
        'calories': 295.0,
        'protein': 17.0,
        'carbs': 24.0,
        'fat': 15.0
      },
      'sushi': {'calories': 156.0, 'protein': 7.0, 'carbs': 20.0, 'fat': 5.5},
      'pasta': {'calories': 131.0, 'protein': 5.0, 'carbs': 25.0, 'fat': 1.1},
      'salad': {'calories': 20.0, 'protein': 1.5, 'carbs': 4.0, 'fat': 0.2},
      'chicken': {
        'calories': 239.0,
        'protein': 27.0,
        'carbs': 0.0,
        'fat': 14.0
      },
      'steak': {'calories': 250.0, 'protein': 26.0, 'carbs': 0.0, 'fat': 15.0},
      'fish': {'calories': 206.0, 'protein': 22.0, 'carbs': 0.0, 'fat': 12.0},
    };
  }

  /// Clean up resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    _isModelLoaded = false;
    debugPrint('🧹 AI Service disposed');
  }
}

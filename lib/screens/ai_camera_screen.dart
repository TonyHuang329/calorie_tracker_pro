// lib/screens/ai_camera_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_food_recognition_service.dart';
import '../models/food_item.dart';
import 'add_food_screen.dart';

class AICameraScreen extends StatefulWidget {
  const AICameraScreen({super.key});

  @override
  State<AICameraScreen> createState() => _AICameraScreenState();
}

class _AICameraScreenState extends State<AICameraScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final AIFoodRecognitionService _aiService = AIFoodRecognitionService.instance;

  File? _selectedImage;
  List<RecognitionResult> _recognitionResults = [];
  bool _isProcessing = false;
  bool _hasResults = false;

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAIService();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOut),
    );
  }

  void _initializeAIService() async {
    if (!_aiService.isModelLoaded) {
      setState(() => _isProcessing = true);
      try {
        await _aiService.initialize();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🤖 AI model ready for food recognition'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to load AI model: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _recognitionResults.clear();
          _hasResults = false;
        });

        _fadeAnimationController.forward();
        await _recognizeFood();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _recognizeFood() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _recognitionResults.clear();
    });

    try {
      final results = await _aiService.recognizeFood(_selectedImage!, topK: 5);

      setState(() {
        _recognitionResults = results;
        _hasResults = results.isNotEmpty;
        _isProcessing = false;
      });

      if (_hasResults) {
        _slideAnimationController.forward();
      } else {
        _showErrorSnackBar('No food recognized in this image');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorSnackBar('Recognition failed: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _recognizeFood(),
        ),
      ),
    );
  }

  void _onFoodSelected(RecognitionResult result) {
    final nutrition = _aiService.getEstimatedNutrition(result.label);

    // Navigate to AddFoodScreen with pre-filled data using arguments
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddFoodScreen(),
        settings: RouteSettings(
          arguments: {
            'foodItem': FoodItem(
              name: _formatFoodName(result.label),
              calories: nutrition['calories'] ?? 100.0,
              protein: nutrition['protein'] ?? 5.0,
              carbs: nutrition['carbs'] ?? 15.0,
              fat: nutrition['fat'] ?? 3.0,
              mealType: _getCurrentMealType(),
              date: DateTime.now(),
            ),
            'isEdit': false,
          },
        ),
      ),
    );
  }

  String _formatFoodName(String label) {
    return label
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getCurrentMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Breakfast';
    if (hour < 15) return 'Lunch';
    if (hour < 20) return 'Dinner';
    return 'Snack';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food Recognition'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          if (_selectedImage != null)
            IconButton(
              onPressed: _clearResults,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
            ),
        ],
      ),
      body: Column(
        children: [
          // Image selection area
          Expanded(
            flex: _selectedImage != null ? 2 : 3,
            child: _buildImageSection(),
          ),

          // Results area
          if (_hasResults || _isProcessing)
            Expanded(
              flex: 2,
              child: _buildResultsSection(),
            ),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (_selectedImage == null) {
      return _buildImagePlaceholder();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
              if (_isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          '🤖 AI is analyzing your food...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Take a photo or select from gallery',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI will identify the food and suggest nutritional values',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing image...'),
          ],
        ),
      );
    }

    if (_recognitionResults.isEmpty) {
      return const Center(
        child: Text('No results yet'),
      );
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '🎯 Recognition Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recognitionResults.length,
              itemBuilder: (context, index) {
                final result = _recognitionResults[index];
                return _buildResultTile(result, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(RecognitionResult result, int index) {
    final nutrition = _aiService.getEstimatedNutrition(result.label);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getConfidenceColor(result.confidence),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          _formatFoodName(result.label),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 4),
            Text(
              '${nutrition['calories']?.toInt()}kcal • '
              'P:${nutrition['protein']?.toStringAsFixed(1)}g • '
              'C:${nutrition['carbs']?.toStringAsFixed(1)}g • '
              'F:${nutrition['fat']?.toStringAsFixed(1)}g',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _onFoodSelected(result),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }

  void _clearResults() {
    setState(() {
      _selectedImage = null;
      _recognitionResults.clear();
      _hasResults = false;
      _isProcessing = false;
    });

    _fadeAnimationController.reset();
    _slideAnimationController.reset();
  }
}

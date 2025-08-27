// lib/widgets/ai_quick_access_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_provider.dart';
import '../screens/ai_camera_screen.dart';

/// AI Quick Access Widget for Home Screen
/// Provides easy access to AI food recognition features
class AIQuickAccessWidget extends StatelessWidget {
  const AIQuickAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.smart_toy_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Food Recognition',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getStatusText(aiProvider),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status indicator
                      _buildStatusIndicator(aiProvider),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Instantly identify food and get nutrition data by taking a photo or selecting from gallery.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Take Photo',
                          Icons.camera_alt,
                          () => _handleCameraAction(context),
                          enabled: aiProvider.isModelLoaded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Open Gallery',
                          Icons.photo_library,
                          () => _handleGalleryAction(context),
                          enabled: aiProvider.isModelLoaded,
                        ),
                      ),
                    ],
                  ),

                  // Recent results preview (if available)
                  if (aiProvider.hasResults) ...[
                    const SizedBox(height: 16),
                    _buildRecentResults(context, aiProvider),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(AIProvider aiProvider) {
    Color color;
    IconData icon;

    if (aiProvider.isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (aiProvider.isModelLoaded) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (aiProvider.errorMessage != null) {
      color = Colors.red;
      icon = Icons.error;
    } else {
      color = Colors.orange;
      icon = Icons.warning;
    }

    return Icon(
      icon,
      color: color,
      size: 20,
    );
  }

  String _getStatusText(AIProvider aiProvider) {
    if (aiProvider.isLoading) {
      return 'Loading AI model...';
    } else if (aiProvider.isModelLoaded) {
      return 'Ready for recognition';
    } else if (aiProvider.errorMessage != null) {
      return 'Error loading model';
    } else {
      return 'Model not initialized';
    }
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildRecentResults(BuildContext context, AIProvider aiProvider) {
    final topResult = aiProvider.recognitionResults.first;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Last recognized: ${_formatFoodName(topResult.label)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            '${(topResult.confidence * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  void _handleCameraAction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AICameraScreen(),
        settings: const RouteSettings(arguments: {'source': 'camera'}),
      ),
    );
  }

  void _handleGalleryAction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AICameraScreen(),
        settings: const RouteSettings(arguments: {'source': 'gallery'}),
      ),
    );
  }
}

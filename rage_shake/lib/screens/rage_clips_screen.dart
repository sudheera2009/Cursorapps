import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../services/screenshot_service.dart';
import '../widgets/glass_card.dart';

class RageClipsScreen extends StatefulWidget {
  const RageClipsScreen({super.key});

  @override
  State<RageClipsScreen> createState() => _RageClipsScreenState();
}

class _RageClipsScreenState extends State<RageClipsScreen> {
  final ScreenshotService _screenshotService = ScreenshotService();
  List<File> _clips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClips();
  }

  Future<void> _loadClips() async {
    setState(() => _isLoading = true);
    final clips = await _screenshotService.getSavedClips();
    setState(() {
      _clips = clips;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A2A), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : _clips.isEmpty
                        ? _buildEmptyState()
                        : _buildClipsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'RAGE CLIPS',
            style: AppTheme.titleStyle.copyWith(letterSpacing: 2),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.photo_library, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.grey,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Rage Clips Yet',
            style: AppTheme.subtitleStyle.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture your epic moments\nfrom the results screen!',
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildClipsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _clips.length,
      itemBuilder: (context, index) {
        return _buildClipCard(_clips[index], index);
      },
    );
  }

  Widget _buildClipCard(File file, int index) {
    final fileName = file.path.split('/').last;
    final timestamp = _extractTimestamp(fileName);

    return GestureDetector(
      onTap: () => _showClipDialog(file),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.cardBackground,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 32),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Text(
                  _formatDate(timestamp),
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  DateTime _extractTimestamp(String fileName) {
    try {
      final match = RegExp(r'_(\d+)\.png').firstMatch(fileName);
      if (match != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(match.group(1)!));
      }
    } catch (_) {}
    return DateTime.now();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showClipDialog(File file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(file, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.share,
                    color: Colors.blue,
                    onTap: () async {
                      Navigator.pop(context);
                      final bytes = await file.readAsBytes();
                      await _screenshotService.shareScreenshot(bytes);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.delete,
                    color: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await _screenshotService.deleteClip(file);
                      if (success) {
                        _loadClips();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Clip deleted'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.grey,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

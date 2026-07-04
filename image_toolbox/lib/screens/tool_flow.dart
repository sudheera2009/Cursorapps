import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/enums.dart';
import '../models/image_job.dart';
import '../models/process_result.dart';
import '../models/recipe.dart';
import '../models/tool.dart';
import '../providers/jobs_provider.dart';
import '../providers/settings_provider.dart';
import '../services/gallery_service.dart';
import '../services/picker_service.dart';
import 'configure_screen.dart';
import 'processing_screen.dart';
import 'result_screen.dart';

/// Entry point when a tool is tapped: pick images then route to the tool.
Future<void> openTool(BuildContext context, Tool tool) async {
  final jobs = await _pickImages(context);
  if (jobs == null || jobs.isEmpty || !context.mounted) return;

  context.read<JobsProvider>().setSelection(jobs);

  if (tool.id == ToolId.cropRotate) {
    await _runCrop(context, jobs.first);
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConfigureScreen(tool: tool)),
    );
  }
}

/// Picks images then runs a saved [recipe] straight through the pipeline.
Future<void> applyRecipe(BuildContext context, Recipe recipe) async {
  final jobs = await _pickImages(context);
  if (jobs == null || jobs.isEmpty || !context.mounted) return;

  context.read<JobsProvider>().setSelection(jobs);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          ProcessingScreen(ops: recipe.ops, encode: recipe.encode),
    ),
  );
}

/// Prompts for a source, handles permissions, and returns picked images.
/// Returns null when the user cancels.
Future<List<ImageJob>?> _pickImages(BuildContext context) async {
  final source = await _askSource(context);
  if (source == null || !context.mounted) return null;

  if (source == _Source.camera) {
    if (!await _ensureCamera(context)) return null;
    if (!context.mounted) return null;
  }

  final picker = PickerService();
  return source == _Source.camera
      ? picker.pickFromCamera()
      : picker.pickFromGallery();
}

/// Ensures camera permission, guiding the user to Settings if permanently
/// denied. Returns true when granted.
Future<bool> _ensureCamera(BuildContext context) async {
  var status = await Permission.camera.status;
  if (status.isGranted) return true;
  if (status.isDenied || status.isRestricted) {
    status = await Permission.camera.request();
  }
  if (status.isGranted) return true;

  if (!context.mounted) return false;
  if (status.isPermanentlyDenied) {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Camera access needed', style: AppTheme.title),
        content: Text(
          'Enable camera access in Settings to take a photo to edit.',
          style: AppTheme.body,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not now')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open Settings')),
        ],
      ),
    );
    if (open == true) await openAppSettings();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied')));
  }
  return false;
}

Future<void> _runCrop(BuildContext context, ImageJob job) async {
  try {
    final path = await GalleryService().writeTemp(job.sourceBytes, job.sourcePath);
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop & Rotate',
          toolbarColor: AppColors.surface,
          toolbarWidgetColor: AppColors.textPrimary,
          backgroundColor: AppColors.background,
          activeControlsWidgetColor: AppColors.primary,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop & Rotate'),
      ],
    );
    if (cropped == null || !context.mounted) return;

    final bytes = await cropped.readAsBytes();
    final decoded = await ui.instantiateImageCodec(bytes);
    final frame = await decoded.getNextFrame();
    final result = ProcessResult(
      bytes: bytes,
      suggestedName: '${job.sourcePath.split('.').first}_cropped.jpg',
      originalBytes: job.originalBytes,
      width: frame.image.width,
      height: frame.image.height,
      format: OutputFormat.jpeg,
    );
    job.result = result;
    job.status = JobStatus.done;

    if (!context.mounted) return;
    context.read<SettingsProvider>().recordProcessed(savedBytes: result.savedBytes);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(job: job)),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Crop failed: $e')));
    }
  }
}

enum _Source { gallery, camera }

Future<_Source?> _askSource(BuildContext context) {
  return showModalBottomSheet<_Source>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.photo_library, color: AppColors.primary),
            title: Text('Choose from gallery', style: AppTheme.subtitle),
            subtitle: Text('Select one or many images', style: AppTheme.body),
            onTap: () => Navigator.pop(ctx, _Source.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera, color: AppColors.secondary),
            title: Text('Take a photo', style: AppTheme.subtitle),
            onTap: () => Navigator.pop(ctx, _Source.camera),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Real image picker that opens the device gallery.
/// Returns a [File] path (for local images) or null if cancelled.
class AppImagePicker {
  static final ImagePicker _picker = ImagePicker();

  // ── Main entry point – shows a bottom-sheet (Galeri / Kamera) ──────────────
  static Future<String?> pickImage(BuildContext context) async {
    // Step 1: Let user pick SOURCE (gallery or camera). Sheet returns ImageSource.
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _SourceSheet(),
    );

    if (source == null) return null;       // user cancelled
    if (!context.mounted) return null;

    // Step 2: Sheet is fully closed → now open the actual picker
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );
      return file?.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka ${source == ImageSource.gallery ? "galeri" : "kamera"}: $e')),
        );
      }
      return null;
    }
  }

  // ── Direct gallery pick (no bottom-sheet) ──────────────────────────────────
  static Future<String?> fromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
    );
    return file?.path;
  }

  // ── Direct camera pick (no bottom-sheet) ──────────────────────────────────
  static Future<String?> fromCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1080,
    );
    return file?.path;
  }
}

// ── Bottom-sheet widget – only returns ImageSource choice ─────────────────────
class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFFD0D0D0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text(
            'Pilih Sumber Foto',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: Color(0xFF1E1E1E)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeri',
                  color: const Color(0xFF001AFF),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Kamera',
                  color: const Color(0xFF00C853),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Center(
              child: Text('Batal', style: TextStyle(fontSize: 13.5, color: Color(0xFF8E8E93), fontFamily: 'Inter')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: color, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}

// ── Helper: render an image from local path or network URL ───────────────────
class AppImageWidget extends StatelessWidget {
  final String? imagePath;   // local file path  (from image_picker)
  final String? imageUrl;    // network URL      (fallback / persisted)
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final BorderRadius? borderRadius;

  const AppImageWidget({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (imagePath != null && imagePath!.isNotEmpty) {
      // Local file from gallery/camera
      child = kIsWeb
          ? Image.network(
              imagePath!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            )
          : Image.file(
              File(imagePath!),
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Network URL
      child = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      child = _buildPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _buildPlaceholder() =>
      placeholder ??
      Container(
        width: width,
        height: height,
        color: const Color(0xFFF0F1F5),
        child: const Icon(Icons.image_outlined, color: Color(0xFFB0B3BE), size: 32),
      );
}

// ── Legacy compatibility shim (so old MockImagePicker.show() calls still work) ──
@Deprecated('Use AppImagePicker.pickImage() instead')
class MockImagePicker {
  static void show(BuildContext context, {required ValueChanged<String> onImageSelected}) {
    AppImagePicker.pickImage(context).then((path) {
      if (path != null) onImageSelected(path);
    });
  }
}

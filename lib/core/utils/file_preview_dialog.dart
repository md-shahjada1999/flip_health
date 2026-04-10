import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/file_picker_helper.dart';

class FilePreviewDialog {
  FilePreviewDialog._();

  static void show(PickedFileInfo file) {
    if (file.isImage && file.path.isNotEmpty) {
      _showImagePreview(file);
    } else {
      _showFileInfo(file);
    }
  }

  static void _showImagePreview(PickedFileInfo file) {
    Get.dialog(
      _ImagePreviewScreen(file: file),
      barrierColor: Colors.black87,
      useSafeArea: false,
    );
  }

  static void _showFileInfo(PickedFileInfo file) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.rw),
        child: Container(
          padding: EdgeInsets.all(24.rs),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.rs),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.rs,
                height: 64.rs,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.rs),
                ),
                child: Icon(
                  _iconForExtension(file.name),
                  size: 32.rs,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16.rh),
              CommonText(
                file.name,
                fontSize: 14.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.rh),
              CommonText(
                _extensionLabel(file.name),
                fontSize: 12.rf,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 20.rh),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.rh),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.rs),
                    ),
                  ),
                  child: CommonText(
                    'Close',
                    fontSize: 14.rf,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForExtension(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  static String _extensionLabel(String name) {
    final ext = name.split('.').last.toUpperCase();
    return '$ext File';
  }
}

class _ImagePreviewScreen extends StatefulWidget {
  final PickedFileInfo file;
  const _ImagePreviewScreen({required this.file});

  @override
  State<_ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<_ImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  final _transformCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  void _close() async {
    await _animCtrl.reverse();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: _close,
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.file(
                    File(widget.file.path),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_rounded,
                            size: 48.rs, color: Colors.white38),
                        SizedBox(height: 12.rh),
                        CommonText(
                          'Unable to load image',
                          fontSize: 14.rf,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.rh,
              left: 12.rw,
              right: 12.rw,
              child: Row(
                children: [
                  _buildHeaderButton(Icons.close_rounded, _close),
                  const Spacer(),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.rw, vertical: 6.rh),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8.rs),
                      ),
                      child: CommonText(
                        widget.file.name,
                        fontSize: 12.rf,
                        color: Colors.white70,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 40.rs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.rs,
        height: 40.rs,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12.rs),
        ),
        child: Icon(icon, size: 22.rs, color: Colors.white),
      ),
    );
  }
}

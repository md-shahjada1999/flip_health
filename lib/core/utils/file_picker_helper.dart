import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class PickedFileInfo {
  final String id;
  final String name;
  final String path;
  final bool isImage;

  PickedFileInfo({
    required this.id,
    required this.name,
    required this.path,
    this.isImage = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'path': path,
        'isImage': isImage,
      };

  static PickedFileInfo fromMap(Map<String, dynamic> map) => PickedFileInfo(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        path: map['path'] ?? '',
        isImage: map['isImage'] ?? false,
      );
}

class FilePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<PickedFileInfo?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return null;
      return PickedFileInfo(
        id: 'img_${DateTime.now().millisecondsSinceEpoch}',
        name: image.name,
        path: image.path,
        isImage: true,
      );
    } catch (e) {
      debugPrint('Gallery pick error: $e');
      return null;
    }
  }

  static Future<PickedFileInfo?> pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image == null) return null;
      return PickedFileInfo(
        id: 'cam_${DateTime.now().millisecondsSinceEpoch}',
        name: image.name,
        path: image.path,
        isImage: true,
      );
    } catch (e) {
      debugPrint('Camera pick error: $e');
      return null;
    }
  }

  static Future<PickedFileInfo?> pickFile({
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );
      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;
      return PickedFileInfo(
        id: 'file_${DateTime.now().millisecondsSinceEpoch}',
        name: file.name,
        path: file.path ?? '',
        isImage: _isImageFile(file.name),
      );
    } catch (e) {
      debugPrint('File pick error: $e');
      return null;
    }
  }

  static bool _isImageFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext);
  }

  static void showPickerBottomSheet({
    required Function(PickedFileInfo) onFilePicked,
    bool showFilePicker = true,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.rs),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.rs)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.rw,
              height: 4.rh,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.rs),
              ),
            ),
            SizedBox(height: 20.rh),
            CommonText(
              'Choose Source',
              fontSize: 18.rf,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 20.rh),
            _buildOption(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: () async {
                Get.back();
                final file = await pickFromGallery();
                if (file != null) onFilePicked(file);
              },
            ),
            SizedBox(height: 12.rh),
            _buildOption(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onTap: () async {
                Get.back();
                final file = await pickFromCamera();
                if (file != null) onFilePicked(file);
              },
            ),
            if (showFilePicker) ...[
              SizedBox(height: 12.rh),
              _buildOption(
                icon: Icons.attach_file_outlined,
                label: 'File',
                onTap: () async {
                  Get.back();
                  final file = await pickFile();
                  if (file != null) onFilePicked(file);
                },
              ),
            ],
            SizedBox(height: 16.rh),
          ],
        ),
      ),
    );
  }

  static Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.rh, horizontal: 16.rw),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12.rs),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.rs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.rs),
              ),
              child: Icon(icon, size: 22.rs, color: AppColors.primary),
            ),
            SizedBox(width: 14.rw),
            CommonText(label, fontSize: 15.rf, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16.rs, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  static Widget buildFilePreview(PickedFileInfo file) {
    if (file.isImage && file.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.rs),
        child: Image.file(
          File(file.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(file.name),
        ),
      );
    }
    return _buildFallbackIcon(file.name);
  }

  static Widget _buildFallbackIcon(String name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insert_drive_file_outlined, size: 28.rs, color: AppColors.textSecondary),
        SizedBox(height: 4.rh),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.rw),
          child: CommonText(
            name,
            fontSize: 8.rf,
            color: AppColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

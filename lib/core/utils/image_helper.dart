import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class ImageHelper {
  /// Convert image file to base64 string (format yang digunakan backend)
  static Future<String> convertToBase64(File imageFile) async {
    try {
// Validate file exists
      if (!await imageFile.exists()) {
        throw FileNotFoundException(imageFile.path);
      }
      // Validate file size
      final fileSizeInBytes = await imageFile.length();
      if (fileSizeInBytes > AppConstants.maxImageSizeMB * 1024 * 1024) {
        throw FileSizeExceededException(AppConstants.maxImageSizeMB);
      }

      // Validate file format
      final extension = getFileExtension(imageFile.path);
      if (!AppConstants.allowedImageFormats.contains(extension)) {
        throw UnsupportedFileTypeException(
          'Unsupported image format: $extension. Allowed formats: ${AppConstants.allowedImageFormats.join(', ')}',
        );
      }

      // Read file bytes
      final imageBytes = await imageFile.readAsBytes();

      // Get MIME type
      final mimeType = _getMimeType(extension);

      // Convert to base64 with data URL format
      final base64String = base64Encode(imageBytes);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException('Failed to convert image to base64: ${e.toString()}');
    }
  }

  /// Compress image before upload
  static Future<File> compressImage(
    File imageFile, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
// Read original image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw const DataParsingException();
      }

      // Resize if dimensions specified
      if (maxWidth != null || maxHeight != null) {
        originalImage = img.copyResize(
          originalImage,
          width: maxWidth,
          height: maxHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Compress image
      List<int> compressedBytes;
      final extension = getFileExtension(imageFile.path);

      switch (extension) {
        case 'png':
          compressedBytes = img.encodePng(originalImage, level: 6);
          break;
        case 'jpg':
        case 'jpeg':
        default:
          compressedBytes = img.encodeJpg(originalImage, quality: quality);
          break;
      }

      // Create compressed file
      final compressedFile = File('${imageFile.path}_compressed');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException('Failed to compress image: ${e.toString()}');
    }
  }

  /// Validate image file size
  static Future<bool> validateImageSize(File imageFile) async {
    try {
      final fileSizeInBytes = await imageFile.length();
      return fileSizeInBytes <= (AppConstants.maxImageSizeMB * 1024 * 1024);
    } catch (e) {
      return false;
    }
  }

  /// Validate image format
  static bool validateImageFormat(String filePath) {
    final extension = getFileExtension(filePath);
    return AppConstants.allowedImageFormats.contains(extension);
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }

  /// Get MIME type from file extension
  static String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Convert base64 string back to image file
  static Future<File> convertFromBase64(
    String base64String,
    String fileName,
  ) async {
    try {
// Remove data URL prefix if present
      String cleanBase64 = base64String;
      if (base64String.startsWith('data:')) {
        cleanBase64 = base64String.split(',')[1];
      }
      // Decode base64
      final imageBytes = base64Decode(cleanBase64);

      // Create file
      final file = File(fileName);
      await file.writeAsBytes(imageBytes);

      return file;
    } catch (e) {
      throw FileException('Failed to convert base64 to image: ${e.toString()}');
    }
  }

  /// Get image dimensions
  static Future<Size> getImageDimensions(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const DataParsingException();
      }

      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException('Failed to get image dimensions: ${e.toString()}');
    }
  }

  /// Create thumbnail from image
  static Future<File> createThumbnail(
    File imageFile, {
    int size = 150,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw const DataParsingException();
      }

      // Create square thumbnail
      final thumbnail = img.copyResizeCropSquare(originalImage, size: size);

      // Encode as JPEG for smaller file size
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);

      // Create thumbnail file
      final thumbnailFile = File('${imageFile.path}_thumb.jpg');
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return thumbnailFile;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException('Failed to create thumbnail: ${e.toString()}');
    }
  }

  /// Crop image to specified aspect ratio
  static Future<File> cropImage(
    File imageFile, {
    double aspectRatio = 1.0, // 1.0 for square, 16/9 for landscape
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw const DataParsingException();
      }

      // Calculate crop dimensions
      final originalWidth = originalImage.width;
      final originalHeight = originalImage.height;

      int cropWidth, cropHeight;

      if (originalWidth / originalHeight > aspectRatio) {
        // Image is wider than desired ratio
        cropHeight = originalHeight;
        cropWidth = (originalHeight * aspectRatio).round();
      } else {
        // Image is taller than desired ratio
        cropWidth = originalWidth;
        cropHeight = (originalWidth / aspectRatio).round();
      }

      // Calculate crop position (center crop)
      final cropX = (originalWidth - cropWidth) ~/ 2;
      final cropY = (originalHeight - cropHeight) ~/ 2;

      // Crop image
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Save cropped image
      final extension = getFileExtension(imageFile.path);
      final croppedBytes = extension == 'png'
          ? img.encodePng(croppedImage)
          : img.encodeJpg(croppedImage, quality: 90);

      final croppedFile = File('${imageFile.path}_cropped');
      await croppedFile.writeAsBytes(croppedBytes);

      return croppedFile;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException('Failed to crop image: ${e.toString()}');
    }
  }

  /// Get formatted file size string
  static String getFormattedFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Clean up temporary files
  static Future<void> cleanupTempFiles(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Failed to delete temp file: ${file.path}');
      }
    }
  }

  /// Process image for upload (compress and convert to base64)
  static Future<String> processImageForUpload(
    File imageFile, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    File? processedFile;
    try {
      // Validate image
      if (!validateImageFormat(imageFile.path)) {
        throw UnsupportedFileTypeException(
          'Unsupported image format: ${getFileExtension(imageFile.path)}',
        );
      }

      if (!await validateImageSize(imageFile)) {
        throw FileSizeExceededException(AppConstants.maxImageSizeMB);
      }

      // Compress image
      processedFile = await compressImage(
        imageFile,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      // Convert to base64
      final base64String = await convertToBase64(processedFile);

      return base64String;
    } finally {
      // Clean up compressed file
      if (processedFile != null) {
        await cleanupTempFiles([processedFile]);
      }
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:del_pick/core/constants/app_constants.dart';
import 'package:del_pick/core/errors/exceptions.dart';

class ImageHelper {
  static const Map<String, String> folderMapping = {
    'users': 'users',
    'drivers': 'drivers',
    'stores': 'stores',
    'menu-items': 'menu-items',
  };

  static const Map<String, String> prefixMapping = {
    'users': 'avatar',
    'drivers': 'driver',
    'stores': 'store',
    'menu-items': 'item',
  };

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

      // Validate file format - allowedImageTypes
      final extension = getFileExtension(imageFile.path);
      if (!AppConstants.allowedImageFormats.contains(extension)) {
        throw UnsupportedFileTypeException(
          'Format gambar tidak didukung: $extension. Format yang diizinkan: ${AppConstants.allowedImageFormats.join(', ')}',
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
      throw FileException(
          'Gagal mengkonversi gambar ke base64: ${e.toString()}');
    }
  }

  ///Validate base64 image format (untuk validasi dari backend response)
  static bool isValidBase64Image(String base64String) {
    try {
      // Check format sesuai backend
      if (!base64String.startsWith('data:image/')) {
        return false;
      }

      // Extract and validate base64 part
      if (!base64String.contains(';base64,')) {
        return false;
      }

      final base64Part = base64String.split(';base64,')[1];
      base64Decode(base64Part);
      return true;
    } catch (e) {
      return false;
    }
  }

  ///Extract image info from base64 (untuk debugging)
  static Map<String, dynamic> getBase64ImageInfo(String base64String) {
    try {
      if (!base64String.startsWith('data:image/')) {
        throw const DataParsingException();
      }

      final parts = base64String.split(';base64,');
      final mimeType = parts[0].replaceFirst('data:', '');
      final base64Data = parts[1];

      // Get file size
      final decodedBytes = base64Decode(base64Data);
      final sizeInMB = decodedBytes.length / (1024 * 1024);

      return {
        'mimeType': mimeType,
        'sizeInBytes': decodedBytes.length,
        'sizeInMB': sizeInMB,
        'isValid': sizeInMB <= AppConstants.maxImageSizeMB,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'isValid': false,
      };
    }
  }

  /// Compress image before upload
  static Future<File> compressImage(
    File imageFile, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
    bool maintainAspectRatio = true,
  }) async {
    try {
      // Read original image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw const DataParsingException();
      }

      // Smart resizing untuk mengurangi ukuran sesuai backend limit
      if (maxWidth != null || maxHeight != null) {
        if (maintainAspectRatio) {
          // Maintain aspect ratio
          final aspectRatio = originalImage.width / originalImage.height;

          if (maxWidth != null && maxHeight != null) {
            final targetRatio = maxWidth / maxHeight;
            if (aspectRatio > targetRatio) {
              maxHeight = (maxWidth / aspectRatio).round();
            } else {
              maxWidth = (maxHeight * aspectRatio).round();
            }
          } else if (maxWidth != null) {
            maxHeight = (maxWidth / aspectRatio).round();
          } else if (maxHeight != null) {
            maxWidth = (maxHeight * aspectRatio).round();
          }
        }

        originalImage = img.copyResize(
          originalImage,
          width: maxWidth,
          height: maxHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Compress image dengan format yang tepat
      List<int> compressedBytes;
      final extension = getFileExtension(imageFile.path);

      switch (extension) {
        case 'png':
          // PNG compression level (0-9, 6 adalah balanced)
          compressedBytes = img.encodePng(originalImage, level: 6);
          break;
        case 'jpg':
        case 'jpeg':
        default:
          // JPEG quality (0-100, 85 adalah balanced untuk backend)
          compressedBytes = img.encodeJpg(originalImage, quality: quality);
          break;
      }

      // Create compressed file
      final compressedFile = File('${imageFile.path}_compressed.${extension}');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException('Gagal mengkompress gambar: ${e.toString()}');
    }
  }

  ///Auto compress untuk memenuhi backend size limit
  static Future<File> autoCompressForBackend(File imageFile) async {
    File currentFile = imageFile;
    int quality = 95;
    int maxAttempts = 5;
    int attempt = 0;

    while (attempt < maxAttempts) {
      final size = await currentFile.length();

      // Jika sudah sesuai backend limit, return
      if (size <= AppConstants.maxImageSizeMB * 1024 * 1024) {
        return currentFile;
      }

      // Compress dengan quality yang lebih rendah
      quality = (quality * 0.8).round();
      if (quality < 30) quality = 30; // Minimum quality

      // Kompres ulang
      final compressed = await compressImage(
        currentFile,
        quality: quality,
        maxWidth: 1920, // Max width untuk mobile
        maxHeight: 1080, // Max height untuk mobile
      );

      // Clean up previous compressed file jika bukan file original
      if (currentFile != imageFile) {
        try {
          await currentFile.delete();
        } catch (e) {
          // Ignore deletion errors
        }
      }

      currentFile = compressed;
      attempt++;
    }

    return currentFile;
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

  /// Validate image format - ✅ SESUAI BACKEND allowedImageTypes
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
      throw FileException(
          'Gagal mengkonversi base64 ke gambar: ${e.toString()}');
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
      throw FileException('Gagal mendapatkan dimensi gambar: ${e.toString()}');
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
      throw FileException('Gagal membuat thumbnail: ${e.toString()}');
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

      final croppedFile = File('${imageFile.path}_cropped.${extension}');
      await croppedFile.writeAsBytes(croppedBytes);

      return croppedFile;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException('Gagal memotong gambar: ${e.toString()}');
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
        debugPrint('Gagal menghapus file sementara: ${file.path}');
      }
    }
  }

  ///Process image for upload (dengan auto-compress jika perlu)
  static Future<String> processImageForUpload(
    File imageFile, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
    bool autoCompress = true,
  }) async {
    File? processedFile;
    List<File> tempFiles = [];

    try {
      // Validate image format
      if (!validateImageFormat(imageFile.path)) {
        throw UnsupportedFileTypeException(
          'Format gambar tidak didukung: ${getFileExtension(imageFile.path)}',
        );
      }

      File fileToProcess = imageFile;

      // Auto compress jika file terlalu besar
      if (autoCompress && !await validateImageSize(imageFile)) {
        fileToProcess = await autoCompressForBackend(imageFile);
        tempFiles.add(fileToProcess);
      }

      // Manual compress jika diminta
      if (maxWidth != null || maxHeight != null || quality < 95) {
        processedFile = await compressImage(
          fileToProcess,
          quality: quality,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
        tempFiles.add(processedFile);
      } else {
        processedFile = fileToProcess;
      }

      // Final validation
      if (!await validateImageSize(processedFile)) {
        throw FileSizeExceededException(AppConstants.maxImageSizeMB);
      }

      // Convert to base64
      final base64String = await convertToBase64(processedFile);

      return base64String;
    } finally {
      // Clean up temp files
      if (tempFiles.isNotEmpty) {
        await cleanupTempFiles(tempFiles);
      }
    }
  }

  ///Generate file name sesuai backend pattern
  static String generateBackendFileName(String folder, String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp';
  }

  ///Validate image requirements untuk berbagai use case
  static Future<Map<String, dynamic>> validateImageRequirements(
    File imageFile, {
    required String purpose, // 'avatar', 'store', 'menu', etc.
  }) async {
    final result = <String, dynamic>{
      'isValid': false,
      'errors': <String>[],
      'warnings': <String>[],
      'info': <String, dynamic>{},
    };

    try {
      // Basic validations
      if (!await imageFile.exists()) {
        result['errors'].add('File tidak ditemukan');
        return result;
      }

      if (!validateImageFormat(imageFile.path)) {
        result['errors'].add('Format file tidak didukung');
        return result;
      }

      final size = await imageFile.length();
      result['info']['sizeInBytes'] = size;
      result['info']['sizeFormatted'] = getFormattedFileSize(size);

      if (size > AppConstants.maxImageSizeMB * 1024 * 1024) {
        result['errors'].add(
            'Ukuran file terlalu besar (max ${AppConstants.maxImageSizeMB}MB)');
      }

      // Get dimensions
      final dimensions = await getImageDimensions(imageFile);
      result['info']['width'] = dimensions.width;
      result['info']['height'] = dimensions.height;
      result['info']['aspectRatio'] = dimensions.width / dimensions.height;

      // Purpose-specific validations
      switch (purpose) {
        case 'avatar':
          if (dimensions.width < 100 || dimensions.height < 100) {
            result['warnings']
                .add('Resolusi rendah untuk foto profil (min 100x100)');
          }
          if ((dimensions.width / dimensions.height - 1).abs() > 0.2) {
            result['warnings']
                .add('Rasio aspek tidak persegi untuk foto profil');
          }
          break;

        case 'store':
          if (dimensions.width < 300 || dimensions.height < 200) {
            result['warnings']
                .add('Resolusi rendah untuk foto toko (min 300x200)');
          }
          break;

        case 'menu':
          if (dimensions.width < 200 || dimensions.height < 150) {
            result['warnings']
                .add('Resolusi rendah untuk foto menu (min 200x150)');
          }
          break;
      }

      result['isValid'] = (result['errors'] as List).isEmpty;
      return result;
    } catch (e) {
      result['errors'].add('Error validasi: ${e.toString()}');
      return result;
    }
  }
}

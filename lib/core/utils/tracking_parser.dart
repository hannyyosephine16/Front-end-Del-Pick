// lib/core/utils/tracking_parser.dart - FIX BACKEND TRACKING_UPDATES PARSING
import 'dart:convert';

class TrackingParser {
  /// Parse tracking updates dari backend yang kadang rusak JSON-nya
  static List<Map<String, dynamic>> parseTrackingUpdates(
      dynamic trackingUpdates) {
    if (trackingUpdates == null) return [];

    try {
      // Jika sudah List
      if (trackingUpdates is List) {
        return trackingUpdates.cast<Map<String, dynamic>>();
      }

      // Jika String, coba parse JSON
      if (trackingUpdates is String) {
        // Handle corrupted JSON string dari backend
        String cleanJson = _cleanTrackingJson(trackingUpdates);

        if (cleanJson.isEmpty) return [];

        final parsed = jsonDecode(cleanJson);
        if (parsed is List) {
          return parsed.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } catch (e) {
      print('Error parsing tracking updates: $e');
      return [];
    }
  }

  /// Clean corrupted JSON string dari backend
  static String _cleanTrackingJson(String rawJson) {
    try {
      // Remove escaped quotes dan characters yang rusak
      String cleaned = rawJson
          .replaceAll(r'\"', '"')
          .replaceAll(r'\\', '')
          .replaceAll('",",', ',')
          .replaceAll('"[', '[')
          .replaceAll(']"', ']');

      // Try to find valid JSON array
      final startIndex = cleaned.indexOf('[');
      final endIndex = cleaned.lastIndexOf(']');

      if (startIndex >= 0 && endIndex > startIndex) {
        cleaned = cleaned.substring(startIndex, endIndex + 1);
      }

      // Validate if it's valid JSON
      jsonDecode(cleaned);
      return cleaned;
    } catch (e) {
      // Jika gagal, coba extract manual
      return _extractManualTrackingData(rawJson);
    }
  }

  /// Extract tracking data secara manual jika JSON rusak total
  static String _extractManualTrackingData(String rawData) {
    try {
      final List<Map<String, dynamic>> trackingList = [];

      // Extract timestamp patterns
      final timestampPattern =
          RegExp(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)');
      final timestamps =
          timestampPattern.allMatches(rawData).map((m) => m.group(1)).toList();

      // Extract status patterns
      final statusPattern = RegExp(r'"status":"([^"]+)"');
      final statuses =
          statusPattern.allMatches(rawData).map((m) => m.group(1)).toList();

      // Extract message patterns
      final messagePattern = RegExp(r'"message":"([^"]+)"');
      final messages =
          messagePattern.allMatches(rawData).map((m) => m.group(1)).toList();

      // Combine extracted data
      for (int i = 0;
          i < timestamps.length && i < statuses.length && i < messages.length;
          i++) {
        trackingList.add({
          'timestamp': timestamps[i],
          'status': statuses[i],
          'message': messages[i],
        });
      }

      return jsonEncode(trackingList);
    } catch (e) {
      print('Manual extraction failed: $e');
      return '[]';
    }
  }

  /// Format tracking update untuk display
  static Map<String, dynamic> formatTrackingUpdate(
      Map<String, dynamic> update) {
    return {
      'timestamp': update['timestamp'] ?? DateTime.now().toIso8601String(),
      'status': update['status'] ?? 'unknown',
      'message': update['message'] ?? 'No message',
      'location': update['location'],
      'estimated_times': update['estimated_times'],
      'distances': update['distances'],
    };
  }

  /// Get latest tracking status
  static String getLatestStatus(List<Map<String, dynamic>> trackingUpdates) {
    if (trackingUpdates.isEmpty) return 'pending';

    final latest = trackingUpdates.last;
    return latest['status'] ?? 'pending';
  }

  /// Get latest tracking message
  static String getLatestMessage(List<Map<String, dynamic>> trackingUpdates) {
    if (trackingUpdates.isEmpty) return 'No updates available';

    final latest = trackingUpdates.last;
    return latest['message'] ?? 'No message';
  }

  /// Parse datetime dari tracking
  static DateTime? parseTrackingTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return null;

    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Create new tracking update
  static Map<String, dynamic> createTrackingUpdate({
    required String status,
    required String message,
    Map<String, dynamic>? location,
    Map<String, dynamic>? estimatedTimes,
    Map<String, dynamic>? distances,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'status': status,
      'message': message,
      if (location != null) 'location': location,
      if (estimatedTimes != null) 'estimated_times': estimatedTimes,
      if (distances != null) 'distances': distances,
    };
  }
}

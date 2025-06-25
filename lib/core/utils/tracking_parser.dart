// lib/core/utils/tracking_parser.dart - FIXED DART SYNTAX
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:math' as math;

class TrackingParser {
  /// Parse tracking updates dari backend yang kadang rusak JSON-nya
  static List<Map<String, dynamic>> parseTrackingUpdates(
      dynamic trackingUpdates) {
    if (trackingUpdates == null) return [];

    try {
      // ✅ Case 1: Jika sudah List of Maps
      if (trackingUpdates is List) {
        final List<Map<String, dynamic>> result = [];

        for (final item in trackingUpdates) {
          if (item is Map<String, dynamic>) {
            result.add(item);
          } else if (item is Map) {
            result.add(Map<String, dynamic>.from(item));
          } else if (item is String) {
            // Parse individual string items
            final parsed = _parseStringToMap(item);
            if (parsed != null) result.add(parsed);
          }
        }

        return result;
      }

      // ✅ Case 2: String JSON (might be corrupted)
      if (trackingUpdates is String) {
        return _parseStringTrackingUpdates(trackingUpdates);
      }

      // ✅ Case 3: Single Map
      if (trackingUpdates is Map) {
        return [Map<String, dynamic>.from(trackingUpdates)];
      }

      developer
          .log('Unknown tracking updates type: ${trackingUpdates.runtimeType}');
      return [];
    } catch (e, stackTrace) {
      developer.log('Error parsing tracking updates',
          error: e, stackTrace: stackTrace, name: 'TrackingParser');
      return _createFallbackTrackingUpdate();
    }
  }

  /// Parse String tracking updates dengan berbagai fallback
  static List<Map<String, dynamic>> _parseStringTrackingUpdates(
      String rawJson) {
    if (rawJson.trim().isEmpty) return [];

    try {
      // ✅ Try 1: Direct JSON decode
      final parsed = jsonDecode(rawJson);
      if (parsed is List) {
        return parsed.cast<Map<String, dynamic>>();
      }
      if (parsed is Map) {
        return [Map<String, dynamic>.from(parsed)];
      }
    } catch (e) {
      developer.log('Direct JSON decode failed: $e', name: 'TrackingParser');
    }

    try {
      // ✅ Try 2: Clean corrupted JSON
      final cleaned = _cleanCorruptedJson(rawJson);
      if (cleaned.isNotEmpty) {
        final parsed = jsonDecode(cleaned);
        if (parsed is List) {
          return parsed.cast<Map<String, dynamic>>();
        }
        if (parsed is Map) {
          return [Map<String, dynamic>.from(parsed)];
        }
      }
    } catch (e) {
      developer.log('Cleaned JSON decode failed: $e', name: 'TrackingParser');
    }

    // ✅ Try 3: Manual extraction for severely corrupted data
    return _extractManualTrackingData(rawJson);
  }

  /// Clean corrupted JSON string dari backend
  static String _cleanCorruptedJson(String rawJson) {
    try {
      String cleaned = rawJson.trim();

      // ✅ Handle severely corrupted data seperti dari backend Anda
      if (cleaned.contains('","",",')) {
        // Data rusak total seperti pada order id 5
        return _reconstructFromCorruptedData(cleaned);
      }

      // ✅ Handle common escape issues from backend
      cleaned = cleaned
          .replaceAll(r'\"', '"') // Fix escaped quotes
          .replaceAll(r'\\', r'\') // Fix double backslashes
          .replaceAll('",",', '","') // Fix comma issues
          .replaceAll('"[', '[') // Fix array start
          .replaceAll(']"', ']') // Fix array end
          .replaceAll('"{', '{') // Fix object start
          .replaceAll('}"', '}'); // Fix object end

      // ✅ Remove extra quotes around JSON
      if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }

      // ✅ Fix double JSON encoding
      if (cleaned.startsWith('\\"[') && cleaned.endsWith(']\\"')) {
        cleaned = cleaned.replaceAll('\\"', '"').replaceAll('\\\\', '\\');
      }

      // ✅ Find valid JSON boundaries
      final startIndex = cleaned.indexOf('[');
      final endIndex = cleaned.lastIndexOf(']');

      if (startIndex >= 0 && endIndex > startIndex) {
        cleaned = cleaned.substring(startIndex, endIndex + 1);
      } else {
        // Try single object
        final objStart = cleaned.indexOf('{');
        final objEnd = cleaned.lastIndexOf('}');
        if (objStart >= 0 && objEnd > objStart) {
          cleaned = '[${cleaned.substring(objStart, objEnd + 1)}]';
        }
      }

      // ✅ Validate cleaned JSON
      jsonDecode(cleaned);
      return cleaned;
    } catch (e) {
      developer.log('JSON cleaning failed: $e', name: 'TrackingParser');
      return '';
    }
  }

  /// Reconstruct dari data yang rusak total seperti dari backend Anda
  static String _reconstructFromCorruptedData(String corruptedData) {
    try {
      // Extract valid JSON objects dari data rusak
      final validObjects = <String>[];

      // Pattern untuk mencari object JSON yang valid
      final objectPattern = RegExp('[{][^{}]*"timestamp"[^{}]*[}]');
      final matches = objectPattern.allMatches(corruptedData);

      for (final match in matches) {
        final objectStr = match.group(0);
        if (objectStr != null) {
          try {
            // Validate object
            jsonDecode(objectStr);
            validObjects.add(objectStr);
          } catch (e) {
            // Try to fix common issues in the object
            String fixed = objectStr.replaceAll('""', '"').replaceAll('_', '_');

            try {
              jsonDecode(fixed);
              validObjects.add(fixed);
            } catch (e2) {
              // Skip invalid objects
            }
          }
        }
      }

      if (validObjects.isNotEmpty) {
        return '[${validObjects.join(',')}]';
      }

      // Fallback: extract basic info manually
      final fallbackObjects = <String>[];

      // Extract timestamps
      final timestampPattern =
          RegExp('(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:\\.\\d{3})?Z)');
      final timestamps = timestampPattern
          .allMatches(corruptedData)
          .map((m) => m.group(1))
          .where((t) => t != null)
          .cast<String>()
          .toList();

      // Extract status
      final statusPattern = RegExp(
          '"(pending|confirmed|preparing|ready_for_pickup|on_delivery|delivered|cancelled|rejected)"');
      final statuses = statusPattern
          .allMatches(corruptedData)
          .map((m) => m.group(1))
          .where((s) => s != null)
          .cast<String>()
          .toList();

      // Create fallback objects
      for (int i = 0; i < timestamps.length; i++) {
        final status = i < statuses.length ? statuses[i] : 'pending';
        final message = _getMessageForStatus(status);

        fallbackObjects.add(
            '{"timestamp":"${timestamps[i]}","status":"$status","message":"$message"}');
      }

      return fallbackObjects.isNotEmpty
          ? '[${fallbackObjects.join(',')}]'
          : '[{"timestamp":"${DateTime.now().toIso8601String()}","status":"pending","message":"Order created"}]';
    } catch (e) {
      developer.log('Reconstruction failed: $e', name: 'TrackingParser');
      return '[{"timestamp":"${DateTime.now().toIso8601String()}","status":"pending","message":"Order created"}]';
    }
  }

  /// Get default message for status
  static String _getMessageForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Order telah dibuat';
      case 'confirmed':
        return 'Order dikonfirmasi';
      case 'preparing':
        return 'Order sedang diproses';
      case 'ready_for_pickup':
        return 'Order siap diambil';
      case 'on_delivery':
        return 'Driver mulai mengantar pesanan';
      case 'delivered':
        return 'Pesanan telah sampai di tujuan';
      case 'cancelled':
        return 'Order dibatalkan';
      case 'rejected':
        return 'Order ditolak';
      default:
        return 'Update status';
    }
  }

  /// Extract tracking data secara manual jika JSON rusak total
  static List<Map<String, dynamic>> _extractManualTrackingData(String rawData) {
    try {
      final List<Map<String, dynamic>> trackingList = [];

      // ✅ Prioritas: Extract valid JSON objects first
      final objectPattern =
          RegExp('[{][^{}]*"timestamp"[^{}]*"status"[^{}]*"message"[^{}]*[}]');
      final objectMatches = objectPattern.allMatches(rawData);

      for (final match in objectMatches) {
        final objectStr = match.group(0);
        if (objectStr != null) {
          try {
            final parsed = jsonDecode(objectStr);
            if (parsed is Map<String, dynamic>) {
              trackingList.add(parsed);
            }
          } catch (e) {
            // Try to fix the object
            String fixed = objectStr
                .replaceAll('""', '"')
                .replaceAll('\\"', '"')
                .replaceAll('\\\\', '\\');

            try {
              final parsed = jsonDecode(fixed);
              if (parsed is Map<String, dynamic>) {
                trackingList.add(parsed);
              }
            } catch (e2) {
              // Skip this object
            }
          }
        }
      }

      if (trackingList.isNotEmpty) {
        return trackingList;
      }

      // ✅ Fallback: Extract dengan regex patterns
      final timestampPattern = RegExp(
          r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z)',
          multiLine: true);

      final timestamps = <String>[];
      final matches = timestampPattern.allMatches(rawData);
      for (final match in matches) {
        final group = match.group(1);
        if (group != null) {
          timestamps.add(group);
        }
      }

      // ✅ Extract status dengan berbagai patterns
      final statusPatterns = [
        RegExp('"status"\\s*:\\s*"([^"]+)"'),
        RegExp("'status'\\s*:\\s*'([^']+)'"),
        RegExp('status["\']?\\s*:\\s*["\']?([^,}\\]]+)["\']?'),
        RegExp(
            '"(pending|confirmed|preparing|ready_for_pickup|on_delivery|delivered|cancelled|rejected)"'),
      ];

      final statuses = <String>[];
      for (final pattern in statusPatterns) {
        final matches = pattern.allMatches(rawData);
        for (final match in matches) {
          final group = match.group(1);
          if (group != null && _isValidStatus(group)) {
            statuses.add(group);
          }
        }
        if (statuses.isNotEmpty) break;
      }

      // ✅ Extract message dengan berbagai patterns
      final messagePatterns = [
        RegExp('"message"\\s*:\\s*"([^"]+)"'),
        RegExp("'message'\\s*:\\s*'([^']+)'"),
        RegExp('message["\']?\\s*:\\s*["\']?([^,}\\]]+)["\']?'),
      ];

      final messages = <String>[];
      for (final pattern in messagePatterns) {
        final matches = pattern.allMatches(rawData);
        for (final match in matches) {
          final group = match.group(1);
          if (group != null && group.trim().isNotEmpty) {
            messages.add(group);
          }
        }
        if (messages.isNotEmpty) break;
      }

      // ✅ Combine extracted data
      final maxLength = [timestamps.length, statuses.length, messages.length]
          .reduce((a, b) => a > b ? a : b);

      for (int i = 0; i < maxLength; i++) {
        final timestamp = i < timestamps.length
            ? timestamps[i]
            : DateTime.now().toIso8601String();
        final status = i < statuses.length ? statuses[i] : 'pending';
        final message =
            i < messages.length ? messages[i] : _getMessageForStatus(status);

        final tracking = <String, dynamic>{
          'timestamp': timestamp,
          'status': status,
          'message': message,
        };

        trackingList.add(tracking);
      }

      return trackingList.isNotEmpty
          ? trackingList
          : _createFallbackTrackingUpdate();
    } catch (e, stackTrace) {
      developer.log('Manual extraction failed',
          error: e, stackTrace: stackTrace, name: 'TrackingParser');
      return _createFallbackTrackingUpdate();
    }
  }

  /// Check if status is valid
  static bool _isValidStatus(String status) {
    const validStatuses = {
      'pending',
      'confirmed',
      'preparing',
      'ready_for_pickup',
      'on_delivery',
      'delivered',
      'cancelled',
      'rejected'
    };
    return validStatuses.contains(status.toLowerCase());
  }

  /// Parse individual string to map
  static Map<String, dynamic>? _parseStringToMap(String str) {
    try {
      // Try direct JSON decode
      final parsed = jsonDecode(str);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      if (parsed is Map) {
        return Map<String, dynamic>.from(parsed);
      }
    } catch (e) {
      // Try to clean and parse
      try {
        final cleaned = _cleanCorruptedJson(str);
        if (cleaned.isNotEmpty) {
          final parsed = jsonDecode(cleaned);
          if (parsed is List && parsed.isNotEmpty) {
            final first = parsed.first;
            if (first is Map) {
              return Map<String, dynamic>.from(first);
            }
          }
        }
      } catch (e2) {
        // Ignore nested errors
      }
    }

    return null;
  }

  /// Create fallback tracking update
  static List<Map<String, dynamic>> _createFallbackTrackingUpdate() {
    return [
      {
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'pending',
        'message': 'Order created',
      }
    ];
  }

  /// Format tracking update untuk display
  static Map<String, dynamic> formatTrackingUpdate(
      Map<String, dynamic> update) {
    final Map<String, dynamic> result = {
      'timestamp': update['timestamp'] ?? DateTime.now().toIso8601String(),
      'status': _sanitizeStatus(update['status']),
      'message': _sanitizeMessage(update['message']),
    };

    // Add optional fields only if they exist
    if (update['location'] != null) {
      result['location'] = update['location'];
    }
    if (update['estimated_times'] != null) {
      result['estimated_times'] = update['estimated_times'];
    }
    if (update['distances'] != null) {
      result['distances'] = update['distances'];
    }

    return result;
  }

  /// Sanitize status value
  static String _sanitizeStatus(dynamic status) {
    if (status == null) return 'unknown';
    if (status is String) {
      return status.trim().toLowerCase();
    }
    return status.toString().trim().toLowerCase();
  }

  /// Sanitize message value
  static String _sanitizeMessage(dynamic message) {
    if (message == null) return 'No message available';
    if (message is String) {
      return message.trim();
    }
    return message.toString().trim();
  }

  /// Get latest tracking status
  static String getLatestStatus(List<Map<String, dynamic>> trackingUpdates) {
    if (trackingUpdates.isEmpty) return 'pending';

    final latest = trackingUpdates.last;
    return _sanitizeStatus(latest['status']);
  }

  /// Get latest tracking message
  static String getLatestMessage(List<Map<String, dynamic>> trackingUpdates) {
    if (trackingUpdates.isEmpty) return 'No updates available';

    final latest = trackingUpdates.last;
    return _sanitizeMessage(latest['message']);
  }

  /// Parse datetime dari tracking dengan safety
  static DateTime? parseTrackingTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return null;

    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      // Try different formats
      try {
        // Try removing Z and parse
        final cleaned = timestamp.replaceAll('Z', '');
        return DateTime.parse(cleaned);
      } catch (e2) {
        developer.log('Failed to parse timestamp: $timestamp',
            error: e2, name: 'TrackingParser');
        return null;
      }
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
    final Map<String, dynamic> result = {
      'timestamp': DateTime.now().toIso8601String(),
      'status': _sanitizeStatus(status),
      'message': _sanitizeMessage(message),
    };

    // Add optional fields only if provided
    if (location != null) {
      result['location'] = location;
    }
    if (estimatedTimes != null) {
      result['estimated_times'] = estimatedTimes;
    }
    if (distances != null) {
      result['distances'] = distances;
    }

    return result;
  }

  /// Validate tracking update structure
  static bool isValidTrackingUpdate(Map<String, dynamic> update) {
    return update.containsKey('timestamp') &&
        update.containsKey('status') &&
        update.containsKey('message');
  }

  /// Clean and normalize tracking updates list
  static List<Map<String, dynamic>> normalizeTrackingUpdates(
      List<Map<String, dynamic>> updates) {
    return updates
        .where(isValidTrackingUpdate)
        .map(formatTrackingUpdate)
        .toList();
  }

  /// Debug tracking data (untuk development)
  static void debugTrackingData(dynamic trackingUpdates) {
    if (!kDebugMode) return;

    try {
      final truncatedValue = trackingUpdates.toString().length > 500
          ? '${trackingUpdates.toString().substring(0, 500)}...'
          : trackingUpdates.toString();

      developer.log(
          'Tracking Updates Debug: Type=${trackingUpdates.runtimeType}, '
          'Value=$truncatedValue',
          name: 'TrackingParser');
    } catch (e) {
      developer.log('Debug tracking data failed: $e', name: 'TrackingParser');
    }
  }
}

// lib/core/utils/parsing_helper.dart - COMPLETE VERSION
class ParsingHelper {
  /// Safely parse double from dynamic value (handles String, int, double, null)
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Safely parse int from dynamic value (handles String, int, double, null)
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Safely parse double with default value
  static double parseDoubleWithDefault(dynamic value, double defaultValue) {
    return parseDouble(value) ?? defaultValue;
  }

  /// Safely parse int with default value
  static int parseIntWithDefault(dynamic value, int defaultValue) {
    return parseInt(value) ?? defaultValue;
  }

  /// Safely parse string with default value
  static String parseStringWithDefault(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely parse string (nullable)
  static String? parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Safely parse DateTime
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Safely parse DateTime with default value
  static DateTime parseDateTimeWithDefault(
      dynamic value, DateTime defaultValue) {
    if (value == null) return defaultValue;
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely parse bool with default value
  static bool parseBoolWithDefault(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) {
      return value == 1;
    }
    return defaultValue;
  }

  /// Safely parse bool (nullable)
  static bool? parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) {
      return value == 1;
    }
    return null;
  }

  /// Safely parse List
  static List<T>? parseList<T>(dynamic value, T Function(dynamic) converter) {
    if (value == null) return null;
    if (value is! List) return null;

    try {
      return value.map((item) => converter(item)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Safely parse Map
  static Map<String, dynamic>? parseMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  /// Safely convert any value to String for JSON serialization
  static String toStringForJson(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// Safely convert any value to nullable String for JSON
  static String? toNullableStringForJson(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Safely parse URL/URI strings
  static String? parseUrl(dynamic value) {
    final url = parseString(value);
    if (url == null || url.isEmpty) return null;

    // Basic URL validation
    if (url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/')) {
      return url;
    }

    return null;
  }

  /// Safely parse phone numbers
  static String? parsePhoneNumber(dynamic value) {
    final phone = parseString(value);
    if (phone == null || phone.isEmpty) return null;

    // Remove common phone number formatting
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Safely parse email addresses
  static String? parseEmail(dynamic value) {
    final email = parseString(value);
    if (email == null || email.isEmpty) return null;

    // Basic email validation
    if (email.contains('@') && email.contains('.')) {
      return email.toLowerCase().trim();
    }

    return null;
  }

  /// Parse nested object safely
  static Map<String, dynamic>? parseNestedObject(dynamic value, String key) {
    if (value is! Map<String, dynamic>) return null;

    final nested = value[key];
    if (nested is Map<String, dynamic>) {
      return nested;
    }

    return null;
  }

  /// Parse array of objects safely
  static List<Map<String, dynamic>>? parseObjectArray(dynamic value) {
    if (value is! List) return null;

    try {
      return value
          .where((item) => item is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Check if value is empty (null, empty string, empty list, empty map)
  static bool isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  /// Check if value is not empty
  static bool isNotEmpty(dynamic value) {
    return !isEmpty(value);
  }

  /// Parse and validate enum values
  static T? parseEnum<T>(dynamic value, List<T> enumValues) {
    if (value == null) return null;

    final stringValue = value.toString().toLowerCase();

    for (final enumValue in enumValues) {
      if (enumValue.toString().toLowerCase().contains(stringValue)) {
        return enumValue;
      }
    }

    return null;
  }

  /// Parse status strings to standardized format
  static String parseStatus(dynamic value, {String defaultStatus = 'unknown'}) {
    final status = parseString(value);
    if (status == null || status.isEmpty) return defaultStatus;

    return status.toLowerCase().trim();
  }

  /// Parse and validate coordinate values (latitude/longitude)
  static double? parseCoordinate(dynamic value) {
    final coord = parseDouble(value);
    if (coord == null) return null;

    // Basic coordinate validation (-180 to 180)
    if (coord >= -180 && coord <= 180) {
      return coord;
    }

    return null;
  }

  /// Parse rating values (typically 0-5)
  static double parseRating(dynamic value,
      {double min = 0.0, double max = 5.0}) {
    final rating = parseDoubleWithDefault(value, min);

    // Clamp rating between min and max
    if (rating < min) return min;
    if (rating > max) return max;

    return rating;
  }

  /// Parse price/money values
  static double parsePrice(dynamic value) {
    final price = parseDoubleWithDefault(value, 0.0);

    // Ensure price is not negative
    return price < 0 ? 0.0 : price;
  }
}

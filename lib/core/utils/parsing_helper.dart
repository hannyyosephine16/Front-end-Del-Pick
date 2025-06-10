// lib/utils/parsing_helper.dart
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
}

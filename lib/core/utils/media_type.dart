class DioMediaType {
  final String type;
  final String subtype;
  final Map<String, String> parameters;

  const DioMediaType(this.type, this.subtype, [this.parameters = const {}]);

  /// Parse media type from string
  static DioMediaType parse(String mediaType) {
    final parts = mediaType.split('/');
    if (parts.length != 2) {
      throw ArgumentError('Invalid media type format: $mediaType');
    }

    return DioMediaType(parts[0], parts[1]);
  }

  @override
  String toString() {
    if (parameters.isEmpty) {
      return '$type/$subtype';
    }

    final paramString =
        parameters.entries.map((e) => '${e.key}=${e.value}').join('; ');

    return '$type/$subtype; $paramString';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DioMediaType) return false;

    return type == other.type &&
        subtype == other.subtype &&
        _mapEquals(parameters, other.parameters);
  }

  @override
  int get hashCode => Object.hash(type, subtype, parameters);

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

import 'dart:math' as math;

class DistanceHelper {
  /// Menghitung jarak antara dua titik koordinat menggunakan Haversine formula
  /// @param lat1 - Latitude titik pertama
  /// @param lon1 - Longitude titik pertama
  /// @param lat2 - Latitude titik kedua
  /// @param lon2 - Longitude titik kedua
  /// @returns Jarak dalam kilometer
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer

    // Konversi derajat ke radian
    final double lat1Rad = lat1 * (math.pi / 180);
    final double lat2Rad = lat2 * (math.pi / 180);
    final double deltaLatRad = (lat2 - lat1) * (math.pi / 180);
    final double deltaLonRad = (lon2 - lon1) * (math.pi / 180);

    // Haversine formula
    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  /// Format jarak untuk tampilan
  /// @param distanceKm - Jarak dalam kilometer
  /// @returns String jarak yang sudah diformat
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Cek apakah lokasi dalam radius pengiriman
  /// @param userLat - Latitude user
  /// @param userLon - Longitude user
  /// @param storeLat - Latitude store
  /// @param storeLon - Longitude store
  /// @param maxRadius - Radius maksimal dalam kilometer
  /// @returns Boolean apakah dalam radius
  static bool isWithinDeliveryRadius(
    double userLat,
    double userLon,
    double storeLat,
    double storeLon,
    double maxRadius,
  ) {
    final distance = calculateDistance(userLat, userLon, storeLat, storeLon);
    return distance <= maxRadius;
  }
}

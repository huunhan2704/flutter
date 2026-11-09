import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteInfo {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final double durationSeconds;
  final String summary;

  RouteInfo({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    this.summary = '',
  });

  String get distanceKm => (distanceMeters / 1000).toStringAsFixed(1);
  String get durationMinutes => (durationSeconds / 60).toStringAsFixed(0);
}

/// Service tính toán lộ trình Polyline thực tế trên đường phố bằng OSRM (Open Source Routing Machine)
class OsrmService {
  static const String _osrmBaseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Lấy danh sách toạ độ Polyline thực tế từ điểm Start đến End qua OSRM API
  static Future<RouteInfo?> getRoutePolyline({
    required LatLng start,
    required LatLng destination,
  }) async {
    try {
      // OSRM nhận toạ độ dạng: {longitude},{latitude};{longitude},{latitude}
      final url = '$_osrmBaseUrl/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;

          final List<LatLng> points = coordinates.map((coord) {
            final lng = (coord[0] as num).toDouble();
            final lat = (coord[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          final distance = (route['distance'] as num?)?.toDouble() ?? 0.0;
          final duration = (route['duration'] as num?)?.toDouble() ?? 0.0;

          return RouteInfo(
            polylinePoints: points,
            distanceMeters: distance,
            durationSeconds: duration,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Lỗi gọi OSRM API: $e. Sử dụng đường nối thẳng.');
    }

    // Fallback: Đường nối trực tiếp nếu mạng ngắt kết nối
    return RouteInfo(
      polylinePoints: [start, destination],
      distanceMeters: 0,
      durationSeconds: 0,
    );
  }
}

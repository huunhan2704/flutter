import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/subject.dart';
import '../services/osrm_service.dart';

class MapLocationController extends ChangeNotifier {
  final MapController _mapController = MapController();

  LatLng _currentLocation = const LatLng(10.77689, 106.70081); // Mặc định Quận 1, TP.HCM
  bool _isLoadingLocation = false;
  bool _isLoadingRoute = false;
  RouteInfo? _currentRouteInfo;
  CampusLocation _selectedCampus = CampusLocation.nhaBe;

  MapController get mapController => _mapController;
  LatLng get currentLocation => _currentLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLoadingRoute => _isLoadingRoute;
  RouteInfo? get currentRouteInfo => _currentRouteInfo;
  CampusLocation get selectedCampus => _selectedCampus;

  MapLocationController() {
    initMap();
  }

  Future<void> initMap() async {
    await determinePosition();
    await updateMapElements(CampusLocation.nhaBe);
  }

  /// Lấy vị trí GPS hiện tại của thiết bị
  Future<void> determinePosition() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoadingLocation = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Lỗi GPS: $e (Sử dụng toạ độ mặc định TPHCM)');
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Cập nhật toạ độ và tính toán tuyến đường OSRM Polyline thực tế
  Future<void> updateMapElements(CampusLocation campus) async {
    _selectedCampus = campus;
    final campusLatLng = LatLng(campus.latitude, campus.longitude);

    _isLoadingRoute = true;
    notifyListeners();

    // Gọi API OSRM tính toán Polyline thực tế trên đường phố
    final routeInfo = await OsrmService.getRoutePolyline(
      start: _currentLocation,
      destination: campusLatLng,
    );

    _currentRouteInfo = routeInfo;
    _isLoadingRoute = false;
    notifyListeners();

    // Bay bản đồ tới vị trí cơ sở được chọn
    moveCameraTo(campusLatLng);
  }

  void moveCameraTo(LatLng target, {double zoom = 14.5}) {
    try {
      _mapController.move(target, zoom);
    } catch (_) {}
  }
}

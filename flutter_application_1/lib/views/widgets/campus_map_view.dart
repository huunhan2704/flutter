import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/map_controller.dart';
import '../../models/subject.dart';

class CampusMapView extends StatelessWidget {
  final MapLocationController mapController;
  final CampusLocation selectedCampus;

  const CampusMapView({
    super.key,
    required this.mapController,
    required this.selectedCampus,
  });

  @override
  Widget build(BuildContext context) {
    final route = mapController.currentRouteInfo;
    final campusLatLng = LatLng(selectedCampus.latitude, selectedCampus.longitude);

    final otherCampus = selectedCampus.name == 'Nhà bè'
        ? CampusLocation.leVanSy
        : CampusLocation.nhaBe;
    final otherCampusLatLng = LatLng(otherCampus.latitude, otherCampus.longitude);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E3DF),
        border: Border.all(color: Colors.black87, width: 1.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Stack(
          children: [
            // Bản đồ OpenStreetMap / OSRM sắc nét, miễn phí, không cần Google API Key
            FlutterMap(
              mapController: mapController.mapController,
              options: MapOptions(
                initialCenter: campusLatLng,
                initialZoom: 14.5,
                minZoom: 5.0,
                maxZoom: 18.5,
              ),
              children: [
                // 1. Tầng bản đồ đường phố OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_application_1',
                ),

                // 2. Tuyến đường OSRM Polyline thực tế
                if (route != null && route.polylinePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route.polylinePoints,
                        strokeWidth: 5.0,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),

                // 3. Các điểm ghim Marker
                MarkerLayer(
                  markers: [
                    // Marker cơ sở đang chọn (Đỏ)
                    Marker(
                      point: campusLatLng,
                      width: 50,
                      height: 50,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              selectedCampus.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.location_on, color: Colors.red, size: 28),
                        ],
                      ),
                    ),

                    // Marker cơ sở còn lại (Cam)
                    Marker(
                      point: otherCampusLatLng,
                      width: 50,
                      height: 50,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade800,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              otherCampus.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.location_on, color: Colors.orange, size: 28),
                        ],
                      ),
                    ),

                    // Marker vị trí hiện tại của sinh viên (Xanh Dương)
                    Marker(
                      point: mapController.currentLocation,
                      width: 44,
                      height: 44,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'Bạn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.my_location, color: Colors.blueAccent, size: 22),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Card thông tin chỉ đường OSRM trên đỉnh bản đồ
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Cơ sở: ${selectedCampus.name}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (mapController.isLoadingRoute) ...[
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(strokeWidth: 1.5),
                                ),
                                const SizedBox(width: 4),
                              ],
                              const Text(
                                'Bản Đồ & OSRM Polyline',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selectedCampus.address,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (route != null && route.distanceMeters > 0) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.directions_car, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'Lộ trình OSRM: ${route.distanceKm} km (ước tính ~${route.durationMinutes} phút)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Nút điều khiển Zoom & Định vị nhanh góc phải dưới
            Positioned(
              bottom: 8,
              right: 8,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'btn_zoom_in',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    onPressed: () {
                      final currentZoom = mapController.mapController.camera.zoom;
                      mapController.moveCameraTo(
                        mapController.mapController.camera.center,
                        zoom: currentZoom + 1,
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 4),
                  FloatingActionButton.small(
                    heroTag: 'btn_zoom_out',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    onPressed: () {
                      final currentZoom = mapController.mapController.camera.zoom;
                      mapController.moveCameraTo(
                        mapController.mapController.camera.center,
                        zoom: currentZoom - 1,
                      );
                    },
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

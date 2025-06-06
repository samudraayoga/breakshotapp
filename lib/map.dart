import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSection extends StatelessWidget {
  final LatLng center;
  final LatLng? currentPosition;
  final MapController mapController;
  final double currentZoom;
  final bool gettingLocation;
  final VoidCallback onGetCurrentLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapSection({
    super.key,
    required this.center,
    required this.currentPosition,
    required this.mapController,
    required this.currentZoom,
    required this.gettingLocation,
    required this.onGetCurrentLocation,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: currentZoom,
            onPositionChanged: (position, hasGesture) {},
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                // Marker lokasi user (dinamis)
                if (currentPosition != null)
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: currentPosition!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.my_location, color: Colors.white, size: 44),
                        Text('Lokasi Anda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                      ],
                    ),
                  ),
                // Marker default center jika user belum ada lokasi
                if (currentPosition == null)
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.location_on, color: Colors.white, size: 44),
                        Text('Seturan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                      ],
                    ),
                  ),
                // Marker statis rumah billiard 1
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: LatLng(-7.765072296340974, 110.41447984627699),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_bar, color: Colors.green, size: 36),
                      const Text('Amora Billiard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ],
                  ),
                ),
                // Marker statis rumah billiard 2
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: LatLng(-7.782719652107371, 110.38992681002497),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_bar, color: Colors.blue, size: 36),
                      const Text('Om Billiard Jogja', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ],
                  ),
                ),
                // Marker statis rumah billiard 3
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: LatLng(-7.78331392238846, 110.39055416955144),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_bar, color: Colors.red, size: 36),
                      const Text('Mille Billiard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ],
                  ),
                ),
                // Marker statis rumah billiard 4: Five Seven
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: LatLng(-7.770281152797553, 110.40488150682984),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_bar, color: Colors.orange, size: 36),
                      const Text('Five Seven', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ],
                  ),
                ),
                // Marker statis rumah billiard 5: Simple Chapter 07
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: LatLng(-7.774830907152643, 110.40393736945487),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_bar, color: Colors.purple, size: 36),
                      const Text('Simple Chapter 07', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ],
                  ),
                ),
                // Marker statis rumah billiard 6: The Gardens
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: LatLng(-7.772449733457909, 110.40844348051856),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_bar, color: Colors.teal, size: 36),
                      const Text('The Gardens', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ],
                  ),
                ),
                // Marker statis rumah billiard 7: Zon Billiard
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: LatLng(-7.773215112242821, 110.41007426371505),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_bar, color: Colors.yellow, size: 36),
                      const Text('Zon Billiard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        if (gettingLocation)
          const Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Mencari lokasi terkini...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 24,
          right: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'zoom_in',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: onZoomIn,
                tooltip: 'Zoom In',
                child: const Icon(Icons.add, color: Color.fromARGB(255, 46, 204, 113)),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: onZoomOut,
                tooltip: 'Zoom Out',
                child: const Icon(Icons.remove, color: Color.fromARGB(255, 46, 204, 113)),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'my_location',
                backgroundColor: Colors.grey,
                onPressed: onGetCurrentLocation,
                tooltip: 'Refresh Lokasi',
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

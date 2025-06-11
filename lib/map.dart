import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSection extends StatefulWidget {
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
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  LatLng? _destination;

  void _showKunjungiDialog(String name, LatLng point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: const Text('Ingin mengunjungi lokasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _destination = point;
              });
              widget.mapController.move(point, widget.currentZoom);
              Navigator.of(context).pop();
            },
            child: const Text('Kunjungi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> billiardMarkers = [
      {
        'name': 'Amora Billiard',
        'point': LatLng(-7.765072296340974, 110.41447984627699),
        'color': Colors.green,
      },
      {
        'name': 'Om Billiard Jogja',
        'point': LatLng(-7.782719652107371, 110.38992681002497),
        'color': Colors.blue,
      },
      {
        'name': 'Mille Billiard',
        'point': LatLng(-7.78331392238846, 110.39055416955144),
        'color': Colors.red,
      },
      {
        'name': 'Five Seven',
        'point': LatLng(-7.770281152797553, 110.40488150682984),
        'color': Colors.orange,
      },
      {
        'name': 'Simple Chapter 07',
        'point': LatLng(-7.774830907152643, 110.40393736945487),
        'color': Colors.purple,
      },
      {
        'name': 'The Gardens',
        'point': LatLng(-7.772449733457909, 110.40844348051856),
        'color': Colors.teal,
      },
      {
        'name': 'Zon Billiard',
        'point': LatLng(-7.773215112242821, 110.41007426371505),
        'color': Colors.yellow,
      },
    ];
    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: widget.currentZoom,
            onPositionChanged: (position, hasGesture) {},
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            if (widget.currentPosition != null && _destination != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [widget.currentPosition!, _destination!],
                    color: Colors.blueAccent,
                    strokeWidth: 5,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (widget.currentPosition != null)
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: widget.currentPosition!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.my_location, color: Colors.white, size: 44),
                        Text('Lokasi Anda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                      ],
                    ),
                  ),
                if (widget.currentPosition == null)
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: widget.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.location_on, color: Colors.white, size: 44),
                        Text('Seturan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                      ],
                    ),
                  ),
                // Marker statis rumah billiard interaktif
                ...billiardMarkers.map((marker) => Marker(
                  width: 60.0,
                  height: 60.0,
                  point: marker['point'],
                  child: GestureDetector(
                    onTap: () => _showKunjungiDialog(marker['name'], marker['point']),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sports_bar, color: marker['color'], size: 36),
                        Text(marker['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, offset: Offset(1,1), blurRadius: 4)])),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ],
        ),
        if (widget.gettingLocation)
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
                backgroundColor: Colors.white, // Warna tombol zoom in/out (putih)
                onPressed: widget.onZoomIn,
                tooltip: 'Zoom In',
                child: const Icon(Icons.add, color: Color.fromARGB(255, 46, 204, 113)),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                backgroundColor: Colors.white, // Warna tombol zoom in/out (putih)
                onPressed: widget.onZoomOut,
                tooltip: 'Zoom Out',
                child: const Icon(Icons.remove, color: Color.fromARGB(255, 46, 204, 113)),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'my_location',
                backgroundColor: Colors.grey, // Warna tombol lokasi (abu-abu)
                onPressed: widget.onGetCurrentLocation,
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

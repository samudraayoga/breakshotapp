import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../map.dart';

class MapContent extends StatelessWidget {
  final LatLng center;
  final LatLng? currentPosition;
  final MapController mapController;
  final double currentZoom;
  final bool gettingLocation;
  final VoidCallback onGetCurrentLocation;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapContent({
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
    return MapSection(
      center: center,
      currentPosition: currentPosition,
      mapController: mapController,
      currentZoom: currentZoom,
      gettingLocation: gettingLocation,
      onGetCurrentLocation: onGetCurrentLocation,
      onZoomIn: onZoomIn,
      onZoomOut: onZoomOut,
    );
  }
}

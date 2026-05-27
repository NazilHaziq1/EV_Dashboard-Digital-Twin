import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class RangeMap extends StatefulWidget {
  final double predictedRange;

  const RangeMap({super.key, required this.predictedRange});

  @override
  State<RangeMap> createState() => _RangeMapState();
}

class _RangeMapState extends State<RangeMap> {
  // Default to Kuala Lumpur until GPS is fetched
  LatLng _currentLocation = const LatLng(3.1390, 101.6869);
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Get an initial rapid position
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentLocation, 8.0);
      }
    } catch (e) {
      debugPrint("Could not fetch initial location: $e");
    }

    // Subscribe to live location stream
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100, // Notify only when device moves 100m
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(position.latitude, position.longitude);
            });
            // Optionally recenter map slowly
            _mapController.move(_currentLocation, _mapController.camera.zoom);
          }
        });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // predictedRange is in km, so we need to multiply by 1000.
    final radiusInMeters = widget.predictedRange * 1000.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 8.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.ev_dashboard',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentLocation,
                      color: Colors.cyanAccent.withOpacity(0.2),
                      borderColor: Colors.cyanAccent,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: radiusInMeters,
                    ),
                    // Center dot marking exact location
                    CircleMarker(
                      point: _currentLocation,
                      color: Colors.redAccent,
                      radius: 5, // pixels
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'Live Range tracking',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

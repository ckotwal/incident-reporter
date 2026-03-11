import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocationMap({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition = LatLng(latitude, longitude);
    return SizedBox(
      height: 250,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('incidentLocation'),
            position: initialPosition,
          ),
        },
      ),
    );
  }
}

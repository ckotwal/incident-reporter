
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incident_reporter/models/incident.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:incident_reporter/services/location_service.dart';
import 'package:incident_reporter/screens/image_detail_screen.dart';
import 'package:intl/intl.dart';

class NearbyIncidentsScreen extends StatefulWidget {
  const NearbyIncidentsScreen({super.key});

  @override
  State<NearbyIncidentsScreen> createState() => _NearbyIncidentsScreenState();
}

class _NearbyIncidentsScreenState extends State<NearbyIncidentsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();

  late DateTime _fromDate;
  late DateTime _toDate;
  double _radius = 3.0;
  bool _useMockLocation = true;
  List<Incident> _incidents = [];
  final LatLng _puneLocation = const LatLng(18.5207, 73.8554);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(const Duration(days: 30));
  }

  Future<void> _searchIncidents() async {
    LatLng center;
    if (_useMockLocation) {
      center = _puneLocation;
    } else {
      try {
        final position = await _locationService.getCurrentLocation();
        center = LatLng(position.latitude, position.longitude);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get current location: $e')),
        );
        return;
      }
    }

    final geoPointCenter = GeoPoint(center.latitude, center.longitude);

    _firestoreService
        .getNearbyIncidentsByDateRange(
      center: geoPointCenter,
      radiusInKm: _radius,
      from: _fromDate,
      to: _toDate,
    )
        .listen((incidents) {
      setState(() {
        _incidents = incidents;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(center));
    });
  }

  Set<Marker> _createMarkers() {
    return _incidents.map((incident) {
      final geoPoint = incident.location['geopoint'] as GeoPoint;
      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        infoWindow: InfoWindow(
          title: incident.address,
          snippet: 'Tap to see image',
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageDetailScreen(imageUrl: incident.imageUrl),
            ),
          );
        },
      );
    }).toSet();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isFromDate ? _fromDate : _toDate)) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Incidents'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text('From: ${DateFormat.yMd().format(_fromDate)}'),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text('To: ${DateFormat.yMd().format(_toDate)}'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Radius (km):'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: _radius.toString()),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          _radius = double.tryParse(value) ?? _radius;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _useMockLocation,
                      onChanged: (bool? value) {
                        setState(() {
                          _useMockLocation = value ?? true;
                        });
                      },
                    ),
                    const Text('Use Mock Location (Pune)'),
                  ],
                ),
                ElevatedButton(
                  onPressed: _searchIncidents,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _puneLocation,
                zoom: 12,
              ),
              markers: _createMarkers(),
            ),
          ),
        ],
      ),
    );
  }
}

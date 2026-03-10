
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class Incident {
  final String? id;
  final String title;
  final String description;
  final GeoFirePoint geo;
  final String? imageUrl;
  final Timestamp timestamp;
  final String? address;

  Incident({
    this.id,
    required this.title,
    required this.description,
    required this.geo,
    this.imageUrl,
    required this.timestamp,
    this.address,
  });

  factory Incident.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['geo']['geopoint'] as GeoPoint;
    return Incident(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      geo: GeoFirePoint(geoPoint),
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      address: data['address'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'geo': geo.data,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'address': address,
    };
  }

  String get location => address ?? 'Lat: ${geo.latitude.toStringAsFixed(5)}, Lng: ${geo.longitude.toStringAsFixed(5)}';
}

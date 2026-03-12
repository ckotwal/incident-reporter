
import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String description;
  final String imageUrl;
  final Timestamp timestamp;
  final String address;
  final Map<String, dynamic> location;

  Incident({
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.address,
    required this.location,
  });

  GeoPoint get geopoint => location['geopoint'];

  factory Incident.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Incident(
      id: doc.id,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      address: data['address'] ?? '',
      location: data['location'] ?? {},
    );
  }
}

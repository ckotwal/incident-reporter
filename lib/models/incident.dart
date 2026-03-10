import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final Timestamp timestamp;

  Incident({
    required this.id,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  factory Incident.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Incident(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      address: data['address'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

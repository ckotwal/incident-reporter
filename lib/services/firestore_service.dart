
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:incident_reporter/models/incident.dart';

class FirestoreService {
  final CollectionReference _incidentsRef = FirebaseFirestore.instance.collection('incidents');

  Future<void> addIncident({
    required String description,
    required String imageUrl,
    required double latitude,
    required double longitude,
    required String address,
    required Timestamp timestamp,
  }) {
    final point = GeoFirePoint(GeoPoint(latitude, longitude));
    return _incidentsRef.add({
      'description': description,
      'imageUrl': imageUrl,
      'address': address,
      'timestamp': timestamp,
      'location': point.data,
    });
  }

  Stream<List<Incident>> getRecentIncidents() {
    return _incidentsRef
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Incident.fromFirestore(doc)).toList();
    });
  }

  Future<List<Incident>> searchIncidentsByDateRange(DateTime from, DateTime to) {
    final endOfDay = DateTime(to.year, to.month, to.day, 23, 59, 59);

    return _incidentsRef
        .where('timestamp', isGreaterThanOrEqualTo: from)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .orderBy('timestamp', descending: true)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => Incident.fromFirestore(doc)).toList());
  }

  Stream<List<Incident>> getNearbyIncidents({required GeoPoint center, required double radiusInKm}) {
    final collectionReference = _incidentsRef as CollectionReference<Map<String, dynamic>>;
    final geoCollection = GeoCollectionReference<Map<String, dynamic>>(collectionReference);
    return geoCollection.subscribeWithin(
      center: GeoFirePoint(center),
      radiusInKm: radiusInKm,
      field: 'location',
      strictMode: true,
      geopointFrom: (data) => (data['location'] as Map<String, dynamic>)['geopoint'],
    ).map((snapshot) => snapshot.map((doc) => Incident.fromFirestore(doc)).toList());
  }

  Stream<List<Incident>> getNearbyIncidentsByDateRange({
    required GeoPoint center,
    required double radiusInKm,
    required DateTime from,
    required DateTime to,
  }) {
    return getNearbyIncidents(center: center, radiusInKm: radiusInKm).map((incidents) {
      return incidents.where((incident) {
        final incidentDate = incident.timestamp.toDate();
        return incidentDate.isAfter(from) && incidentDate.isBefore(to);
      }).toList();
    });
  }

  Stream<List<Incident>> getIncidents() {
    return _incidentsRef
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Incident.fromFirestore(doc)).toList();
    });
  }

  Stream<Incident> getIncidentById(String id) {
    return _incidentsRef.doc(id).snapshots().map((snapshot) => Incident.fromFirestore(snapshot));
  }
}

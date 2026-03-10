
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../models/incident_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference<Incident> _incidentsRef;

  FirestoreService() {
    _incidentsRef = _db.collection('incidents').withConverter<Incident>(
          fromFirestore: (snapshot, _) => Incident.fromFirestore(snapshot),
          toFirestore: (incident, _) => incident.toFirestore(),
        );
  }

  /// Get a stream of the latest 10 incidents, ordered by timestamp
  Stream<List<Incident>> getIncidents() {
    return _incidentsRef
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get a stream of incidents within a specific radius of a center point.
  Stream<List<Incident>> getNearbyIncidents({
    required GeoPoint center,
    required double radiusInKm,
  }) {
    // Note: Queries on 'geo' field require a composite index in Firestore.
    // The AI will prompt to create this if it detects a permission error.
    return GeoCollectionRef<Incident>(_incidentsRef).within(
      center: GeoFirePoint(center),
      radius: radiusInKm,
      field: 'geo',
      strictMode: true, // Ensures the query is as accurate as possible
    ).map((docs) => docs.map((doc) => doc.data()).toList());
  }

  /// Get a single incident by its ID
  Stream<Incident> getIncidentById(String id) {
    return _incidentsRef
        .doc(id)
        .snapshots()
        .map((snapshot) {
          final incident = snapshot.data();
          if (incident == null) {
            throw Exception('Incident not found!');
          }
          return incident;
        });
  }

  /// Add a new incident to Firestore
  Future<DocumentReference<Incident>> addIncident(Incident incident) {
    return _incidentsRef.add(incident);
  }

  /// Update an existing incident
  Future<void> updateIncident(String id, Incident incident) {
    return _incidentsRef.doc(id).update(incident.toFirestore());
  }

  /// Delete an incident
  Future<void> deleteIncident(String id) {
    return _incidentsRef.doc(id).delete();
  }
}

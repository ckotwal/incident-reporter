import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incident_reporter/models/incident.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  late final CollectionReference<Incident> _incidentsRef =
      _firestore.collection('incidents').withConverter<Incident>(
            fromFirestore: (snapshot, _) => Incident.fromFirestore(snapshot),
            toFirestore: (incident, _) => {
              'imageUrl': incident.imageUrl,
              'latitude': incident.latitude,
              'longitude': incident.longitude,
              'address': incident.address,
              'timestamp': incident.timestamp,
            },
          );

  CollectionReference<Incident> get incidentsRef => _incidentsRef;

  Future<void> addIncident(Incident incident) async {
    await _incidentsRef.add(incident);
  }

  Stream<List<Incident>> getIncidents() {
    return _incidentsRef
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Stream<Incident> getIncidentById(String id) {
    return _incidentsRef.doc(id).snapshots().map((snapshot) => snapshot.data()!);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incident_reporter/models/incident.dart';

class FirestoreService {
  final CollectionReference<Incident> _incidentsRef = FirebaseFirestore.instance
      .collection('incidents')
      .withConverter<Incident>(
        fromFirestore: (snapshot, _) => Incident.fromFirestore(snapshot),
        toFirestore: (incident, _) => incident.toFirestore(),
      );

  Future<void> addIncident(Incident incident) {
    return _incidentsRef.add(incident);
  }

  Stream<List<Incident>> getRecentIncidents() {
    return _incidentsRef
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<List<Incident>> searchIncidentsByDateRange(DateTime from, DateTime to) {
    // Ensure the 'to' date includes the entire day
    final endOfDay = DateTime(to.year, to.month, to.day, 23, 59, 59);

    return _incidentsRef
        .where('timestamp', isGreaterThanOrEqualTo: from)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .orderBy('timestamp', descending: true)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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

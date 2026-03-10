import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';

class IncidentsProvider with ChangeNotifier {
  List<Incident> _incidents = [];

  List<Incident> get incidents => _incidents;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Incident> _incidentsRef = _firestore
      .collection('incidents')
      .withConverter<Incident>(
          fromFirestore: (snapshot, _) => Incident.fromFirestore(snapshot),
          toFirestore: (incident, _) => incident.toFirestore());

  Future<void> fetchIncidents() async {
    try {
      final querySnapshot = await _incidentsRef.orderBy('timestamp', descending: true).get();
      _incidents = querySnapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    } catch (e, s) {
      developer.log('Error fetching incidents', error: e, stackTrace: s);
    }
  }
}

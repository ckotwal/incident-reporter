import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';

class IncidentsProvider with ChangeNotifier {
  List<Incident> _incidents = [];

  List<Incident> get incidents => _incidents;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchIncidents() async {
    try {
      final querySnapshot = await _firestore
          .collection('incidents')
          .orderBy('timestamp', descending: true)
          .get();
      _incidents = querySnapshot.docs
          .map((doc) => Incident.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching incidents: $e');
    }
  }
}

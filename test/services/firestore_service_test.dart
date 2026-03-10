import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/incident.dart';
import 'package:myapp/services/firestore_service.dart';

void main() {
  group('FirestoreService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService firestoreService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: fakeFirestore);
    });

    test('should add and get incidents', () async {
      // Arrange
      final incident = Incident(
        id: 'test',
        imageUrl: 'image_url',
        latitude: 1.0,
        longitude: 1.0,
        address: '123 Test St',
        timestamp: Timestamp.now(),
      );

      // Act
      await firestoreService.addIncident(incident);
      final incidentsStream = firestoreService.getIncidents();

      // Assert
      expectLater(
        incidentsStream,
        emits(
          isA<List<Incident>>()
              .having((list) => list.length, 'length', 1)
              .having((list) => list.first.address, 'address', '123 Test St'),
        ),
      );
    });

    test('getIncidents should return a list limited to 10 incidents', () async {
      // Arrange
      for (int i = 0; i < 15; i++) {
        await fakeFirestore.collection('incidents').add({
          'imageUrl': 'image_url_$i',
          'latitude': 1.0,
          'longitude': 1.0,
          'address': 'Address $i',
          'timestamp': Timestamp.fromMillisecondsSinceEpoch(i * 1000),
        });
      }

      // Act
      final incidentsStream = firestoreService.getIncidents();

      // Assert
      expectLater(
        incidentsStream,
        emits(isA<List<Incident>>()..having((list) => list.length, 'length', 10)),
      );
    });

    test('getIncidentById should return the correct incident', () async {
      // Arrange
      final docRef = await fakeFirestore.collection('incidents').add({
        'imageUrl': 'specific_image',
        'latitude': 2.0,
        'longitude': 2.0,
        'address': '456 Specific Ave',
        'timestamp': Timestamp.now(),
      });

      // Act
      final incidentStream = firestoreService.getIncidentById(docRef.id);
      await docRef.get();

      // Assert
      expectLater(
        incidentStream,
        emits(
          isA<Incident>()
              .having((i) => i.address, 'address', '456 Specific Ave')
              .having((i) => i.id, 'id', docRef.id),
        ),
      );
    });
  });
}

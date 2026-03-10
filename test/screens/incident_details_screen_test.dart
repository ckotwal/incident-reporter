import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:incident_reporter/models/incident.dart';
import 'package:incident_reporter/screens/incident_details_screen.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Incident Details Screen Widget Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    final now = DateTime.now();

    final testIncident = Incident(
      id: '1',
      timestamp: Timestamp.fromDate(now),
      latitude: 0.0,
      longitude: 0.0,
      address: 'Test Address',
      imageUrl: 'http://fake-url.com/image.jpg',
    );

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await fakeFirestore.collection('incidents').doc(testIncident.id).set({
        'timestamp': testIncident.timestamp,
        'latitude': testIncident.latitude,
        'longitude': testIncident.longitude,
        'address': testIncident.address,
        'imageUrl': testIncident.imageUrl,
      });
    });

    createTestApp(String incidentId) {
      final router = GoRouter(
        initialLocation: '/details/$incidentId',
        routes: [
          GoRoute(
            path: '/details/:id',
            builder: (context, state) =>
                IncidentDetailsScreen(incidentId: state.pathParameters['id']!),
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
        builder: (context, child) {
          return Provider<FirestoreService>(
            create: (_) => FirestoreService(firestore: fakeFirestore),
            child: child!,
          );
        },
      );
    }

    testWidgets('should display incident details', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestApp(testIncident.id));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining(testIncident.address), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); 
    });
  });
}

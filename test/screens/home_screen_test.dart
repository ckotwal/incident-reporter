import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:incident_reporter/models/incident.dart';
import 'package:incident_reporter/screens/capture_screen.dart';
import 'package:incident_reporter/screens/home_screen.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:incident_reporter/services/location_service.dart';
import 'package:incident_reporter/services/storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_services.dart';

void main() {
  group('Home Screen Widget Tests', () {
    final testIncident = Incident(
      id: '1',
      timestamp: Timestamp.now(),
      latitude: 0.0,
      longitude: 0.0,
      address: '123 Test St',
      imageUrl: 'http://fake-url.com/image.jpg',
    );

    Widget createTestApp(
      MockFirestoreService firestoreService,
      MockLocationService locationService,
      MockStorageService storageService,
    ) {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/capture',
            builder: (context, state) => const CaptureScreen(),
          ),
        ],
      );

      return MultiProvider(
        providers: [
          Provider<FirestoreService>.value(value: firestoreService),
          Provider<LocationService>.value(value: locationService),
          Provider<StorageService>.value(value: storageService),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('should display a list of incidents', (WidgetTester tester) async {
      // Arrange
      final mockFirestoreService = MockFirestoreService();
      final mockLocationService = MockLocationService();
      final mockStorageService = MockStorageService();
      final incidentsController = StreamController<List<Incident>>.broadcast();

      when(mockFirestoreService.getIncidents()).thenAnswer((_) => incidentsController.stream);

      await tester.pumpWidget(createTestApp(
        mockFirestoreService,
        mockLocationService,
        mockStorageService,
      ));

      // Act
      incidentsController.add([testIncident]);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('123 Test St'), findsOneWidget);
      
      await incidentsController.close();
    });

    testWidgets('should navigate to capture screen when FAB is tapped', (WidgetTester tester) async {
      // Arrange
      final mockFirestoreService = MockFirestoreService();
      final mockLocationService = MockLocationService();
      final mockStorageService = MockStorageService();
      final incidentsController = StreamController<List<Incident>>.broadcast();

      when(mockFirestoreService.getIncidents()).thenAnswer((_) => incidentsController.stream);
      
      await tester.pumpWidget(createTestApp(
        mockFirestoreService,
        mockLocationService,
        mockStorageService,
      ));
      
      incidentsController.add([]);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CaptureScreen), findsOneWidget);

      await incidentsController.close();
    });
  });
}

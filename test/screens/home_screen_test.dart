import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:incident_reporter/models/incident.dart';
import 'package:incident_reporter/screens/capture_screen.dart';
import 'package:incident_reporter/screens/home_screen.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_services.dart';

void main() {
  group('Home Screen Widget Tests', () {
    late MockFirestoreService mockFirestoreService;
    late StreamController<List<Incident>> incidentsController;

    final testIncident = Incident(
      id: '1',
      timestamp: Timestamp.now(),
      latitude: 0.0,
      longitude: 0.0,
      address: '123 Test St',
      imageUrl: 'http://fake-url.com/image.jpg',
    );

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      incidentsController = StreamController<List<Incident>>.broadcast();
      when(mockFirestoreService.getIncidents()).thenAnswer((_) => incidentsController.stream);
    });

    tearDown(() {
      incidentsController.close();
    });

    Widget createTestApp() {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/capture',
            builder: (context, state) => CaptureScreen(image: state.extra as XFile?),
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
        builder: (context, child) {
          return Provider<FirestoreService>.value(
            value: mockFirestoreService,
            child: child!,
          );
        },
      );
    }

    testWidgets('should display a list of incidents', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestApp());

      // Act
      incidentsController.add([testIncident]);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('123 Test St'), findsOneWidget);
    });

    testWidgets('should navigate to capture screen when FAB is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestApp());

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CaptureScreen), findsOneWidget);
    });
  });
}

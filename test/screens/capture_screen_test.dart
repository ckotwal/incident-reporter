import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:incident_reporter/screens/capture_screen.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_camera_controller.dart';
import '../mocks/mock_services.dart';

void main() {
  group('Capture Screen Widget Tests', () {
    late MockFirestoreService mockFirestoreService;
    late MockLocationService mockLocationService;
    late MockStorageService mockStorageService;
    late MockCameraController mockCameraController;

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      mockLocationService = MockLocationService();
      mockStorageService = MockStorageService();
      mockCameraController = MockCameraController();
    });

    Widget createTestApp() {
      final router = GoRouter(
        initialLocation: '/capture',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Text("Home")),
          GoRoute(
            path: '/capture',
            builder: (context, state) => const CaptureScreen(),
          ),
        ],
      );
      return MaterialApp.router(
        routerConfig: router,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              Provider<MockFirestoreService>.value(value: mockFirestoreService),
              Provider<MockLocationService>.value(value: mockLocationService),
              Provider<MockStorageService>.value(value: mockStorageService),
            ],
            child: child!,
          );
        },
      );
    }

    testWidgets('should show camera preview and allow taking a picture', (WidgetTester tester) async {
      // Arrange
      // You might need to mock the availableCameras() function to return a mock camera

      await tester.pumpWidget(createTestApp());

      // Act & Assert
      expect(find.byType(CameraPreview), findsOneWidget);
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // expect(find.byType(Image), findsOneWidget); // Assuming an Image widget is shown after taking a picture
    });
  });
}

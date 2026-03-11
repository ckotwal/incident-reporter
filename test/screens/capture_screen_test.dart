import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:incident_reporter/screens/capture_screen.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:incident_reporter/services/location_service.dart';
import 'package:incident_reporter/services/storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../mocks/mock_services.dart';

// 1. Mock the camera platform
class MockCameraPlatform extends Mock implements CameraPlatform {
  @override
  Future<List<CameraDescription>> availableCameras() async {
    return [
      const CameraDescription(
        name: 'cam0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
    ];
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    return 1; // Return a fake camera ID
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    // Simulate camera initialization
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return Stream.value(const CameraInitializedEvent(1, 1920, 1080,
        ExposureMode.auto, true, FocusMode.auto, true));
  }
  
  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return const Stream.empty();
  }

  @override
  Widget buildPreview(int cameraId) {
    // Return a simple widget as a placeholder for the camera preview
    return const SizedBox(
      width: 1920,
      height: 1080,
      child: Text('Camera Preview'),
    );
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    // Return an XFile with mock data
    return MockXFile();
  }
}

// 2. Mock XFile to prevent file system access
class MockXFile extends Mock implements XFile {
  @override
  Future<Uint8List> readAsBytes() async {
    // Return minimal valid image data (a 1x1 transparent PNG)
    return Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0,
      0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120,
      156, 99, 96, 0, 0, 0, 2, 0, 1, 195, 33, 237, 134, 0, 0, 0, 0, 73, 69, 78, 68,
      174, 66, 96, 130
    ]);
  }

  @override
  final String path = 'fake_path/fake_image.jpg';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Capture Screen Widget Tests', () {
    Widget createTestApp(
      MockFirestoreService firestoreService,
      MockLocationService locationService,
      MockStorageService storageService,
    ) {
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

    testWidgets('should show camera preview and allow taking a picture', (WidgetTester tester) async {
      // Arrange
      CameraPlatform.instance = MockCameraPlatform();
      final mockFirestore = MockFirestoreService();
      final mockLocation = MockLocationService();
      final mockStorage = MockStorageService();

      await tester.pumpWidget(createTestApp(mockFirestore, mockLocation, mockStorage));

      // Wait for camera to initialize by looking for the preview placeholder
      await tester.pumpAndSettle();

      // Assert: Camera preview is showing
      expect(find.text('Camera Preview'), findsOneWidget);

      // Act: Tap the capture button
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Assert: After taking a picture, an Image widget is displayed
      // and the retake and submit buttons are visible.
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}

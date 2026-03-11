import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
// This import is the critical fix for the compilation error.
import 'package:camera_platform_interface/src/types/types.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:incident_reporter/screens/capture_screen.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:incident_reporter/services/location_service.dart';
import 'package:incident_reporter/services/storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_services.dart';

class MockCameraPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements CameraPlatform {

  @override
  Future<int> createCameraWithSettings(CameraDescription cameraDescription, CameraSettings settings) {
    return Future.value(1);
  }

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
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {}

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return Stream.value(const CameraInitializedEvent(
        1, 1920, 1080, ExposureMode.auto, true, FocusMode.auto, true));
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return const Stream.empty();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return const Stream.empty();
  }

  @override
  Widget buildPreview(int cameraId) {
    return const SizedBox(
      width: 1920,
      height: 1080,
      child: Text('Camera Preview'),
    );
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    return MockXFile();
  }

  @override
  Future<void> dispose(int cameraId) async {}

  @override
  Future<void> lockCaptureOrientation(int cameraId, DeviceOrientation orientation) async {}

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) async {}

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) async {}

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {}
}

class MockXFile extends Mock implements XFile {
  @override
  Future<Uint8List> readAsBytes() async {
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

    setUp(() {
      CameraPlatform.instance = MockCameraPlatform();
    });

    testWidgets('should show camera preview and allow taking a picture',
        (WidgetTester tester) async {
      final mockFirestore = MockFirestoreService();
      final mockLocation = MockLocationService();
      final mockStorage = MockStorageService();

      await tester.pumpWidget(createTestApp(mockFirestore, mockLocation, mockStorage));

      await tester.pumpAndSettle();

      expect(find.text('Camera Preview'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}

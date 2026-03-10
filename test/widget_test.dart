import 'package:flutter_test/flutter_test.dart';
import 'package:incident_reporter/main.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:incident_reporter/services/location_service.dart';
import 'package:incident_reporter/services/storage_service.dart';

import 'mocks/mock_location_service.dart';
import 'mocks/mock_storage_service.dart';

void main() {
  testWidgets('Main app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<FirestoreService>(
          create: (_) => FirestoreService(firestore: FakeFirebaseFirestore()),
        ),
        Provider<LocationService>(
          create: (_) => MockLocationService(),
        ),
        Provider<StorageService>(
          create: (_) => MockStorageService(),
        ),
      ],
      child: const MyApp(),
    ));

    // Verify that our app shows the home screen with the correct title.
    expect(find.text('Incident Reporter'), findsOneWidget);
  });
}

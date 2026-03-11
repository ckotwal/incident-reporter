import 'package:incident_reporter/services/firestore_service.dart';
import 'package:incident_reporter/services/location_service.dart';
import 'package:incident_reporter/services/storage_service.dart';
import 'package:mockito/mockito.dart';

class MockFirestoreService extends Mock implements FirestoreService {}
class MockLocationService extends Mock implements LocationService {}
class MockStorageService extends Mock implements StorageService {}

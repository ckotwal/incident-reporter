import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/location_service.dart';
import 'package:myapp/services/storage_service.dart';
import 'package:mockito/mockito.dart';

class MockFirestoreService extends Mock implements FirestoreService {}
class MockLocationService extends Mock implements LocationService {}
class MockStorageService extends Mock implements StorageService {}

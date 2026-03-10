
import 'package:geolocator/geolocator.dart';
import 'package:incident_reporter/services/location_service.dart';
import 'package:mockito/mockito.dart';

class MockLocationService extends Mock implements LocationService {
  @override
  Future<Position> getCurrentPosition() =>
      super.noSuchMethod(Invocation.method(#getCurrentPosition, []),
          returnValue: Future.value(Position(
              latitude: 0, longitude: 0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0.0, headingAccuracy: 0.0)));
}

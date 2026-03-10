

import 'package:image_picker/image_picker.dart';
import 'package:incident_reporter/services/storage_service.dart';
import 'package:mockito/mockito.dart';

class MockStorageService extends Mock implements StorageService {
  @override
  Future<String> uploadImage(XFile image) =>
      super.noSuchMethod(Invocation.method(#uploadImage, [image]),
          returnValue: Future.value('http://fake-url.com/image.jpg'));
}

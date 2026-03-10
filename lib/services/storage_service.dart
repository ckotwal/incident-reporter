import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:camera/camera.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(XFile image) async {
    final storageRef = _storage.ref().child('images/${image.name}');
    final uploadTask = await storageRef.putFile(File(image.path));
    return await uploadTask.ref.getDownloadURL();
  }
}

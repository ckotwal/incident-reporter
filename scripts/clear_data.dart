import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:incident_reporter/firebase_options.dart';

// A script to wipe all data from the 'incidents' collection and the
// 'incident_images/' folder in Firebase Storage.
Future<void> main() async {
  // --- 1. SAFETY GUARDRAIL ---
  // This is a destructive script. We MUST get explicit confirmation.
  print('''
?? WARNING: This script will permanently delete all data from the 'incidents'
   collection and all images from the 'incident_images/' folder in Firebase Storage.

   This action cannot be undone.
''');
  stdout.write('?? To confirm, please type "DELETE": ');
  final confirmation = stdin.readLineSync();

  if (confirmation != 'DELETE') {
    print('\n?? Confirmation not received. Aborting data deletion.\n');
    exit(0);
  }

  print('\n?? Confirmation received. Proceeding with data deletion...');

  // --- 2. INITIALIZE FIREBASE ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  print('?? Firebase Initialized.');

  // --- 3. WIPE FIRESTORE COLLECTION ---
  print('?? Deleting all documents from the "incidents" collection...');
  final incidents = await firestore.collection('incidents').get();
  for (final doc in incidents.docs) {
    await doc.reference.delete();
    stdout.write('.');
  }
  print('\n?? All documents deleted from Firestore.');

  // --- 4. WIPE STORAGE FOLDER ---
  print('?? Deleting all files from the "incident_images/" folder in Storage...');
  try {
    final listResult = await storage.ref('incident_images').listAll();
    for (final item in listResult.items) {
      await item.delete();
      stdout.write('.');
    }
    print('\n?? All files deleted from Firebase Storage.');
  } catch (e) {
    // It's possible the folder doesn't exist, which is fine.
    print('\n?? Could not list files in Storage (the folder might be empty or not exist). $e');
  }

  print('\n??? Data cleanup complete!\n');
  exit(0);
}

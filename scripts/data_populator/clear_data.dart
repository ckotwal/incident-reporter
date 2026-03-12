
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// A script to wipe all data from the 'incidents' collection and the
// 'incident_images/' folder in Firebase Storage using REST APIs.
Future<void> main() async {
  // --- 1. SAFETY GUARDRAIL ---
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

  // --- 2. FIREBASE PROJECT CONFIGURATION ---
  const projectId = 'wires-489305';
  // CORRECTED: The storage bucket name was wrong. Updated to match google-services.json
  const storageBucket = 'wires-489305.firebasestorage.app';
  final firestoreUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  // --- 3. WIPE FIRESTORE COLLECTION ---
  print('?? Deleting all documents from the "incidents" collection...');
  try {
    final listResponse = await http.get(Uri.parse('$firestoreUrl/incidents'));
    if (listResponse.statusCode == 200) {
      final documents = jsonDecode(listResponse.body)['documents'];
      if (documents != null) {
        for (final doc in documents) {
          final docName = doc['name']; // The full resource name
          final deleteUrl = 'https://firestore.googleapis.com/v1/$docName';
          await http.delete(Uri.parse(deleteUrl));
          stdout.write('.');
        }
      }
    }
    print('\n?? All documents deleted from Firestore.');
  } catch (e) {
    print('\n?? ERROR during Firestore cleanup: $e');
  }

  // --- 4. WIPE STORAGE FOLDER ---
  print('?? Deleting all files from the "incident_images/" folder in Storage...');
  final storageListUrl = 'https://firebasestorage.googleapis.com/v0/b/$storageBucket/o?prefix=incident_images%2F';
  try {
    final listResponse = await http.get(Uri.parse(storageListUrl));
    if (listResponse.statusCode == 200) {
      final items = jsonDecode(listResponse.body)['items'];
      if (items != null) {
        for (final item in items) {
          final itemName = item['name']; // The full object path
          final deleteUrl = 'https://firebasestorage.googleapis.com/v0/b/$storageBucket/o/${Uri.encodeComponent(itemName)}';
          await http.delete(Uri.parse(deleteUrl));
          stdout.write('.');
        }
      }
    }
    print('\n?? All files deleted from Firebase Storage.');
  } catch (e) {
    print('\n?? ERROR during Storage cleanup (the folder might be empty or not exist). $e');
  }

  print('\n??? Data cleanup complete!\n');
  exit(0);
}

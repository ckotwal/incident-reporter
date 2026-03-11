import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:incident_reporter/firebase_options.dart';
import 'package:incident_reporter/models/incident.dart';
import 'package:random_string/random_string.dart';

// A script to populate the Firestore database with 10 random incidents.
Future<void> main() async {
  // --- 1. INITIALIZE FIREBASE ---
  // We need to initialize Firebase before we can use any of its services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  print('?? Firebase Initialized. Starting data population...');

  // --- 2. GENERATE 10 INCIDENTS ---
  for (int i = 0; i < 10; i++) {
    print('??‍?? Generating Incident ${i + 1}/10...');

    // --- 3. GENERATE RANDOM DATA ---

    // Generate random coordinates within the Pune area.
    final lat = 18.5 + Random().nextDouble() * 0.05; // 18.5 to 18.55
    final lon = 73.8 + Random().nextDouble() * 0.1; // 73.8 to 73.9

    // Reverse geocode to get a real address.
    // This can sometimes fail, so we have a fallback.
    String address = 'Pune Area, Maharashtra, India';
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = '${p.name}, ${p.locality}, ${p.administrativeArea}';
      }
    } catch (e) {
      print('?? Could not get address for ($lat, $lon). Using default.');
    }

    // Generate a random date within the last 10 days.
    final timestamp = Timestamp.fromDate(
      DateTime.now().subtract(Duration(days: Random().nextInt(10))),
    );

    // --- 4. FETCH AND UPLOAD IMAGE ---

    // Download a random image from a placeholder service.
    final imageUrl = 'https://picsum.photos/seed/${randomAlphaNumeric(8)}/800/600';
    final response = await http.get(Uri.parse(imageUrl));
    final imageBytes = response.bodyBytes;

    // Create a unique filename for the image.
    final imageName = '${randomAlphaNumeric(16)}.jpg';
    final ref = storage.ref('incident_images/$imageName');

    // Upload the image to Firebase Storage.
    await ref.putData(imageBytes);
    final downloadUrl = await ref.getDownloadURL();

    print('  ?? Image uploaded to: $downloadUrl');

    // --- 5. CREATE FIRESTORE DOCUMENT ---

    // Create an Incident object.
    // Note: We leave the 'id' field empty because Firestore will generate it.
    final newIncident = Incident(
      id: '', // Firestore will auto-generate this.
      imageUrl: downloadUrl,
      latitude: lat,
      longitude: lon,
      address: address,
      timestamp: timestamp,
    );

    // Add the new incident to the 'incidents' collection.
    await firestore.collection('incidents').add(newIncident.toFirestore());

    print('  ?? Incident ${i + 1} created successfully!');
  }

  print('\n??? All 10 incidents have been created successfully!\n');
  // We must exit explicitly because the script otherwise hangs.
  exit(0);
}

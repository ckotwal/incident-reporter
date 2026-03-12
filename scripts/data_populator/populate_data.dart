
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:dart_geohash/dart_geohash.dart';

// A script to populate the Firestore database with 10 random incidents using REST APIs.
Future<void> main() async {
  // --- 1. FIREBASE PROJECT CONFIGURATION ---
  const projectId = 'wires-489305';
  const storageBucket = 'wires-489305.firebasestorage.app';

  final firestoreUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/incidents';

  print('?? Starting data population via REST API...');

  final addresses = [
    'FC Road, Deccan Gymkhana',
    'MG Road, Camp',
    'Koregaon Park',
    'Viman Nagar',
    'Hinjewadi',
    'Aundh',
    'Baner',
    'Kothrud',
    'Wakad',
    'Pimple Saudagar',
  ];

  final geoHasher = GeoHasher();
  final headers = {'Content-Type': 'application/json'};

  // --- Get gcloud access token ---
  final ProcessResult result = await Process.run('gcloud', ['auth', 'print-access-token']);
  if (result.exitCode != 0) {
    print('?? Error getting gcloud auth token: ${result.stderr}');
    exit(1);
  }
  final accessToken = result.stdout.toString().trim();


  for (int i = 0; i < 2; i++) {
    print('??‍?? Generating Incident ${i + 1}/10...');

    // --- 2. GENERATE INCIDENT DATA ---
    final lat = 18.5 + Random().nextDouble() * 0.1;
    final lon = 73.8 + Random().nextDouble() * 0.1;
    final address = addresses[Random().nextInt(addresses.length)];
    final timestamp = DateTime.now()
        .toUtc()
        .subtract(Duration(days: Random().nextInt(10)))
        .toIso8601String();

    // --- 3. FETCH, UPLOAD IMAGE, AND CREATE DOWNLOAD TOKEN ---
    String publicImageUrl;
    try {
      final imageUrl = 'https://picsum.photos/seed/${randomAlphaNumeric(8)}/800/600';
      final imageResponse = await http.get(Uri.parse(imageUrl));
      final imageBytes = imageResponse.bodyBytes;
      final imageName = 'incident_images/${randomAlphaNumeric(16)}.jpg';

      final uploadUrl =
          'https://storage.googleapis.com/upload/storage/v1/b/$storageBucket/o?uploadType=media&name=$imageName';

      final uploadResponse = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': 'image/jpeg',
          'Authorization': 'Bearer $accessToken',
        },
        body: imageBytes,
      );

      if (uploadResponse.statusCode != 200) {
        print('?? Error uploading image: ${uploadResponse.body}');
        continue;
      }
      
      // Generate a download token and attach it to the image metadata
      final downloadToken = randomAlphaNumeric(36);
      final encodedImageName = Uri.encodeComponent(imageName);

      final patchUrl = 'https://storage.googleapis.com/storage/v1/b/$storageBucket/o/$encodedImageName';
      final patchBody = jsonEncode({
        'metadata': {
          'firebaseStorageDownloadTokens': downloadToken,
        }
      });

      final patchResponse = await http.patch(
        Uri.parse(patchUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: patchBody,
      );

      if (patchResponse.statusCode != 200) {
        print('?? Error setting image metadata: ${patchResponse.body}');
        continue;
      }

      // Construct the public URL with the token
      publicImageUrl =
          'https://firebasestorage.googleapis.com/v0/b/$storageBucket/o/$encodedImageName?alt=media&token=$downloadToken';

    } catch (e) {
      print('?? Error fetching/uploading image: $e');
      continue;
    }

    // --- 4. CALCULATE GEOHASH AND CONSTRUCT PAYLOAD ---
    final geohash = geoHasher.encode(lon, lat);

    final payload = {
      'fields': {
        'address': {'stringValue': address},
        'timestamp': {'timestampValue': timestamp},
        'imageUrl': {'stringValue': publicImageUrl},
        'description': {'stringValue': 'A randomly generated incident report.'},
        'location': {
          'mapValue': {
            'fields': {
              'geohash': {'stringValue': geohash},
              'geopoint': {
                'geoPointValue': {'latitude': lat, 'longitude': lon}
              }
            }
          }
        }
      }
    };

    // --- 5. CREATE FIRESTORE DOCUMENT ---
    try {
      final response = await http.post(
        Uri.parse(firestoreUrl),
        headers: {
          'Content-Type': 'application/json',
           'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        print('???? Incident ${i + 1} created successfully.');
      } else {
        print(
            '?? Error creating incident ${i + 1}: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('?? An exception occurred while creating incident ${i + 1}: $e');
    }
  }
  print('\n??? All 10 incidents have been processed!\n');
  exit(0);
}

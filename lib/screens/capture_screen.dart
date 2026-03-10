import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:incident_reporter/models/incident.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:incident_reporter/services/location_service.dart';
import 'package:incident_reporter/services/storage_service.dart';
import 'package:provider/provider.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _cameraController;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    final image = await _cameraController!.takePicture();
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _submitIncident() async {
    if (_imageFile == null) return;

    final locationService = Provider.of<LocationService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    try {
      final position = await locationService.getCurrentPosition();
      final address = await locationService.getAddressFromPosition(position);
      final imageUrl = await storageService.uploadImage(_imageFile!);

      final newIncident = Incident(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        imageUrl: imageUrl,
        timestamp: Timestamp.fromDate(DateTime.now()), // Corrected this line
      );

      await firestoreService.addIncident(newIncident);

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      // Handle errors appropriately
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: _imageFile == null ? _buildCameraPreview() : _buildImageConfirmation(),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Expanded(
          child: CameraPreview(_cameraController!),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(
            onPressed: _takePicture,
            child: const Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }

  Widget _buildImageConfirmation() {
    return Column(
      children: [
        Expanded(
          child: Image.file(File(_imageFile!.path)),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () => setState(() => _imageFile = null),
                child: const Icon(Icons.close),
              ),
              FloatingActionButton(
                onPressed: _submitIncident,
                child: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

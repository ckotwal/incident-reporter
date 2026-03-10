
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

import '../models/incident_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _image;
  bool _isUploading = false;
  String _title = '';
  String _description = '';

  Future<void> _getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _retakeImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _uploadIncident() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please take a picture.')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        final locationService = Provider.of<LocationService>(context, listen: false);
        final storageService = Provider.of<StorageService>(context, listen: false);
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);

        final position = await locationService.getCurrentPosition();
        final imageUrl = await storageService.uploadImage(_image!);

        final newIncident = Incident(
          title: _title,
          description: _description,
          geo: GeoFirePoint(GeoPoint(position.latitude, position.longitude)),
          imageUrl: imageUrl,
          timestamp: Timestamp.now(),
        );

        await firestoreService.addIncident(newIncident);

        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload incident: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Incident'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_isUploading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Uploading Incident...'),
                  ],
                )
              else
                _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _image == null
            ? _buildImagePicker()
            : _buildImagePreview(),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
          onSaved: (value) => _title = value!,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onSaved: (value) => _description = value!,
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: _uploadIncident,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Submit Report'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        const Icon(Icons.camera_enhance_rounded, size: 100, color: Colors.grey),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _getImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Picture'),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: kIsWeb
              ? Image.network(_image!.path, fit: BoxFit.cover, height: 250)
              : Image.file(File(_image!.path), fit: BoxFit.cover, height: 250),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _retakeImage,
          icon: const Icon(Icons.refresh),
          label: const Text('Retake Picture'),
        ),
      ],
    );
  }
}

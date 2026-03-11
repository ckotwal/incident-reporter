import 'package:flutter/material.dart';
import 'package:incident_reporter/models/incident.dart';

class ImageDetailScreen extends StatelessWidget {
  final Incident incident;
  const ImageDetailScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Image'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Image.network(
            incident.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red, size: 50),
          ),
        ),
      ),
    );
  }
}

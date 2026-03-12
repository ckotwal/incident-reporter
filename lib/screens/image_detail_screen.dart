import 'package:cached_network_image/cached_network_image.dart';
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
          child: CachedNetworkImage(
            imageUrl: incident.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.red, size: 50),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

class NearbyIncidentsScreen extends StatelessWidget {
  const NearbyIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Incidents'),
      ),
      body: const Center(
        child: Text('Nearby Incidents Screen'),
      ),
    );
  }
}

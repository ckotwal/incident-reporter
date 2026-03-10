
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/incident_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Reporter'),
      ),
      body: StreamBuilder<List<Incident>>(
        stream: firestoreService.getIncidents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final incidents = snapshot.data ?? [];

          if (incidents.isEmpty) {
            return const Center(child: Text('No incidents reported yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              final timeAgo = timeago.format(incident.timestamp.toDate());

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.report_problem, color: Colors.amber, size: 40),
                  title: Text(incident.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Reported $timeAgo at ${incident.location}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.go('/incident/${incident.id}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/capture'),
        tooltip: 'Report a New Incident',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:incident_reporter/models/incident.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<List<Incident>>? _incidentsStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    if (mounted) {
      setState(() {
        _incidentsStream = firestoreService.getIncidents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Reporter'),
      ),
      body: StreamBuilder<List<Incident>>(
        stream: _incidentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No incidents reported yet.'));
          }
          final incidents = snapshot.data!;
          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              final reportedAt = timeago.format(incident.timestamp.toDate());
              final truncatedAddress = incident.address.length > 10
                  ? '${incident.address.substring(0, 10)}...'
                  : incident.address;
              return ListTile(
                title: Text(truncatedAddress),
                subtitle: Text('Reported $reportedAt'),
                onTap: () => context.go('/details/${incident.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/capture'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

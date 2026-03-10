import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/incidents_provider.dart';
import 'incident_detail_screen.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});

  @override
  _IncidentListScreenState createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch incidents when the screen is initialized
    Provider.of<IncidentsProvider>(context, listen: false).fetchIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incidents')),
      body: Consumer<IncidentsProvider>(
        builder: (context, provider, child) {
          if (provider.incidents.isEmpty) {
            return const Center(child: Text('No incidents reported yet.'));
          } else {
            return ListView.builder(
              itemCount: provider.incidents.length,
              itemBuilder: (context, index) {
                final incident = provider.incidents[index];
                return ListTile(
                  leading: Hero(
                    tag: incident.id,
                    child: Image.network(
                      incident.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(incident.address),
                  subtitle: Text(incident.timestamp.toDate().toString()),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            IncidentDetailScreen(incident: incident),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

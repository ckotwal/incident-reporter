import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:incident_reporter/models/incident.dart';
import 'package:incident_reporter/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum OutputFormat { map, list }

class SearchIncidentsScreen extends StatefulWidget {
  const SearchIncidentsScreen({super.key});

  @override
  State<SearchIncidentsScreen> createState() => _SearchIncidentsScreenState();
}

class _SearchIncidentsScreenState extends State<SearchIncidentsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  OutputFormat _outputFormat = OutputFormat.map;
  bool _isLoading = false;
  List<Incident> _searchResults = [];
  bool _searchPerformed = false;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  static const LatLng _puneLocation = LatLng(18.5207, 73.8554);

  @override
  void initState() {
    super.initState();
    _setToDate(DateTime.now());
    _setFromDate(DateTime.now().subtract(const Duration(days: 30)));
  }

  void _setFromDate(DateTime date) {
    setState(() {
      _fromDate = date;
      _fromController.text = DateFormat.yMd().format(date);
    });
  }

  void _setToDate(DateTime date) {
    setState(() {
      _toDate = date;
      _toController.text = DateFormat.yMd().format(date);
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFromDate ? _fromDate : _toDate) ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      if (isFromDate) {
        _setFromDate(picked);
      } else {
        _setToDate(picked);
      }
    }
  }

  Future<void> _performSearch() async {
    if (_fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both a "from" and "to" date.')),
      );
      return;
    }
    if (_fromDate!.isAfter(_toDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('"From" date cannot be after "To" date.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _searchPerformed = true;
    });

    final firestoreService = context.read<FirestoreService>();
    final results =
        await firestoreService.searchIncidentsByDateRange(_fromDate!, _toDate!);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Set<Marker> _createMarkers() {
    return _searchResults.map((incident) {
      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.latitude, incident.longitude),
        infoWindow: InfoWindow(
          title: incident.address,
          snippet: 'Tap to view details',
          onTap: () => context.push('/image-details', extra: incident),
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Incidents')),
      body: Column(
        children: [
          _buildSearchControls(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildResultsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchControls() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fromController,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _toController,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<OutputFormat>(
                  segments: const [
                    ButtonSegment(
                        value: OutputFormat.map,
                        label: Text('Map'),
                        icon: Icon(Icons.map)),
                    ButtonSegment(
                        value: OutputFormat.list,
                        label: Text('List'),
                        icon: Icon(Icons.list)),
                  ],
                  selected: {_outputFormat},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _outputFormat = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
                child: const Text('Search'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (!_searchPerformed) {
      return const Center(
          child: Text('Please select a date range and click search.'));
    }
    if (_searchResults.isEmpty) {
      return const Center(
          child: Text('No incidents found for the selected dates.'));
    }

    if (_outputFormat == OutputFormat.map) {
      return GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _puneLocation,
          zoom: 12,
        ),
        markers: _createMarkers(),
      );
    } else {
      return _buildResultsTable();
    }
  }

  Widget _buildResultsTable() {
    const double imageHeight = 90.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SingleChildScrollView(
        child: Scrollbar(
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 12,
            dataRowMinHeight: imageHeight + 16, // image height + padding
            dataRowMaxHeight: imageHeight + 16,
            columns: [
              DataColumn(
                  label: Flexible(
                      child: Text('Address',
                          style: const TextStyle(fontWeight: FontWeight.bold)))),
              DataColumn(
                  label: Text('Image',
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _searchResults.map((incident) {
              return DataRow(
                onSelectChanged: (_) {
                  context.push('/image-details', extra: incident);
                },
                cells: [
                  DataCell(
                    SizedBox(
                      width: screenWidth * 0.5,
                      child: Text(incident.address,
                          overflow: TextOverflow.ellipsis, maxLines: 4),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          incident.imageUrl,
                          height: imageHeight,
                          width: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator()),
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

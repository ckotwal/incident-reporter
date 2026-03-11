
import 'package:flutter/material.dart';

class SearchIncidentsScreen extends StatelessWidget {
  const SearchIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Incidents'),
      ),
      body: const Center(
        child: Text('Search Incidents Screen'),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search Incidents'),
            onTap: () {
              context.go('/search_incidents');
            },
          ),
          ListTile(
            leading: const Icon(Icons.near_me),
            title: const Text('Nearby Incidents'),
            onTap: () {
              context.go('/nearby_incidents');
            },
          ),
        ],
      ),
    );
  }
}

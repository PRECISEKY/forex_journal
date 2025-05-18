import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added import for Supabase

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.storage), // Or other relevant icon
            title: const Text('Manage Strategies'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to the sub-route for strategies
              context.push('/settings/strategies');
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange), // Icon for Forex Pairs
            title: const Text('Manage Forex Pairs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate using the path defined in the router
              context.push('/settings/pairs');
            },
          ),
          ListTile(
            leading: const Icon(Icons.label), // Icon for Tags
            title: const Text('Manage Tags'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to the sub-route for tags
              context.push('/settings/tags');
            },
          ),
          const Divider(), // Add a separator
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: () async { // Make onTap async
              try {
                await Supabase.instance.client.auth.signOut();
                print('User signed out');
                // Optionally show a snackbar
                // if (context.mounted) {
                //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged out')));
                // }
              } catch (e) {
                print('Error signing out: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
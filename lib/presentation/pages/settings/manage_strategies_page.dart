import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import go_router

// Import the database file to access the provider and Strategy class
import '../../../data/local/database.dart'; // CORRECT PATH (3 dots)
import '../../../data/remote/sync_service.dart'; // Import SyncService for delete

class ManageStrategiesPage extends ConsumerWidget {
  const ManageStrategiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream provider to get the list of strategies
    final strategiesAsyncValue = ref.watch(allStrategiesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Strategies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Strategy',
            onPressed: () {
              // Navigate to the new Add Strategy route
              context.push('/settings/strategies/add'); // Use push
            },
          ),
        ],
      ),
      // Use AsyncValue.when to handle loading/error/data states
      body: strategiesAsyncValue.when(
        data: (strategies) {
          // If the list is empty, show a message
          if (strategies.isEmpty) {
            return const Center(
              child: Text('No strategies found. Tap + to add one.'),
            );
          }
          // If data is available, display it in a ListView
          return ListView.builder(
            itemCount: strategies.length,
            itemBuilder: (context, index) {
              final strategy = strategies[index];
              return ListTile(
                title: Text(strategy.name),
                subtitle: strategy.description != null
                    ? Text(strategy.description!) // Show description if available
                    : null,
                // NEW: Add trailing buttons
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Keep row narrow
                  children: [
                    // Edit Button
                    IconButton(
                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                      tooltip: 'Edit Strategy',
                      onPressed: () {
                        // Navigate to Add/Edit page, passing the strategy object
                        context.push('/settings/strategies/add', extra: strategy); // Use 'add' route, pass data
                      },
                    ),
                    // Delete Button
                    IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                       tooltip: 'Delete Strategy',
                      onPressed: () async { // Make async for dialog and delete calls
                         // Show Confirmation Dialog
                        final bool? confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text('Delete strategy "${strategy.name}"? This cannot be undone.'), // Show name
                            actions: [
                               TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
                               TextButton(
                                 style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                 child: const Text('Delete'),
                                 onPressed: () => Navigator.of(context).pop(true)),
                            ],
                          ),
                        );

                        // If confirmed, perform delete
                        if (confirmDelete == true) {
                           try {
                             // Delete locally first
                             await ref.read(strategyDaoProvider).deleteStrategy(strategy.id);
                             // Then delete from Supabase (fire and forget for now)
                             ref.read(syncServiceProvider).deleteSupabaseStrategy(strategy.id); // No need to await? Or show loading?

                             if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Strategy deleted')));
                             }
                           } catch (e) {
                              print('Error deleting strategy: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
                              }
                           }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        // Show an error message if the stream fails
        error: (error, stackTrace) {
           print('Error loading strategies: $error'); // Log error
           return Center(child: Text('Error loading strategies: $error'));
        },
        // Show a loading indicator while fetching
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
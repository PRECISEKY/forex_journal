import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/remote/sync_service.dart'; // Import sync service for delete
// Import database/providers (adjust path if necessary)
import '../../../data/local/database.dart';

class ManagePairsPage extends ConsumerWidget {
  const ManagePairsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider for the list of pairs
    final pairsAsyncValue = ref.watch(allPairsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Forex Pairs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Pair',
            onPressed: () {
              // Navigate to the Add Pair screen
              context.push('/settings/pairs/add');
            },
          ),
        ],
      ),
      body: pairsAsyncValue.when(
        data: (pairs) {
          if (pairs.isEmpty) {
            return const Center(
              child: Text('No pairs added yet. Tap + to add your first pair.'),
            );
          }
          // Display pairs in a list
          return ListView.builder(
            itemCount: pairs.length,
            itemBuilder: (context, index) {
              final pair = pairs[index];
              return ListTile(
                title: Text(pair.name),
                // NEW: Add trailing buttons
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Keep row narrow
                  children: [
                    // Edit Button
                    IconButton(
                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                      tooltip: 'Edit Pair',
                      onPressed: () {
                        // Navigate using the NEW edit route with the ID in the path
                        context.push('/settings/pairs/edit/${pair.id}');
                      },
                    ),
                    // Delete Button
                    IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                      tooltip: 'Delete Pair',
                      onPressed: () async { // Make async
                        // Show Confirmation Dialog
                        final bool? confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text('Delete pair "${pair.name}"? This may affect existing trades linked to it if not handled carefully.\n(Cloud delete for pairs is currently disabled).'), // Updated message
                            actions: [
                              TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
                              TextButton(
                                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                  child: const Text('Delete Locally'), // Change button text
                                  onPressed: () => Navigator.of(context).pop(true)),
                            ],
                          ),
                        );

                        // If confirmed, perform LOCAL delete only for now
                        if (confirmDelete == true) {
                          try {
                            // Delete locally
                            await ref.read(pairDaoProvider).deletePair(pair.id);
                            // We are NOT calling deleteSupabasePair yet
                            // ref.read(syncServiceProvider).deleteSupabasePair(pair.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pair deleted locally')));
                            }
                          } catch (e) {
                            print('Error deleting pair locally: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting locally: $e')));
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
        error: (error, stackTrace) => Center(child: Text('Error loading pairs: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
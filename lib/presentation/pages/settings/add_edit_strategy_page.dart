import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/local/database.dart'; // Adjust import path if needed
import '../../../data/remote/sync_service.dart'; // Import sync service
import '../../../data/local/database.dart' show Strategy, StrategiesCompanion; // Import Strategy class

// Simple page for adding (and later editing) strategies
class AddEditStrategyPage extends ConsumerStatefulWidget {
  final Strategy? strategyToEdit;
  const AddEditStrategyPage({super.key, this.strategyToEdit});

  @override
  ConsumerState<AddEditStrategyPage> createState() => _AddEditStrategyPageState();
}

class _AddEditStrategyPageState extends ConsumerState<AddEditStrategyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Flag for edit mode
  bool get _isEditing => widget.strategyToEdit != null;

  @override
  void initState() {
    super.initState();
    // Populate fields if editing
    if (_isEditing) {
      _nameController.text = widget.strategyToEdit!.name;
      _descriptionController.text = widget.strategyToEdit!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveStrategy() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final description = _descriptionController.text.isEmpty ? null : _descriptionController.text;
      final bool isEditing = widget.strategyToEdit != null;

      final companion = StrategiesCompanion(
        id: isEditing ? Value(widget.strategyToEdit!.id) : const Value.absent(),
        name: Value(name),
        description: Value(description),
      );

      try {
        final dao = ref.read(strategyDaoProvider);
         Strategy? savedLocalStrategy;

        if (isEditing) {
          await dao.updateStrategy(companion);
          savedLocalStrategy = widget.strategyToEdit!.copyWith(
            name: name,
            description: Value(description),
          );
          print('Strategy updated locally with ID: ${savedLocalStrategy.id}');
        } else {
          savedLocalStrategy = await dao.insertStrategy(companion);
          print('Strategy inserted locally with temp ID: ${savedLocalStrategy.id}');
        }

        // Sync and get Supabase ID
        final int? supabaseId = await ref.read(syncServiceProvider).upsertStrategy(companion);

        // Align local ID if needed after insert
        if (!isEditing && supabaseId != null && supabaseId != savedLocalStrategy!.id) {
           print('Aligning local ID (${savedLocalStrategy.id}) with Supabase ID ($supabaseId) for ${savedLocalStrategy.name}');
           await dao.deleteStrategy(savedLocalStrategy.id);
           final finalCompanion = StrategiesCompanion(
                id: Value(supabaseId),
                name: Value(name),
                description: Value(description)
           );
           await dao.insertStrategy(finalCompanion);
            print('Local strategy ID aligned.');
        }


        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Strategy ${isEditing ? "updated" : "saved"} & synced!')),
          );
          context.pop();
        }
      } catch (e) {
          print('Error during strategy save/sync: $e');
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save strategy: $e')));
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Strategy' : 'Add Strategy';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Strategy',
            onPressed: _saveStrategy,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Strategy Name *', // Mark as required
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Strategy name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                 textCapitalization: TextCapitalization.sentences,
              ),
              // Add some spacing before potential footer buttons if needed
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
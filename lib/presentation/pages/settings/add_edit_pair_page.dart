import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import database/providers (adjust path if necessary)
import '../../../data/local/database.dart' show Pair, PairsCompanion;
import '../../../data/remote/sync_service.dart';
// Add this line (adjust path if VS Code suggests differently)
import '../../../data/local/database.dart';
class AddEditPairPage extends ConsumerStatefulWidget {
  // Changed parameter name
  final int? editPairId;

  const AddEditPairPage({super.key, this.editPairId});

  @override
  ConsumerState<AddEditPairPage> createState() => _AddEditPairPageState();
}


// --- Replace the entire State class ---
class _AddEditPairPageState extends ConsumerState<AddEditPairPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // State for holding the fetched pair when editing
  Pair? _pairBeingEdited;
  // State for loading indicator while fetching data
  bool _isLoadingData = true; // Start true if potentially editing
  bool _isSaving = false; // Keep track of save operation

  // --- Getter determines mode based on ID passed to the widget ---
  bool get _isEditing => widget.editPairId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // If editing, load the data based on the ID
      _loadPairForEditing();
    } else {
      // If adding, we are not loading anything
      _isLoadingData = false;
    }
  }

  // Method to load data when editing
  Future<void> _loadPairForEditing() async {
    try {
      if (!_isEditing || widget.editPairId == null) {
        // This is a safety check - _loadPairForEditing should only be called when editing
        setState(() { _isLoadingData = false; });
        return;
      }

      final dao = ref.read(pairDaoProvider);
      // Since we checked for null above, we can safely use ! here
      final loadedPair = await dao.getPairById(widget.editPairId!);
      if (loadedPair != null && mounted) {
        setState(() {
          _pairBeingEdited = loadedPair;
          _nameController.text = loadedPair.name;
          _isLoadingData = false;
        });
      } else if (mounted) {
        setState(() { _isLoadingData = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not load pair data to edit.'))
        );
      }
    } catch (e) {
      print("Error loading pair for edit: $e");
      if (mounted) {
        setState(() { _isLoadingData = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pair data: $e'))
        );
      }
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Save Pair Logic (using _isEditing getter)
  Future<void> _savePair() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final name = _nameController.text.toUpperCase().trim();
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in. Cannot save pair.')),
          );
          setState(() {
            _isSaving = false;
          });
        }
        return;
      }

      // Get definitively non-null ID when editing
      final definitiveEditId = _isEditing ? widget.editPairId : null;
      if (_isEditing && definitiveEditId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Invalid edit ID')),
          );
          setState(() {
            _isSaving = false;
          });
        }
        return;
      }

      final companion = PairsCompanion(
        id: definitiveEditId != null ? Value(definitiveEditId) : const Value.absent(),
        name: Value(name),
      );

      try {
        final dao = ref.read(pairDaoProvider);
        Pair? savedLocalPair;

        if (_isEditing && definitiveEditId != null) {
          await dao.updatePair(companion);
          savedLocalPair = _pairBeingEdited?.copyWith(
            name: name,
            userId: _pairBeingEdited?.userId ?? currentUserId,
            createdAt: _pairBeingEdited?.createdAt ?? DateTime.now(),
          ) ?? Pair(
            id: definitiveEditId,  // Now using our non-null ID
            name: name,
            userId: currentUserId,
            createdAt: DateTime.now(),
          );
          print('Pair updated locally with ID: ${savedLocalPair.id}');
        } else {
          savedLocalPair = await dao.insertPair(companion);
          print('Pair inserted locally with temp ID: ${savedLocalPair.id}');
        }

        final int? supabaseId = await ref.read(syncServiceProvider).upsertPair(companion);

        if (!_isEditing && supabaseId != null && supabaseId != savedLocalPair.id) {
          print('Aligning local ID (${savedLocalPair.id}) with Supabase ID ($supabaseId) for ${savedLocalPair.name}');
          await dao.deletePair(savedLocalPair.id);
          final finalCompanion = PairsCompanion(
            id: Value(supabaseId),
            name: Value(name)
          );
          await dao.insertPair(finalCompanion);
          print('Local pair ID aligned.');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pair ${_isEditing ? "updated" : "saved"} & synced!')),
          );
          context.pop();
        }
      } catch (e) {
        print('Error during pair save/sync: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save pair: $e'))
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  // Build method (uses _isEditing getter)
  @override
  Widget build(BuildContext context) {
    // Use getter for title
    final title = _isEditing ? 'Edit Pair' : 'Add Pair';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            // Disable button while saving
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
            tooltip: 'Save Pair',
            onPressed: _isSaving ? null : _savePair,
          )
        ],
      ),
      body: _isLoadingData // Show loading indicator while fetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pair Name (e.g., EURUSD) *',
                        border: OutlineInputBorder(),
                      ),
                      // Automatically convert to uppercase as user types
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Pair name cannot be empty';
                        }
                         if (value.trim().length < 6) {
                           return 'Pair name should be at least 6 characters';
                         }
                        // Basic check for common format (XXX/YYY or XXXYYY)
                        // Allow just 6 chars for simplicity now
                        // if (!RegExp(r'^[A-Z]{3}/?[A-Z]{3}$').hasMatch(value.trim())) {
                        //   return 'Use format like EURUSD or EUR/USD';
                        // }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Note: Pair names should be unique.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} // End State class
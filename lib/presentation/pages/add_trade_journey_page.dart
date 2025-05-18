import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Add if not already present
import '../../data/local/database.dart'; // Needed for Pair, Strategy, allPairsStreamProvider, and allStrategiesStreamProvider
import 'dart:io'; // For File objects used with images
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:convert'; // For JSON encoding tags/images later
import '../../data/remote/sync_service.dart'; // Needed for saving/syncing
import 'package:supabase_flutter/supabase_flutter.dart'; // Needed for user ID
import 'package:go_router/go_router.dart'; // Needed for navigating back
import 'package:drift/drift.dart' show Value; // Needed for TradesCompanion Value()

// This is the new page for the step-by-step "journey" trade logging
class AddTradeJourneyPage extends ConsumerStatefulWidget {
  const AddTradeJourneyPage({super.key});

  @override
  ConsumerState<AddTradeJourneyPage> createState() => _AddTradeJourneyPageState();
}

class _AddTradeJourneyPageState extends ConsumerState<AddTradeJourneyPage> {

  final PageController _pageController = PageController();
  int _currentPage = 0;
  int? _selectedPairId; // Stores the ID of the selected pair
  bool? _selectedDirection; // Stores the direction (true=Long, false=Short)
  DateTime? _entryDateTime; // Stores the selected entry date and time
  final TextEditingController _entryPriceController = TextEditingController(); // Controller for price input
  DateTime? _exitDateTime; // Stores the selected exit date and time
  final TextEditingController _exitPriceController = TextEditingController(); // Controller for exit price
  final TextEditingController _lotsController = TextEditingController(); // Controller for lots size
  int? _selectedStrategyId; // Stores the ID of the selected strategy (optional)
  final TextEditingController _stopLossController = TextEditingController();
  final TextEditingController _takeProfitController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _swapController = TextEditingController();
  int? _journeyConfidenceScore; // Use a unique name to avoid conflicts if copied later
  final TextEditingController _reasonEntryController = TextEditingController();
  final TextEditingController _reasonExitController = TextEditingController();
  final TextEditingController _tagInputController = TextEditingController();
  List<String> _customTags = []; // List to hold tags
  List<String> _imagePaths = []; // List to hold image paths
  bool _isLoading = false; // To show loading indicator on save button

  @override
  void dispose() {
    _pageController.dispose(); // Clean up the controller
    _entryPriceController.dispose(); // Clean up the controller
    _exitPriceController.dispose(); // Clean up the controller
    _lotsController.dispose(); // Dispose lots controller
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _commissionController.dispose();
    _swapController.dispose();
    _reasonEntryController.dispose();
    _reasonExitController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initialDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date == null) return null; // User cancelled Date picker

    if (!context.mounted) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );

    if (time == null) return null; // User cancelled Time picker

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context, await picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log New Trade'), // Title for the page
        // We might add progress indication here later
      ),
      body: Column( // Main layout: PageView + Navigation Controls
        children: [
          Expanded(
            child: PageView(
              controller: _pageController, // Use the controller
              onPageChanged: (int page) {
                setState(() { // Update the current page index when swiped
                  _currentPage = page;
                });
              },
              physics: const NeverScrollableScrollPhysics(), // Disable user swiping
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Make column fill width
                    children: [
                      const Spacer(), // Added before title
                      Text(
                        'Step 1: Select Pair',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Consumer( // No longer wrapped in Expanded
                        builder: (context, ref, child) {
                          // Get the AsyncValue for the list of Pair objects
                          final pairsAsyncValue = ref.watch(allPairsStreamProvider);

                          // Use .when to handle loading/error/data states
                          return pairsAsyncValue.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(child: Text('Error loading pairs: $error')),
                            data: (pairs) {
                              if (pairs.isEmpty) {
                                return const Center(child: Text('No pairs found. Please add pairs in Settings.'));
                              }
                              // Display pairs using Wrap and ChoiceChip
                              return SingleChildScrollView( // Make chips scrollable if they overflow
                                child: Wrap(
                                  spacing: 8.0, // Horizontal space between chips
                                  runSpacing: 8.0, // Vertical space between lines of chips
                                  alignment: WrapAlignment.center, // Center chips horizontally
                                  children: pairs.map((pair) {
                                    return ChoiceChip(
                                      label: Text(pair.name),
                                      labelStyle: TextStyle(
                                        color: _selectedPairId == pair.id
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      selected: _selectedPairId == pair.id, // Check if this chip is selected
                                      selectedColor: Theme.of(context).colorScheme.primary,
                                      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                                      onSelected: (isSelected) {
                                        setState(() { // Update state when a chip is tapped
                                          if (isSelected) {
                                            _selectedPairId = pair.id; // Store the selected ID

                                            // Automatically go to the next page after selection
                                            _pageController.nextPage(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                            );

                                          } else {
                                            // ... potentially handle unselecting ...
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          );
                        },
                      ), // End of Consumer
                      const Spacer(), // Added after chips
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Spacer(),
                      Text(
                        'Step 2: Select Direction',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SegmentedButton<bool>(
                        segments: const <ButtonSegment<bool>>[
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Long'),
                            icon: Icon(Icons.arrow_upward),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Short'),
                            icon: Icon(Icons.arrow_downward),
                          ),
                        ],
                        selected: _selectedDirection == null ? <bool>{} : <bool>{_selectedDirection!},
                        multiSelectionEnabled: false,
                        emptySelectionAllowed: true, // Changed from false to true
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _selectedDirection = newSelection.isEmpty ? null : newSelection.first;
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                          selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Spacer(),
                      Text(
                        'Step 3: Entry Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text('Entry Date & Time*', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final pickedDateTime = await _pickDateTime(context, _entryDateTime);
                          if (pickedDateTime != null) {
                            setState(() {
                              _entryDateTime = pickedDateTime;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _entryDateTime == null
                                    ? 'Select Date & Time...'
                                    : DateFormat.yMd().add_jm().format(_entryDateTime!),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _entryDateTime == null ? Theme.of(context).hintColor : null,
                                ),
                              ),
                              const Icon(Icons.calendar_month_outlined, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Entry Price*', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _entryPriceController,
                        decoration: InputDecoration(
                          labelText: 'Enter Entry Price',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null) return 'Invalid number';
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Spacer(), // Vertical centering
                      Text(
                        'Step 4: Exit Details', // Page Title
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // --- Exit Date & Time Picker ---
                      Text('Exit Date & Time*', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final pickedDateTime = await _pickDateTime(context, _exitDateTime ?? _entryDateTime);
                          if (pickedDateTime != null) {
                            setState(() {
                              _exitDateTime = pickedDateTime;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _exitDateTime == null
                                    ? 'Select Date & Time...'
                                    : DateFormat.yMd().add_jm().format(_exitDateTime!),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _exitDateTime == null ? Theme.of(context).hintColor : null,
                                ),
                              ),
                              const Icon(Icons.calendar_month_outlined, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Exit Price Input ---
                      Text('Exit Price*', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _exitPriceController, // Use exit controller
                        decoration: InputDecoration(
                          labelText: 'Enter Exit Price',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null) return 'Invalid number';
                          return null;
                        },
                        onChanged: (value) => setState(() {}), // Update state to re-check Next button
                      ),

                      const Spacer(), // Vertical centering
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Spacer(), // Vertical centering
                      Text(
                        'Step 5: Position Size', // Page Title
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // --- Position Size (Lots) Input ---
                      Text('Position Size (Lots)*', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lotsController, // Use lots controller
                        decoration: InputDecoration(
                          labelText: 'Enter Lots (e.g., 0.1, 1.0)',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final number = double.tryParse(value);
                          if (number == null) return 'Invalid number';
                          if (number <= 0) return 'Must be positive'; // Lots must be > 0
                          return null;
                        },
                        onChanged: (value) => setState(() {}), // Update state to re-check Next button
                      ),

                      const Spacer(), // Vertical centering
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(), // Vertical centering
                      Text(
                        'Step 6: Select Strategy (Optional)', // Indicate optional
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Expanded( // Allow list/wrap to take space
                        child: Consumer( // Watch the provider for strategies
                          builder: (context, ref, child) {
                            final strategiesAsyncValue = ref.watch(allStrategiesStreamProvider);

                            return strategiesAsyncValue.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (error, stack) => Center(child: Text('Error loading strategies: $error')),
                              data: (strategies) {
                                if (strategies.isEmpty) {
                                  return const Center(child: Text('(No strategies defined in Settings)'));
                                }
                                return SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    alignment: WrapAlignment.center,
                                    children: strategies.map((strategy) {
                                      return ChoiceChip(
                                        label: Text(strategy.name),
                                        labelStyle: TextStyle(
                                          color: _selectedStrategyId == strategy.id
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        selected: _selectedStrategyId == strategy.id,
                                        selectedColor: Theme.of(context).colorScheme.primary,
                                        checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                                        onSelected: (isSelected) {
                                          setState(() {
                                            _selectedStrategyId = isSelected ? strategy.id : null;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16), // Space before hint
                      Text(
                        'Selecting a strategy is optional.\nTap Next to skip or continue.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const Spacer(), // Vertical centering
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        Text(
                          'Step 7: Order Details (Optional)',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _stopLossController,
                          decoration: InputDecoration(labelText: 'Stop Loss Price'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _takeProfitController,
                          decoration: InputDecoration(labelText: 'Take Profit Price'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _commissionController,
                          decoration: InputDecoration(labelText: 'Commissions'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _swapController,
                          decoration: InputDecoration(labelText: 'Swaps'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _journeyConfidenceScore,
                          decoration: InputDecoration(
                            labelText: 'Confidence Score',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<int>(value: null, child: Text('Select Score (1-5)')),
                            ...List.generate(5, (index) => DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text('${index + 1} Star${index == 0 ? '' : 's'}'),
                            )),
                          ],
                          onChanged: (int? newValue) {
                            setState(() {
                              _journeyConfidenceScore = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'All details on this page are optional.\nTap Next to skip or continue.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Step 8: Notes & Media (Optional)',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _reasonEntryController,
                          decoration: InputDecoration(labelText: 'Reason for Entry'),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reasonExitController,
                          decoration: InputDecoration(labelText: 'Reason for Exit / Management'),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        Text('Custom Tags', style: Theme.of(context).textTheme.titleMedium),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagInputController,
                                decoration: InputDecoration(hintText: 'Type a tag and press +'),
                                onSubmitted: (_) {
                                  final tag = _tagInputController.text.trim();
                                  if (tag.isNotEmpty && !_customTags.contains(tag)) {
                                    setState(() {
                                      _customTags.add(tag);
                                    });
                                    _tagInputController.clear();
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                final tag = _tagInputController.text.trim();
                                if (tag.isNotEmpty && !_customTags.contains(tag)) {
                                  setState(() {
                                    _customTags.add(tag);
                                  });
                                  _tagInputController.clear();
                                }
                              },
                              tooltip: 'Add Tag',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _customTags.map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setState(() {
                                _customTags.remove(tag);
                              });
                            },
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text('Screenshots', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonal(
                            onPressed: () => _showImageSourceActionSheet(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attach_file, size: 18),
                                const SizedBox(width: 8),
                                const Text('Attach Screenshot'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _imagePaths.map((path) => Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  File(path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() {
                                      _imagePaths.remove(path);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'All details on this page are optional.\nTap Next for final review or to save.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Step 9: Review & Save',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Please review the details before saving:', style: Theme.of(context).textTheme.titleMedium),
                        const Divider(height: 20),
                        Text('Pair ID: ${_selectedPairId ?? 'Not Set'}'),
                        Text('Direction: ${_selectedDirection == null ? 'Not Set' : (_selectedDirection! ? 'Long' : 'Short')}'),
                        Text('Entry Time: ${_entryDateTime == null ? 'Not Set' : DateFormat.yMd().add_jm().format(_entryDateTime!)}'),
                        Text('Entry Price: ${_entryPriceController.text}'),
                        Text('Exit Time: ${_exitDateTime == null ? 'Not Set' : DateFormat.yMd().add_jm().format(_exitDateTime!)}'),
                        Text('Exit Price: ${_exitPriceController.text}'),
                        Text('Position Size: ${_lotsController.text} Lots'),
                        if (_selectedStrategyId != null) Text('Strategy ID: $_selectedStrategyId'),
                        if (_stopLossController.text.isNotEmpty) Text('Stop Loss: ${_stopLossController.text}'),
                        if (_takeProfitController.text.isNotEmpty) Text('Take Profit: ${_takeProfitController.text}'),
                        if (_commissionController.text.isNotEmpty) Text('Commissions: ${_commissionController.text}'),
                        if (_swapController.text.isNotEmpty) Text('Swaps: ${_swapController.text}'),
                        if (_journeyConfidenceScore != null) Text('Confidence: $_journeyConfidenceScore Stars'),
                        if (_reasonEntryController.text.isNotEmpty) Text('Entry Notes: ${_reasonEntryController.text}'),
                        if (_reasonExitController.text.isNotEmpty) Text('Exit Notes: ${_reasonExitController.text}'),
                        if (_customTags.isNotEmpty) Text('Tags: ${_customTags.join(', ')}'),
                        if (_imagePaths.isNotEmpty) Text('Screenshots Attached: ${_imagePaths.length}'),
                        const SizedBox(height: 30),
                        Center(child: Text('Tap "Save Trade" below to finish.', style: Theme.of(context).textTheme.titleMedium)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentPage == 0 ? null : () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    bool canProceed = false;
                    if (_currentPage == 0 && _selectedPairId != null) { canProceed = true; }
                    else if (_currentPage == 1 && _selectedDirection != null) { canProceed = true; }
                    else if (_currentPage == 2 && _entryDateTime != null && _entryPriceController.text.isNotEmpty && double.tryParse(_entryPriceController.text) != null) { canProceed = true; }
                    else if (_currentPage == 3 && _exitDateTime != null && _exitPriceController.text.isNotEmpty && double.tryParse(_exitPriceController.text) != null) { canProceed = true; }
                    else if (_currentPage == 4) {
                      final lotsText = _lotsController.text; final lotsNumber = double.tryParse(lotsText);
                      if (lotsText.isNotEmpty && lotsNumber != null && lotsNumber > 0) { canProceed = true; }
                    }
                    else if (_currentPage == 5) { canProceed = true; }
                    else if (_currentPage == 6) { canProceed = true; }
                    else if (_currentPage == 7) { canProceed = true; }
                    else if (_currentPage == 8) { canProceed = true; }

                    if (canProceed) {
                      if (_currentPage < 8) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _saveTradeJourney();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please complete the current required step.'), duration: Duration(seconds: 2)),
                      );
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_currentPage == 8 ? 'Save Trade' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTradeJourney() async {
    if (_selectedPairId == null || _selectedDirection == null || _entryDateTime == null || _exitDateTime == null ||
        _entryPriceController.text.isEmpty || _exitPriceController.text.isEmpty || _lotsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot save, required fields missing!')));
      return;
    }

    final entryPrice = double.tryParse(_entryPriceController.text);
    final exitPrice = double.tryParse(_exitPriceController.text);
    final lots = double.tryParse(_lotsController.text);
    final stopLoss = double.tryParse(_stopLossController.text);
    final takeProfit = double.tryParse(_takeProfitController.text);
    final commission = double.tryParse(_commissionController.text);
    final swap = double.tryParse(_swapController.text);

    if (entryPrice == null || exitPrice == null || lots == null || lots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid number format for prices or lots.')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final tradeDao = ref.read(tradeDaoProvider);
      final strategyDao = ref.read(strategyDaoProvider);
      final pairDao = ref.read(pairDaoProvider);
      final syncService = ref.read(syncServiceProvider);
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      if (currentUserId == null) throw Exception("User not logged in.");

      final Pair? selectedPair = await pairDao.getPairById(_selectedPairId!);
      if (selectedPair == null) throw Exception("Selected Pair not found in DB!");
      final String pairName = selectedPair.name;

      String? strategyName;
      if (_selectedStrategyId != null) {
        final Strategy? selectedStrategy = await (strategyDao.select(strategyDao.strategies)..where((s) => s.id.equals(_selectedStrategyId!))).getSingleOrNull();
        strategyName = selectedStrategy?.name;
      }

      final localCompanion = TradesCompanion(
        pairId: Value(_selectedPairId!),
        pair: Value(pairName),
        entryDate: Value(_entryDateTime!),
        exitDate: Value(_exitDateTime!),
        isLong: Value(_selectedDirection!),
        entryPrice: Value(entryPrice),
        exitPrice: Value(exitPrice),
        positionSizeLots: Value(lots),
        stopLossPrice: Value(stopLoss),
        takeProfitPrice: Value(takeProfit),
        commissionFees: Value(commission),
        swapFees: Value(swap),
        reasonForEntry: Value(_reasonEntryController.text.isEmpty ? null : _reasonEntryController.text),
        reasonForExit: Value(_reasonExitController.text.isEmpty ? null : _reasonExitController.text),
        confidenceScore: Value(_journeyConfidenceScore),
        customTagsJson: Value(_customTags.isNotEmpty ? jsonEncode(_customTags) : null),
      );

      final insertedTrade = await tradeDao.insertTrade(localCompanion);
      final savedTradeId = insertedTrade.id;

      List<String> finalImageUrls = [];
      for (String path in _imagePaths) {
        final String? uploadedUrl = await syncService.uploadTradeImage(
          localPath: path, userId: currentUserId, tradeId: savedTradeId,
        );
        if (uploadedUrl != null) {
          finalImageUrls.add(uploadedUrl);
        }
      }

      final finalCompanion = localCompanion.copyWith(
        id: Value(savedTradeId),
        imagePathsJson: Value(finalImageUrls.isNotEmpty ? jsonEncode(finalImageUrls) : null),
        userId: Value(currentUserId),
      );

      await tradeDao.updateTrade(finalCompanion);
      await syncService.upsertTrade(finalCompanion, pairName, strategyName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trade saved & synced!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving trade: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }
}
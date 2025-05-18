import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // For back navigation later   
import 'package:drift/drift.dart' show Value; // Needed for Value()
import '../../data/local/database.dart';      // Needed for TradesCompanion, tradeDaoProvider, and Strategy class
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'dart:convert'; // For JSON encoding
import 'dart:io'; // For File objects
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/remote/sync_service.dart'; // Import the sync service
import 'dart:developer'; // Import for logging
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class AddTradePage extends ConsumerStatefulWidget {
  final Trade? tradeToEdit;

  const AddTradePage({super.key, this.tradeToEdit});

  @override
  ConsumerState<AddTradePage> createState() => _AddTradePageState();
}

class _AddTradePageState extends ConsumerState<AddTradePage> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final _entryPriceController = TextEditingController();
  final _exitPriceController = TextEditingController();
  final _lotsController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _takeProfitController = TextEditingController();
  final _actualPlController = TextEditingController();
  final _commissionController = TextEditingController();
  final _swapController = TextEditingController();
  final _reasonEntryController = TextEditingController();
  final _reasonExitController = TextEditingController();
  final _tagInputController = TextEditingController();

  // --- State Variables ---
  bool? _isLong;
  DateTime? _entryDateTime;
  DateTime? _exitDateTime;
  int? _confidenceScore;
  List<String> _customTags = [];
  List<String> _imagePaths = [];
  Strategy? _selectedStrategy;
  Pair? _selectedPair; // NEW: State for selected Pair object
  bool _isLoading = false;

  // --- Editing Flag ---
  bool get _isEditing => widget.tradeToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final trade = widget.tradeToEdit!;
      print('>>> EDITING Trade with LOCAL ID: ${trade.id}'); // Add this log
      _entryDateTime = trade.entryDate;
      _exitDateTime = trade.exitDate;
      _isLong = trade.isLong;
      _entryPriceController.text = trade.entryPrice.toString();
      _exitPriceController.text = trade.exitPrice.toString();
      _lotsController.text = trade.positionSizeLots.toString();
      _stopLossController.text = trade.stopLossPrice?.toString() ?? '';
      _takeProfitController.text = trade.takeProfitPrice?.toString() ?? '';
      _commissionController.text = trade.commissionFees?.toString() ?? '';
      _swapController.text = trade.swapFees?.toString() ?? '';
      _actualPlController.text = trade.actualProfitLoss?.toString() ?? '';
      _confidenceScore = trade.confidenceScore;
      _reasonEntryController.text = trade.reasonForEntry ?? '';
      _reasonExitController.text = trade.reasonForExit ?? '';
      if (trade.customTagsJson != null) {
        try {
          _customTags = List<String>.from(jsonDecode(trade.customTagsJson!));
        } catch (_) {}
      }
      if (trade.imagePathsJson != null) {
        try {
          _imagePaths = List<String>.from(jsonDecode(trade.imagePathsJson!));
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _entryPriceController.dispose();
    _exitPriceController.dispose();
    _lotsController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _actualPlController.dispose();
    _commissionController.dispose();
    _swapController.dispose();
    _reasonEntryController.dispose();
    _reasonExitController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _saveTrade() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPair == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Forex Pair')));
        return;
      }
      if (_isLong == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select trade direction (Long/Short)')));
        return;
      }
      if (_entryDateTime == null || _exitDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both Entry and Exit Date/Time')));
        return;
      }
      if (_exitDateTime!.isBefore(_entryDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exit time cannot be before Entry time')));
        return;
      }

      final entryPrice = double.tryParse(_entryPriceController.text);
      final exitPrice = double.tryParse(_exitPriceController.text);
      final lots = double.tryParse(_lotsController.text);
      final stopLoss = double.tryParse(_stopLossController.text);
      final takeProfit = double.tryParse(_takeProfitController.text);
      final commission = double.tryParse(_commissionController.text);
      final swap = double.tryParse(_swapController.text);
      final actualPl = double.tryParse(_actualPlController.text);

      if (entryPrice == null || exitPrice == null || lots == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid number format for prices or lots.')));
        return;
      }

      final localCompanion = TradesCompanion(
        id: _isEditing ? Value(widget.tradeToEdit!.id) : const Value.absent(),
        pairId: Value(_selectedPair!.id),
        pair: Value(_selectedPair!.name),
        entryDate: Value(_entryDateTime!),
        exitDate: Value(_exitDateTime!),
        isLong: Value(_isLong!),
        entryPrice: Value(entryPrice),
        exitPrice: Value(exitPrice),
        positionSizeLots: Value(lots),
        stopLossPrice: Value(stopLoss),
        takeProfitPrice: Value(takeProfit),
        commissionFees: Value(commission),
        swapFees: Value(swap),
        actualProfitLoss: Value(actualPl),
        strategyId: Value(_selectedStrategy?.id),
        strategyTag: const Value(null),
        reasonForEntry: Value(_reasonEntryController.text.isEmpty ? null : _reasonEntryController.text),
        reasonForExit: Value(_reasonExitController.text.isEmpty ? null : _reasonExitController.text),
        confidenceScore: Value(_confidenceScore),
        customTagsJson: Value(_customTags.isNotEmpty ? jsonEncode(_customTags) : null),
        imagePathsJson: const Value.absent(),
      );

      try {
        final tradeDao = ref.read(tradeDaoProvider);
        final syncService = ref.read(syncServiceProvider);
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;

        if (currentUserId == null) {
          throw Exception("User not logged in, cannot save/sync.");
        }

        String successAction = _isEditing ? "updated" : "saved";
        int savedTradeId;

        // Step 1: Save/Update Locally
        if (_isEditing) {
          final success = await tradeDao.updateTrade(localCompanion);
          if (!success) throw Exception("Local update failed.");
          savedTradeId = widget.tradeToEdit!.id;
        } else {
          final insertedTrade = await tradeDao.insertTrade(localCompanion);
          savedTradeId = insertedTrade.id;
        }
        print('Local trade $successAction successfully with ID: $savedTradeId');

        // Step 2: Upload Images
        List<String> finalImageUrls = [];
        bool uploadFailed = false;
        print('Starting image processing/upload for ${_imagePaths.length} paths...');

        for (String path in _imagePaths) {
          if (path.startsWith('http')) {
            print('Keeping existing URL: $path');
            finalImageUrls.add(path);
          } else {
            print('Uploading new local path: $path');
            final String? uploadedUrl = await syncService.uploadTradeImage(
              localPath: path,
              userId: currentUserId,
              tradeId: savedTradeId,
            );
            if (uploadedUrl != null) {
              finalImageUrls.add(uploadedUrl);
            } else {
              print('Upload failed for path: $path');
              uploadFailed = true;
              finalImageUrls.add(path);
            }
          }
        }
        print('Finished image processing. Final URLs/Paths: $finalImageUrls');

        // Step 3: Create Final Companion
        final finalCompanion = localCompanion.copyWith(
          imagePathsJson: Value(finalImageUrls.isNotEmpty ? jsonEncode(finalImageUrls) : null),
          userId: Value(currentUserId),
          id: Value(savedTradeId),
        );

        // Step 4: Update Local DB & Sync to Supabase
        print('Updating local trade with final image paths...');
        await tradeDao.updateTrade(finalCompanion);

        print("Attempting final sync to Supabase...");
        await syncService.upsertTrade(
          finalCompanion,
          _selectedPair!.name,
          _selectedStrategy?.name,
        );
        print("Supabase sync successful.");

        // Step 5: Success Feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trade $successAction & ${uploadFailed ? "partially " : ""}synced!')),
          );
          context.pop();
        }
      } catch (e, st) {
        print('Error during save/sync process: $e');
        print(st);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving/syncing trade: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strategiesAsyncValue = ref.watch(allStrategiesStreamProvider);
    final pairsAsyncValue = ref.watch(allPairsStreamProvider);

    // --- Define a common input style ---
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
    // --- End common input style ---

    final cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
    final cardColor = Theme.of(context).colorScheme.surfaceContainerLow;
    const cardMargin = EdgeInsets.symmetric(vertical: 8.0);
    const cardPadding = EdgeInsets.all(16.0);
    const double cardElevation = 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Trade' : 'Add New Trade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTrade,
            tooltip: 'Save Trade',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Card 1: Setup ---
              Card(
                margin: cardMargin,
                shape: cardShape,
                color: cardColor,
                elevation: cardElevation,
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Setup', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      pairsAsyncValue.when(
                        data: (pairs) => DropdownButtonFormField<Pair?>(
                          value: _selectedPair,
                          isExpanded: true,
                          decoration: inputDecoration.copyWith(
                            labelText: 'Forex Pair *',
                          ),
                          items: pairs.map((pair) => DropdownMenuItem<Pair?>(
                            value: pair,
                            child: Text(pair.name),
                          )).toList(),
                          onChanged: (Pair? newValue) {
                            setState(() {
                              _selectedPair = newValue;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a pair' : null,
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Text('Error loading pairs: $error'),
                      ),
                      const SizedBox(height: 16),
                      Text('Direction *', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
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
                        selected: _isLong == null ? <bool>{} : <bool>{_isLong!},
                        multiSelectionEnabled: false,
                        emptySelectionAllowed: _isLong == null,
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _isLong = newSelection.isEmpty ? null : newSelection.first;
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                          selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      if (_isLong == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select direction',
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16),
                      strategiesAsyncValue.when(
                        data: (strategies) => DropdownButtonFormField<Strategy?>(
                          value: _selectedStrategy,
                          decoration: inputDecoration.copyWith(
                            labelText: 'Strategy (Optional)',
                          ),
                          items: [
                            const DropdownMenuItem<Strategy?>(
                              value: null,
                              child: Text('Select Strategy (Optional)'),
                            ),
                            ...strategies.map((strategy) => DropdownMenuItem<Strategy?>(
                                  value: strategy,
                                  child: Text(strategy.name),
                                )),
                          ],
                          onChanged: (Strategy? newValue) {
                            setState(() {
                              _selectedStrategy = newValue;
                            });
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Text('Error loading strategies: $error'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _confidenceScore,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Confidence Score (Optional)',
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Select Score (1-5)'),
                          ),
                          ...List.generate(5, (index) => DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text('${index + 1} Star${index == 0 ? '' : 's'}'),
                          )),
                        ],
                        onChanged: (int? newValue) {
                          setState(() {
                            _confidenceScore = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // --- Card 2: Execution ---
              Card(
                margin: cardMargin,
                shape: cardShape,
                color: cardColor,
                elevation: cardElevation,
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Execution', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),

                      // --- NEW: Entry Date/Time Row ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Entry Date & Time *', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 4),
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
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _entryDateTime == null
                                        ? 'Select Date & Time'
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- NEW: Exit Date/Time Row ---
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Exit Date & Time *', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 4),
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
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _exitDateTime == null
                                        ? 'Select Date & Time'
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _entryPriceController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'Entry Price',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _exitPriceController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'Exit Price',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stopLossController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'Stop Loss (Optional)',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _takeProfitController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'Take Profit (Optional)',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lotsController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Position Size (Lots)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Invalid size';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // --- Card 3: Outcome & Notes ---
              Card(
                margin: cardMargin,
                shape: cardShape,
                color: cardColor,
                elevation: cardElevation,
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Outcome & Notes', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _actualPlController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Actual P/L Override (Optional)',
                          helperText: 'Overrides calculation if commission/swaps differ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (double.tryParse(value) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _commissionController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'Commissions (Optional)',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _swapController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'Swaps (Optional)',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonEntryController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Reason for Entry (Optional)',
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonExitController,
                        decoration: inputDecoration.copyWith(
                          labelText: 'Reason for Exit / Management (Optional)',
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      Text('Custom Tags (Optional)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagInputController,
                              decoration: inputDecoration.copyWith(
                                hintText: 'Type a tag and press +',
                              ),
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
                        children: _customTags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setState(() {
                                _customTags.remove(tag);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('Screenshots (Optional)', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () => _showImageSourceActionSheet(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_file, size: 18),
                            SizedBox(width: 8),
                            Text('Attach Screenshot'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _imagePaths.map((path) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  File(path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 100,
                                    height: 100,
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
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initialDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date == null) return null;

    if (!context.mounted) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      if (!_imagePaths.contains(image.path)) {
                        _imagePaths.add(image.path);
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      if (!_imagePaths.contains(image.path)) {
                        _imagePaths.add(image.path);
                      }
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
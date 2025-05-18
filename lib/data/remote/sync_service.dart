import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/database.dart'; // Provides DAOs and Companions
import 'dart:io'; // Import for File class

// --- UPDATED SyncService Class ---
class SyncService {
  final SupabaseClient _supabase;
  // NEW: Hold references to DAOs needed for sync
  final PairDao _pairDao;
  final StrategyDao _strategyDao;
  final TradeDao _tradeDao;

  // UPDATED: Constructor accepts DAOs
  SyncService(this._supabase, this._pairDao, this._strategyDao, this._tradeDao);

  // --- Keep upsertTrade, upsertPair, upsertStrategy methods ---
  Future<void> upsertTrade(TradesCompanion companion, String selectedPairName, String? selectedStrategyName) async { 
    // --- Look up correct Supabase Foreign Keys ---
    final int? correctPairId = await _findSupabaseIdByName('pairs', selectedPairName);
    final int? correctStrategyId = selectedStrategyName == null
        ? null
        : await _findSupabaseIdByName('strategies', selectedStrategyName);

    // Check if required Pair was found in Supabase
    if (correctPairId == null) {
      throw Exception('Failed to sync trade: Pair "$selectedPairName" not found in Supabase. Please ensure it was added via Settings.');
    }
    // If strategy was selected but not found, throw error (or handle differently)
    if (selectedStrategyName != null && correctStrategyId == null) {
       throw Exception('Failed to sync trade: Strategy "$selectedStrategyName" not found in Supabase. Please ensure it was added via Settings.');
    }
    // --- End Lookup ---

    // Convert companion to map
    final supabaseData = _companionToSupabaseMap(companion);

    // --- IMPORTANT: Overwrite IDs in map with correct Supabase IDs ---
    supabaseData['pair_id'] = correctPairId;
    supabaseData['strategy_id'] = correctStrategyId; // Will be null if no strategy selected

    // Add log here to see the final map being sent
    print('>>> EDIT SYNC: Map being sent to Supabase UPSERT: $supabaseData');

    try {
      print('Attempting to upsert trade to Supabase with looked-up FKs: $supabaseData');
      await _supabase.from('trades').upsert(supabaseData);
      print('Supabase upsert successful for trade id: ${supabaseData['id'] ?? 'NEW'}');
    } on PostgrestException catch (e) {
      print('Supabase PostgrestException upserting trade: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unknown error upserting trade to Supabase: $e');
      rethrow;
    }
  }
  Future<int?> upsertPair(PairsCompanion companion) async {
    final supabaseData = _pairCompanionToMap(companion); // Map helper still excludes ID

    try {
      if (companion.id.present) {
        // --- UPDATE ---
        final updateId = companion.id.value;
        print('Attempting to update pair $updateId: $supabaseData');
        await _supabase
            .from('pairs')
            .update(supabaseData) // Use update
            .eq('id', updateId); // Match on ID
        print('Supabase pair update successful for id: $updateId');
        return updateId; // Return the ID we updated
      } else {
        // --- INSERT ---
        print('Attempting to insert pair: $supabaseData');
        // Insert WITHOUT ID, let Supabase generate it, select ID back
        final response = await _supabase
            .from('pairs')
            .insert(supabaseData) // Use insert
            .select('id') // Select the ID
            .single(); // Expect single row back
        final newId = response['id'] as int?;
        print('Supabase pair insert successful, new ID: $newId');
        return newId; // Return the newly generated Supabase ID
      }
    } catch (e) {
      print('Error upserting pair to Supabase: $e');
      rethrow; // Rethrow to be handled by caller
    }
  }
  Future<int?> upsertStrategy(StrategiesCompanion companion) async {
    final supabaseData = _strategyCompanionToMap(companion); // Map helper excludes ID

    try {
      if (companion.id.present) {
        // --- UPDATE ---
        final updateId = companion.id.value;
        print('Attempting to update strategy $updateId: $supabaseData');
        await _supabase
            .from('strategies')
            .update(supabaseData)
            .eq('id', updateId);
        print('Supabase strategy update successful for id: $updateId');
        return updateId;
      } else {
        // --- INSERT ---
        print('Attempting to insert strategy: $supabaseData');
        final response = await _supabase
            .from('strategies')
            .insert(supabaseData)
            .select('id')
            .single();
        final newId = response['id'] as int?;
        print('Supabase strategy insert successful, new ID: $newId');
        return newId;
      }
    } catch (e) {
      print('Error upserting strategy to Supabase: $e');
      rethrow;
    }
  }

  // NEW: Delete Pair from Supabase
  Future<void> deleteSupabasePair(int pairId) async {
    try {
      print('Attempting to delete pair $pairId from Supabase...');
      await _supabase
          .from('pairs')
          .delete()
          .eq('id', pairId); // Delete where ID matches
      print('Supabase pair delete successful for id: $pairId');
    } catch (e) {
       print('Error deleting pair $pairId from Supabase: $e');
      // Decide if error should be re-thrown or handled silently
    }
  }

  // --- Keep _findSupabaseIdByName helper ---
  Future<int?> _findSupabaseIdByName(String tableName, String name) async { 
    try {
      final response = await _supabase
          .from(tableName)
          .select('id') // Select only the ID column
          .eq('name', name) // Find where the name matches
          .limit(1) // We only need one result
          .maybeSingle(); // Return the single row map or null

      if (response != null && response['id'] != null) {
        return response['id'] as int?;
      }
      return null; // Not found
    } catch (e) {
      print("Error finding ID for $name in $tableName: $e");
      return null;
    }
  }

  // --- Keep Map conversion helpers (_companionToSupabaseMap, _pairCompanionToMap, _strategyCompanionToMap) ---
  Map<String, dynamic> _companionToSupabaseMap(TradesCompanion companion) {
     final map = <String, dynamic>{};

     // Helper to add field to map only if it has a value present in the companion
     void addField<T>(String key, Value<T>? value) {
        if (value != null && value.present) {
           // Convert DateTime to ISO8601 string for Supabase timestampz
           if (value.value is DateTime) {
              map[key] = (value.value as DateTime?)?.toIso8601String();
           } else {
             // Add the actual value (could be null if Value(null) was passed)
             map[key] = value.value;
           }
        }
        // Note: If value.present is false, the field is skipped (won't be updated in Supabase)
        // If you want to explicitly set nulls for absent optional fields during updates,
        // you might need different logic here. Upsert usually handles this okay.
     }

     // Map all fields from Drift companion (camelCase) to Supabase map (snake_case)
     addField('id', companion.id);
     addField('pair', companion.pair);
     addField('pair_id', companion.pairId);
     addField('user_id', companion.userId); // Added by clientDefault on insert
     addField('entry_date', companion.entryDate);
     addField('exit_date', companion.exitDate);
     addField('is_long', companion.isLong);
     addField('entry_price', companion.entryPrice);
     addField('exit_price', companion.exitPrice);
     addField('position_size_lots', companion.positionSizeLots);
     addField('stop_loss_price', companion.stopLossPrice);
     addField('take_profit_price', companion.takeProfitPrice);
     addField('actual_profit_loss', companion.actualProfitLoss);
     addField('commission_fees', companion.commissionFees);
     addField('swap_fees', companion.swapFees);
     addField('strategy_id', companion.strategyId);
     addField('strategy_tag', companion.strategyTag);
     addField('reason_for_entry', companion.reasonForEntry);
     addField('reason_for_exit', companion.reasonForExit);
     addField('confidence_score', companion.confidenceScore);
     addField('custom_tags_json', companion.customTagsJson);
     addField('image_paths_json', companion.imagePathsJson);
     addField('created_at', companion.createdAt);
     addField('updated_at', companion.updatedAt);

      // Ensure user_id is present if not set by clientDefault (e.g., during updates)
     if (!map.containsKey('user_id') || map['user_id'] == null) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
         if (userId != null) {
           map['user_id'] = userId;
         } else {
            print("CRITICAL Error: User ID missing when creating Supabase map!");
            // This should ideally not happen in authenticated routes
         }
     }


     return map;
  }

  Map<String, dynamic> _pairCompanionToMap(PairsCompanion companion) {
    final map = <String, dynamic>{};
    if (companion.name.present) map['name'] = companion.name.value;
    if (companion.createdAt.present) map['created_at'] = companion.createdAt.value.toIso8601String();
    return map;
  }

  Map<String, dynamic> _strategyCompanionToMap(StrategiesCompanion companion) {
    final map = <String, dynamic>{};
    if (companion.name.present) map['name'] = companion.name.value;
    map['description'] = companion.description.present ? companion.description.value : null;
    if (companion.createdAt.present) map['created_at'] = companion.createdAt.value.toIso8601String();
    return map;
  }

  // --- Keep Fetch Methods (they only use _supabase) ---
  Future<List<PairsCompanion>> fetchAllPairs() async { 
    try {
      print('Fetching all pairs from Supabase...');
      final List<Map<String, dynamic>> data = await _supabase.from('pairs').select();
      print('Fetched ${data.length} pairs.');
      return data.map((map) => _supabaseMapToPairCompanion(map)).toList();
    } catch (e) {
      print('Error fetching pairs from Supabase: $e');
      return []; // Return empty list on error
    }
  }
  Future<List<StrategiesCompanion>> fetchAllStrategies() async { 
    try {
      print('Fetching all strategies from Supabase...');
      final List<Map<String, dynamic>> data = await _supabase.from('strategies').select();
      print('Fetched ${data.length} strategies.');
      return data.map((map) => _supabaseMapToStrategyCompanion(map)).toList();
    } catch (e) {
      print('Error fetching strategies from Supabase: $e');
      return [];
    }
  }
  Future<List<TradesCompanion>> fetchCurrentUserTrades() async { 
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return []; // Should not happen if called when logged in
      print('Fetching trades for user $userId from Supabase...');
      final List<Map<String, dynamic>> data = await _supabase
          .from('trades')
          .select(); // Supabase RLS handles filtering by user_id implicitly
      print('Fetched ${data.length} trades.');
      return data.map((map) => _supabaseMapToTradeCompanion(map)).toList();
    } catch (e) {
      print('Error fetching trades from Supabase: $e');
      return [];
    }
  }

  // --- Keep Supabase Map -> Drift Companion Converters ---
  PairsCompanion _supabaseMapToPairCompanion(Map<String, dynamic> map) { 
    return PairsCompanion(
      id: Value(map['id'] as int),
      name: Value(map['name'] as String),
      createdAt: Value(DateTime.parse(map['created_at'] as String)),
    );
  }
  StrategiesCompanion _supabaseMapToStrategyCompanion(Map<String, dynamic> map) { 
    return StrategiesCompanion(
      id: Value(map['id'] as int),
      name: Value(map['name'] as String),
      description: Value(map['description'] as String?),
      createdAt: Value(DateTime.parse(map['created_at'] as String)),
    );
  }
  TradesCompanion _supabaseMapToTradeCompanion(Map<String, dynamic> map) { 
    double? parseDouble(dynamic value) => value == null ? null : double.tryParse(value.toString());
    int? parseInt(dynamic value) => value == null ? null : int.tryParse(value.toString());

    return TradesCompanion(
      id: Value(map['id'] as int),
      pair: Value(map['pair'] as String),
      pairId: Value(map['pair_id'] as int),
      userId: Value(map['user_id'] as String),
      entryDate: Value(DateTime.parse(map['entry_date'] as String)),
      exitDate: Value(DateTime.parse(map['exit_date'] as String)),
      isLong: Value(map['is_long'] as bool),
      entryPrice: Value(parseDouble(map['entry_price'])!),
      exitPrice: Value(parseDouble(map['exit_price'])!),
      positionSizeLots: Value(parseDouble(map['position_size_lots'])!),
      stopLossPrice: Value(parseDouble(map['stop_loss_price'])),
      takeProfitPrice: Value(parseDouble(map['take_profit_price'])),
      actualProfitLoss: Value(parseDouble(map['actual_profit_loss'])),
      commissionFees: Value(parseDouble(map['commission_fees'])),
      swapFees: Value(parseDouble(map['swap_fees'])),
      strategyId: Value(parseInt(map['strategy_id'])),
      strategyTag: Value(map['strategy_tag'] as String?),
      reasonForEntry: Value(map['reason_for_entry'] as String?),
      reasonForExit: Value(map['reason_for_exit'] as String?),
      confidenceScore: Value(parseInt(map['confidence_score'])),
      customTagsJson: Value(map['custom_tags_json'] as String?),
      imagePathsJson: Value(map['image_paths_json'] as String?),
      createdAt: Value(DateTime.parse(map['created_at'] as String)),
      updatedAt: Value(DateTime.parse(map['updated_at'] as String)),
    );
  }

  // --- NEW/UPDATED: performInitialSync no longer needs ref ---
  Future<void> performInitialSync() async { // REMOVED 'Reader read' parameter
    print('Starting initial sync...');
    try {
      // Fetch and Upsert Pairs
      final pairCompanions = await fetchAllPairs();
      if (pairCompanions.isNotEmpty) {
        await _pairDao.bulkUpsertPairs(pairCompanions);
      }

      // Fetch and Upsert Strategies
      final strategyCompanions = await fetchAllStrategies();
      if (strategyCompanions.isNotEmpty) {
        await _strategyDao.bulkUpsertStrategies(strategyCompanions);
      }

      // Fetch and Upsert Trades
      final tradeCompanions = await fetchCurrentUserTrades();
      if (tradeCompanions.isNotEmpty) {
        await _tradeDao.bulkUpsertTrades(tradeCompanions);
      }

      print('Initial sync completed successfully.');
    } catch (e) {
      print('Initial sync failed: $e');
    }
  } // End performInitialSync

  // NEW: Upload Image and Get URL
  Future<String?> uploadTradeImage({
    required String localPath,
    required String userId,
    required int tradeId,
  }) async {
    try {
      print('Uploading image: $localPath');
      final file = File(localPath);
      // Create a unique path in Supabase storage
      // e.g., user_id/trade_id/timestamp_filename.ext
      final fileExt = localPath.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final supabasePath = '$userId/$tradeId/$fileName';

      final storageBucket = _supabase.storage.from('trade.screenshots'); // Use your bucket name

      // Upload the file
      await storageBucket.upload(
        supabasePath,
        file,
        // Optional: Set content type, cache control etc.
        fileOptions: FileOptions(cacheControl: '3600', upsert: false, contentType: 'image/$fileExt'),
      );
      print('Image upload successful: $supabasePath');

      // Get the public URL for the uploaded file
      final String publicUrl = storageBucket.getPublicUrl(supabasePath);
      print('Public URL: $publicUrl');
      return publicUrl;

    } catch (e) {
      print('Error uploading image $localPath: $e');
      return null; // Return null on error
    }
  }

  // NEW: Delete Strategy from Supabase
  Future<void> deleteSupabaseStrategy(int strategyId) async {
    try {
      print('Attempting to delete strategy $strategyId from Supabase...');
      await _supabase
          .from('strategies')
          .delete()
          .eq('id', strategyId); // Delete where ID matches
      print('Supabase strategy delete successful for id: $strategyId');
    } catch (e) {
       print('Error deleting strategy $strategyId from Supabase: $e');
      // Decide if error should be re-thrown or handled silently
      // rethrow;
    }
  }
} // End SyncService class

// --- UPDATED: syncServiceProvider ---
// Now reads the DAO providers and passes them to the SyncService constructor
final syncServiceProvider = Provider<SyncService>((ref) {
  final supabaseClient = Supabase.instance.client;
  // Read the DAO providers needed by SyncService
  final pairDao = ref.read(pairDaoProvider);
  final strategyDao = ref.read(strategyDaoProvider);
  final tradeDao = ref.read(tradeDaoProvider);
  // Create SyncService instance with all dependencies
  return SyncService(supabaseClient, pairDao, strategyDao, tradeDao);
});

// NOTE: performInitialSync function is now a METHOD inside SyncService
// Delete the standalone performInitialSync function if you still have it outside the class
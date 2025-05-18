import 'dart:io';
import 'dart:convert'; // Import for json encoding/decoding later if needed

import 'package:drift/drift.dart'; // Ensure full import for all Drift symbols
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Keep Riverpod import
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for auth info

// Import generated file (will show error initially)
part 'database.g.dart'; // Instructs Drift how to name the generated file

// Define the table structure
@DataClassName('Strategy') // Generated class will be named Strategy
class Strategies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 1)(); // Strategy names must be unique
  TextColumn get description => text().nullable()(); // Optional description
  TextColumn get userId => text().clientDefault(() => Supabase.instance.client.auth.currentUser!.id)(); // Added userId
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// NEW: Pairs Table Definition
@DataClassName('Pair')
class Pairs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 6)(); // e.g., EURUSD
  TextColumn get userId => text().clientDefault(() => Supabase.instance.client.auth.currentUser!.id)(); // Added userId
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Trade') // Sets the name of the generated data class
class Trades extends Table {
  // Primary Key
  IntColumn get id => integer().autoIncrement()();

  // Mandatory Fields
  TextColumn get pair => text().withLength(min: 6, max: 10)(); // e.g., EURUSD, GBPJPY
  IntColumn get pairId => integer().references(Pairs, #id)(); // NEW: Foreign key to Pairs table
  // NEW: User ID column - links trade to the logged-in user
  TextColumn get userId => text().clientDefault(() => Supabase.instance.client.auth.currentUser!.id)();
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get exitDate => dateTime()();
  BoolColumn get isLong => boolean()(); // true for Long, false for Short
  RealColumn get entryPrice => real()();
  RealColumn get exitPrice => real()();
  RealColumn get positionSizeLots => real()();

  // Optional but Crucial Fields
  RealColumn get stopLossPrice => real().nullable()(); // Use nullable() for optional fields
  RealColumn get takeProfitPrice => real().nullable()();
  RealColumn get actualProfitLoss => real().nullable()(); // In account currency
  RealColumn get commissionFees => real().nullable()();
  RealColumn get swapFees => real().nullable()();

  // Enrichment Fields
  TextColumn get strategyTag => text().nullable()(); // Keep old one temporarily, or remove if desired
  IntColumn get strategyId => integer().nullable().references(Strategies, #id)(); // Foreign key to Strategies table
  TextColumn get reasonForEntry => text().nullable()();
  TextColumn get reasonForExit => text().nullable()();
  IntColumn get confidenceScore => integer().nullable()(); // e.g., 1-5
  TextColumn get customTagsJson => text().nullable()(); // Storing list/set of tags as JSON string
  TextColumn get imagePathsJson => text().nullable()(); // Storing list of image file paths as JSON string

  // Timestamps for tracking
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// --- NEW: Define the TradeDao ---
@DriftAccessor(tables: [Trades]) // Specify which tables this DAO accesses
class TradeDao extends DatabaseAccessor<AppDatabase> with _$TradeDaoMixin {
  // This constructor is required
  TradeDao(AppDatabase db) : super(db);

  // Method to watch all trades (returns a stream for live updates)
  Stream<List<Trade>> watchAllTrades() => select(trades).watch();

  // Method to get all trades once (returns a future)
  Future<List<Trade>> getAllTrades() => select(trades).get();

  // UPDATE: Change return type from Future<int> to Future<Trade>
  // Use insertReturning to get the full object back
  Future<Trade> insertTrade(TradesCompanion trade) =>
      into(trades).insertReturning(trade);

  // Method to update a trade
  Future<bool> updateTrade(TradesCompanion trade) => update(trades).replace(trade);

  // Method to delete a trade
  Future<int> deleteTrade(int id) => (delete(trades)..where((t) => t.id.equals(id))).go();

  // NEW: Method to get unique pair strings from logged trades
  Future<List<String>> getUniquePairs() async {
    final query = selectOnly(trades, distinct: true)..addColumns([trades.pair]);
    // Execute query - row.read might return String?
    final resultsWithNulls = await query.map((row) => row.read(trades.pair)).get();
    // Filter out any potential null values and ensure the final type is List<String>
    final results = resultsWithNulls.whereType<String>().toList();
    return results;
  }

  // NEW: Method to watch a single trade by ID (returns null if not found)
  Stream<Trade?> watchTradeById(int id) {
    return (select(trades)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  // UPDATE signature and add where clauses
  Stream<List<Trade>> watchFilteredTrades({
    DateTime? startDate,
    DateTime? endDate,
    int? pairId, // NEW parameter
    int? strategyId, // NEW parameter
    bool? isLong, // NEW parameter
  }) {
    var query = select(trades);

    // Keep date filters
    if (startDate != null) {
      query.where((t) => t.entryDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day + 1);
      query.where((t) => t.entryDate.isSmallerThanValue(endOfDay));
    }

    // NEW: Add filters for pair and strategy if provided
    if (pairId != null) {
      query.where((t) => t.pairId.equals(pairId));
    }
    if (strategyId != null) {
      query.where((t) => t.strategyId.equals(strategyId));
    }

    // NEW: Add filter for direction if provided
    if (isLong != null) {
      query.where((t) => t.isLong.equals(isLong));
    }

    // Keep sorting
    query.orderBy([(t) => OrderingTerm(expression: t.entryDate)]);

    return query.watch();
  }

  // --- We will add more specific query methods here later (e.g., filter by date, pair) ---

  Future<void> bulkUpsertTrades(List<TradesCompanion> data) async {
    await batch((b) {
      b.insertAll(trades, data, mode: InsertMode.insertOrReplace);
    });
    print('Bulk upserted ${data.length} trades locally.');
  }
}

// --- NEW: Define the StrategyDao ---
@DriftAccessor(tables: [Strategies])
class StrategyDao extends DatabaseAccessor<AppDatabase> with _$StrategyDaoMixin {
  StrategyDao(AppDatabase db) : super(db);

  // Watch all strategies for live updates
  Stream<List<Strategy>> watchAllStrategies() => select(strategies).watch();

  // Get all strategies once
  Future<List<Strategy>> getAllStrategies() => select(strategies).get();

  // Insert a new strategy (returns the generated ID)
  Future<Strategy> insertStrategy(StrategiesCompanion strategy) => into(strategies).insertReturning(strategy);

  // NEW: Update an existing strategy
  Future<bool> updateStrategy(StrategiesCompanion strategy) =>
      update(strategies).replace(strategy);

  // NEW: Delete a strategy by its ID
  Future<int> deleteStrategy(int id) =>
      (delete(strategies)..where((s) => s.id.equals(id))).go();

  Future<void> bulkUpsertStrategies(List<StrategiesCompanion> data) async {
    await batch((b) {
      b.insertAll(strategies, data, mode: InsertMode.insertOrReplace);
    });
    print('Bulk upserted ${data.length} strategies locally.');
  }
}

// NEW: PairDao Definition
@DriftAccessor(tables: [Pairs])
class PairDao extends DatabaseAccessor<AppDatabase> with _$PairDaoMixin {
  PairDao(AppDatabase db) : super(db);

  Stream<List<Pair>> watchAllPairs() => select(pairs).watch();
  Future<List<Pair>> getAllPairs() => select(pairs).get();
  Future<Pair> insertPair(PairsCompanion pair) => into(pairs).insertReturning(pair);
  Future<int> deletePair(int id) => (delete(pairs)..where((p) => p.id.equals(id))).go();
  Future<bool> updatePair(PairsCompanion companion) => update(pairs).replace(companion);

  // NEW: Get a single pair by ID
  Future<Pair?> getPairById(int id) =>
      (select(pairs)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<void> bulkUpsertPairs(List<PairsCompanion> data) async {
    await batch((b) {
      b.insertAll(pairs, data, mode: InsertMode.insertOrReplace);
    });
    print('Bulk upserted ${data.length} pairs locally.');
  }
}

// Define the Database Class
@DriftDatabase(
  tables: [Trades, Strategies, Pairs], // Add Pairs table
  daos: [TradeDao, StrategyDao, PairDao] // Add PairDao
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; // Incremented schema version

  // NEW: Add migration logic
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // This runs if the database is created for the first time
        await m.createAll(); // Creates all tables defined in tables: [...]
        // Optionally add default data here if needed on fresh install
      },
      onUpgrade: (Migrator m, int from, int to) async {
        print('Migrating database from $from to $to');
        if (from == 1) {
          // We are migrating from version 1 to 2
          // Create the new strategies table
          await m.createTable(strategies);
          // Add the new strategyId column to the existing trades table
          await m.addColumn(trades, trades.strategyId);
          print('Migration from v1 to v2 complete: Added strategies table and trades.strategyId column.');
        }
        if (from < 3) { // Changes for version 3
          await m.createTable(pairs);
          await m.addColumn(trades, trades.pairId);
          print('Migration from v2 to v3 complete.');
        }
        // NEW: Migration for version 4
        if (from < 4) {
          await m.addColumn(this.trades, this.trades.userId);
          print('Migration from v3 to v4 complete: Added trades.userId column.');
        }

        // Revised block for version 5
        if (from < 5) {
          await m.addColumn(
            this.pairs,
            GeneratedColumn<String>(
              'user_id', 
              this.pairs.actualTableName, 
              false, 
              clientDefault: () => Supabase.instance.client.auth.currentUser!.id,
              type: DriftSqlType.string,
            ),
          );
          await m.addColumn(
            this.strategies,
            GeneratedColumn<String>(
              'user_id', 
              this.strategies.actualTableName, 
              false, 
              clientDefault: () => Supabase.instance.client.auth.currentUser!.id,
              type: DriftSqlType.string,
            ),
          );
          print('Migration from v4 to v5 complete: Added userId to pairs and strategies.');
        }
        // Add more 'if (from == x)' blocks for future migrations
      },
    );
  }
}

// Function to open the database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'forex_journal_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// Define a Provider for our database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  // This creates a single instance of AppDatabase when first requested
  // and provides the same instance afterwards.
  return AppDatabase();
});

// NEW: Provider for the TradeDao instance
final tradeDaoProvider = Provider<TradeDao>((ref) {
  // Watch the main database provider
  final db = ref.watch(databaseProvider);
  // Access the dao instance from the database
  return db.tradeDao; // Drift generates this getter
});

// NEW: Provider for the StrategyDao instance
final strategyDaoProvider = Provider<StrategyDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.strategyDao; // Drift generates this
});

// NEW: Provider for the PairDao instance
final pairDaoProvider = Provider<PairDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.pairDao;
});

// NEW LOCATION for the provider:
final allStrategiesStreamProvider = StreamProvider.autoDispose<List<Strategy>>((ref) {
  // Now watch the provider defined just above
  return ref.watch(strategyDaoProvider).watchAllStrategies();
});

// NEW: All Pairs Stream Provider
final allPairsStreamProvider = StreamProvider.autoDispose<List<Pair>>((ref) {
  return ref.watch(pairDaoProvider).watchAllPairs();
});

// Change this provider to remove .autoDispose
final allTradesStreamProvider = StreamProvider<List<Trade>>((ref) {
  // Now watch the provider defined just above
  return ref.watch(tradeDaoProvider).watchAllTrades();
});

// NEW: Provider family to watch a single trade by its ID
final tradeProviderFamily = StreamProvider.autoDispose.family<Trade?, int>((ref, tradeId) {
  // Watches the DAO method, passing the tradeId parameter
  return ref.watch(tradeDaoProvider).watchTradeById(tradeId);
});

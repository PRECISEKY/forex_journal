import 'dart:math'; // For max()
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // For dialog navigation if needed later
import 'package:intl/intl.dart';
// Adjust import path as necessary
import '../../data/local/database.dart';

// --- Report Page Filter State Providers ---
// Independent state for the Report page filters
final reportStartDateProvider = StateProvider.autoDispose<DateTime?>((ref) => null);
final reportEndDateProvider = StateProvider.autoDispose<DateTime?>((ref) => null);
final reportSelectedPairProvider = StateProvider.autoDispose<Pair?>((ref) => null);
final reportSelectedStrategyProvider = StateProvider.autoDispose<Strategy?>((ref) => null);
final reportDirectionFilterProvider = StateProvider.autoDispose<bool?>((ref) => null);

// --- Report Page Data Provider ---
// Fetches trades based ONLY on the report page's filters
final reportFilteredTradesProvider = StreamProvider.autoDispose<List<Trade>>((ref) {
  // Watch report-specific filters
  final startDate = ref.watch(reportStartDateProvider);
  final endDate = ref.watch(reportEndDateProvider);
  final selectedPair = ref.watch(reportSelectedPairProvider);
  final selectedStrategy = ref.watch(reportSelectedStrategyProvider);
  final selectedDirection = ref.watch(reportDirectionFilterProvider);
  // Get the DAO
  final tradeDao = ref.watch(tradeDaoProvider);

  // Call DAO method with report filters
  return tradeDao.watchFilteredTrades(
    startDate: startDate,
    endDate: endDate,
    pairId: selectedPair?.id,
    strategyId: selectedStrategy?.id,
    isLong: selectedDirection,
  );
});

// --- Report Page Basic Metric Providers ---
// Calculate metrics based only on reportFilteredTradesProvider

final reportTotalTradesProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(reportFilteredTradesProvider).maybeWhen(
      data: (trades) => trades.length, orElse: () => 0);
});

final reportNetPLProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(reportFilteredTradesProvider).maybeWhen(
      data: (trades) => trades.fold(0.0, (sum, t) => sum + (t.actualProfitLoss ?? 0.0)),
      orElse: () => 0.0);
});

final reportWinCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(reportFilteredTradesProvider).maybeWhen(
      data: (trades) => trades.where((t) => (t.actualProfitLoss ?? 0.0) > 0).length,
      orElse: () => 0);
});

final reportLossCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(reportFilteredTradesProvider).maybeWhen(
      data: (trades) => trades.where((t) => (t.actualProfitLoss ?? 0.0) < 0).length,
      orElse: () => 0);
});

final reportWinRateProvider = Provider.autoDispose<double>((ref) {
  final wins = ref.watch(reportWinCountProvider);
  final losses = ref.watch(reportLossCountProvider);
  final totalClosed = wins + losses;
  return totalClosed == 0 ? 0.0 : (wins / totalClosed) * 100.0;
});

// --- NEW Report Page Metric Providers ---

final reportBreakEvenTradesProvider = Provider.autoDispose<int>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  return trades.where((t) => (t.actualProfitLoss ?? 0.0).abs() < 0.0001).length;
});

final reportTotalCommissionsProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(reportFilteredTradesProvider).maybeWhen(
      data: (trades) => trades.fold(0.0, (sum, t) => sum + (t.commissionFees ?? 0.0)),
      orElse: () => 0.0);
});

final reportTotalSwapsProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(reportFilteredTradesProvider).maybeWhen(
      data: (trades) => trades.fold(0.0, (sum, t) => sum + (t.swapFees ?? 0.0)),
      orElse: () => 0.0);
});

final reportTotalFeesProvider = Provider.autoDispose<double>((ref) {
  final commissions = ref.watch(reportTotalCommissionsProvider);
  final swaps = ref.watch(reportTotalSwapsProvider);
  return commissions + swaps;
});

final reportAvgWinHoldTimeProvider = Provider.autoDispose<Duration>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  final winningTrades = trades.where((t) => (t.actualProfitLoss ?? 0.0) > 0).toList();
  if (winningTrades.isEmpty) return Duration.zero;
  Duration totalDuration = Duration.zero;
  int validCount = 0;
  for (final trade in winningTrades) {
    if (trade.exitDate.isAfter(trade.entryDate)) {
      totalDuration += trade.exitDate.difference(trade.entryDate);
      validCount++;
    }
  }
  return validCount == 0 ? Duration.zero : Duration(microseconds: totalDuration.inMicroseconds ~/ validCount);
});

final reportAvgLossHoldTimeProvider = Provider.autoDispose<Duration>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  final losingTrades = trades.where((t) => (t.actualProfitLoss ?? 0.0) < 0).toList();
  if (losingTrades.isEmpty) return Duration.zero;
  Duration totalDuration = Duration.zero;
  int validCount = 0;
  for (final trade in losingTrades) {
    if (trade.exitDate.isAfter(trade.entryDate)) {
      totalDuration += trade.exitDate.difference(trade.entryDate);
      validCount++;
    }
  }
  return validCount == 0 ? Duration.zero : Duration(microseconds: totalDuration.inMicroseconds ~/ validCount);
});

final reportAvgTradePlProvider = Provider.autoDispose<double>((ref) {
  final totalTrades = ref.watch(reportTotalTradesProvider);
  if (totalTrades == 0) return 0.0;
  final netPL = ref.watch(reportNetPLProvider);
  return netPL / totalTrades;
});

final reportAvgWinPlProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  final winningTrades = trades.where((t) => (t.actualProfitLoss ?? 0.0) > 0).toList();
  if (winningTrades.isEmpty) return 0.0;
  return winningTrades.fold(0.0, (sum, t) => sum + (t.actualProfitLoss ?? 0.0)) / winningTrades.length;
});

final reportAvgLossPlProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  final losingTrades = trades.where((t) => (t.actualProfitLoss ?? 0.0) < 0).toList();
  if (losingTrades.isEmpty) return 0.0;
  return losingTrades.fold(0.0, (sum, t) => sum + (t.actualProfitLoss ?? 0.0)) / losingTrades.length;
});

final reportProfitFactorProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  final grossProfit = trades.where((t) => (t.actualProfitLoss ?? 0.0) > 0).fold(0.0, (sum, t) => sum + (t.actualProfitLoss ?? 0.0));
  final grossLoss = trades.where((t) => (t.actualProfitLoss ?? 0.0) < 0).fold(0.0, (sum, t) => sum + (t.actualProfitLoss ?? 0.0)).abs();
  return grossLoss == 0.0 ? 0.0 : grossProfit / grossLoss;
});

final reportAvgHoldingTimeProvider = Provider.autoDispose<Duration>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  if (trades.isEmpty) return Duration.zero;
  Duration totalDuration = Duration.zero;
  int validCount = 0;
  for (final trade in trades) {
    if (trade.exitDate.isAfter(trade.entryDate)) {
      totalDuration += trade.exitDate.difference(trade.entryDate);
      validCount++;
    }
  }
  return validCount == 0 ? Duration.zero : Duration(microseconds: totalDuration.inMicroseconds ~/ validCount);
});

final reportLargestWinProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  final winningPLs = trades
      .map((t) => t.actualProfitLoss ?? 0.0)
      .where((pl) => pl > 0);
  if (winningPLs.isEmpty) {
    return 0.0;
  }
  return winningPLs.reduce(max); 
});

final reportLargestLossProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  final losingPLs = trades
      .map((t) => t.actualProfitLoss ?? 0.0)
      .where((pl) => pl < 0);
  if (losingPLs.isEmpty) {
    return 0.0;
  }      
  return losingPLs.reduce(min);
});

final reportExpectancyProvider = Provider.autoDispose<double>((ref) {
  final winRate = ref.watch(reportWinRateProvider) / 100.0;
  final avgWin = ref.watch(reportAvgWinPlProvider);
  final avgLoss = ref.watch(reportAvgLossPlProvider).abs();
  return (winRate * avgWin) - ((1 - winRate) * avgLoss);
});

// --- DailyPLDataPoint Class ---
class DailyPLDataPoint {
  final DateTime date;
  final double totalPL;

  DailyPLDataPoint({required this.date, required this.totalPL});
}

// --- Daily Stats Providers ---
final dailyPLProvider = Provider.autoDispose<List<DailyPLDataPoint>>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  final Map<DateTime, double> dailyPLMap = {};

  for (final trade in trades) {
    final date = DateTime(trade.exitDate.year, trade.exitDate.month, trade.exitDate.day);
    dailyPLMap[date] = (dailyPLMap[date] ?? 0.0) + (trade.actualProfitLoss ?? 0.0);
  }

  return dailyPLMap.entries
      .map((entry) => DailyPLDataPoint(date: entry.key, totalPL: entry.value))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

final reportTotalTradingDaysProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(dailyPLProvider).length;
});

final reportWinningDaysProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(dailyPLProvider).where((d) => d.totalPL > 0.0001).length;
});

final reportLosingDaysProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(dailyPLProvider).where((d) => d.totalPL < -0.0001).length;
});

final reportBreakevenDaysProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(dailyPLProvider).where((d) => d.totalPL.abs() < 0.0001).length;
});

final reportAvgDailyPlProvider = Provider.autoDispose<double>((ref) {
  final totalDays = ref.watch(reportTotalTradingDaysProvider);
  if (totalDays == 0) return 0.0;
  final netPL = ref.watch(reportNetPLProvider);
  return netPL / totalDays;
});

// --- Streaks Providers ---
int _calculateMaxConsecutive(List<Trade> trades, bool countWins) {
  if (trades.isEmpty) return 0;
  int maxCount = 0;
  int currentCount = 0;

  for (final trade in trades) {
    final pl = trade.actualProfitLoss ?? 0.0;
    bool isMatch = countWins ? (pl > 0) : (pl < 0);

    if (isMatch) {
      currentCount++;
    } else {
      maxCount = max(maxCount, currentCount);
      if (pl != 0) currentCount = 0;
    }
  }

  return max(maxCount, currentCount);
}

final reportMaxConsecutiveWinsProvider = Provider.autoDispose<int>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  return _calculateMaxConsecutive(trades, true);
});

final reportMaxConsecutiveLossesProvider = Provider.autoDispose<int>((ref) {
  final trades = ref.watch(reportFilteredTradesProvider).valueOrNull ?? [];
  return _calculateMaxConsecutive(trades, false);
});

// --- ReportPage Widget ---

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  // --- Copied and MODIFIED Dialog/Picker Functions ---
  // These now read/write the report-specific providers

  Future<void> _showDateRangeFilterDialog(BuildContext context, WidgetRef ref, DateTime? currentStart, DateTime? currentEnd) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: currentStart != null && currentEnd != null
          ? DateTimeRange(start: currentStart, end: currentEnd)
          : null,
    );
    if (picked != null) {
      ref.read(reportStartDateProvider.notifier).state = picked.start; // Use report provider
      ref.read(reportEndDateProvider.notifier).state = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59); // Use report provider
    }
  }

  Future<void> _showPairFilterDialog(BuildContext context, WidgetRef ref, List<Pair> allPairs, Pair? currentSelection) async {
    await showDialog<Pair?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Pair'),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          content: DropdownButton<Pair?>(
            value: currentSelection,
            hint: const Text('All Pairs'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<Pair?>(value: null, child: Text('All Pairs')),
              ...allPairs.map((p) => DropdownMenuItem<Pair?>(value: p, child: Text(p.name))),
            ],
            onChanged: (Pair? newValue) {
              ref.read(reportSelectedPairProvider.notifier).state = newValue; // Use report provider
              Navigator.of(context).pop();
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
        );
      },
    );
  }

  Future<void> _showStrategyFilterDialog(BuildContext context, WidgetRef ref, List<Strategy> allStrategies, Strategy? currentSelection) async {
    await showDialog<Strategy?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Strategy'),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          content: DropdownButton<Strategy?>(
            value: currentSelection,
            hint: const Text('All Strategies'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<Strategy?>(value: null, child: Text('All Strategies')),
              ...allStrategies.map((s) => DropdownMenuItem<Strategy?>(value: s, child: Text(s.name))),
            ],
            onChanged: (Strategy? newValue) {
              ref.read(reportSelectedStrategyProvider.notifier).state = newValue; // Use report provider
              Navigator.of(context).pop();
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {// Starting brace of the function
  return Padding(
    // Keep existing padding:
    padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
    child: Text(
      // Make title uppercase like the reference image's "Actions" header:
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith( // Use titleSmall style
            fontWeight: FontWeight.w800, // Make it bold
            color: const Color.fromARGB(255, 255, 255, 255), // Use the primary theme color
            letterSpacing: 0.8, // Add a little space between letters
          ),
    ),
  );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- WATCH PROVIDERS needed for UI ---
    // Filter States
    final startDate = ref.watch(reportStartDateProvider);
    final endDate = ref.watch(reportEndDateProvider);
    final selectedPair = ref.watch(reportSelectedPairProvider);
    final selectedStrategy = ref.watch(reportSelectedStrategyProvider);
    final selectedDirection = ref.watch(reportDirectionFilterProvider);

    // Data for Filter Dropdowns
    final allPairsAsync = ref.watch(allPairsStreamProvider);
    final allStrategiesAsync = ref.watch(allStrategiesStreamProvider);

    // Main Data Stream (for loading/error state and metric providers)
    final filteredTradesAsyncValue = ref.watch(reportFilteredTradesProvider);

    // Basic Metrics calculated from filteredTradesProvider
    final totalTrades = ref.watch(reportTotalTradesProvider);
    final netPL = ref.watch(reportNetPLProvider);
    final winRate = ref.watch(reportWinRateProvider);

    // NEW: Watch all the detailed metric providers
    final reportWins = ref.watch(reportWinCountProvider);
    final reportLosses = ref.watch(reportLossCountProvider);
    final reportBE = ref.watch(reportBreakEvenTradesProvider);
    final reportTotalComm = ref.watch(reportTotalCommissionsProvider);
    final reportTotalSwap = ref.watch(reportTotalSwapsProvider);
    final reportTotalFees = ref.watch(reportTotalFeesProvider);
    final reportAvgWinTime = ref.watch(reportAvgWinHoldTimeProvider);
    final reportAvgLossTime = ref.watch(reportAvgLossHoldTimeProvider);
    final reportAvgTradePl = ref.watch(reportAvgTradePlProvider);
    final reportAvgWinPl = ref.watch(reportAvgWinPlProvider);
    final reportAvgLossPl = ref.watch(reportAvgLossPlProvider);
    final reportProfitFactor = ref.watch(reportProfitFactorProvider);
    final reportAvgHoldTime = ref.watch(reportAvgHoldingTimeProvider);
    final reportLargestWin = ref.watch(reportLargestWinProvider);
    final reportLargestLoss = ref.watch(reportLargestLossProvider);
    final reportExpectancy = ref.watch(reportExpectancyProvider);

    // NEW: Watch daily stats and streaks providers
    final totalTradingDays = ref.watch(reportTotalTradingDaysProvider);
    final winningDays = ref.watch(reportWinningDaysProvider);
    final losingDays = ref.watch(reportLosingDaysProvider);
    final breakevenDays = ref.watch(reportBreakevenDaysProvider);
    final avgDailyPL = ref.watch(reportAvgDailyPlProvider);
    final maxConsecutiveWins = ref.watch(reportMaxConsecutiveWinsProvider);
    final maxConsecutiveLosses = ref.watch(reportMaxConsecutiveLossesProvider);

    // --- FORMATTERS ---
    final dateFormat = DateFormat.yMd();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final percentFormat = NumberFormat("##0.0#", "en_US");
    final numberFormat = NumberFormat("##0.0#", "en_US");

    // --- CARD STYLING ---
    final cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
    final cardColor = Theme.of(context).colorScheme.surfaceContainerLow; // Use .surface instead
    const double cardElevation = 0.0;

    // --- SCAFFOLD & BODY STRUCTURE ---
    return Scaffold(
      // AppBar is provided by HomePage

      body: Column( // Main vertical layout
        children: [

          // --- 1. Filter Section (Fixed at Top) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
            child: Card(
              shape: cardShape, color: cardColor, elevation: cardElevation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                       // Date Filter Chip
                      _FilterChipWidget(
                        label: 'Dates:',
                        value: (startDate == null && endDate == null) ? 'All Time' : '${startDate != null ? dateFormat.format(startDate) : '...'} - ${endDate != null ? dateFormat.format(endDate) : '...'}',
                        onTap: () => _showDateRangeFilterDialog(context, ref, startDate, endDate),
                      ),
                      const SizedBox(width: 8),
                       // Pair Filter Chip
                      allPairsAsync.when(
                        data: (pairs) => _FilterChipWidget(label: 'Pair:', value: selectedPair?.name ?? 'All Pairs', onTap: () => _showPairFilterDialog(context, ref, pairs, selectedPair)),
                        loading: () => const ActionChip(label: Text('Pair: Loading...'), onPressed: null),
                        error: (e, s) => ActionChip(label: Text('Pair: Err'), onPressed: null),
                      ),
                      const SizedBox(width: 8),
                       // Strategy Filter Chip
                      allStrategiesAsync.when(
                        data: (strategies) => _FilterChipWidget(label: 'Strategy:', value: selectedStrategy?.name ?? 'All Strategies', onTap: () => _showStrategyFilterDialog(context, ref, strategies, selectedStrategy)),
                        loading: () => const ActionChip(label: Text('Strategy: Loading...'), onPressed: null),
                        error: (e, s) => ActionChip(label: Text('Strategy: Err'), onPressed: null),
                      ),
                       const SizedBox(width: 8),
                        // Direction Filter Segmented Button
                        Consumer( builder: (context, ref, _) {
                          final currentDir = ref.watch(reportDirectionFilterProvider);
                          return SegmentedButton<bool?>(
                             style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                             showSelectedIcon: false,
                             segments: const [
                                ButtonSegment<bool?>(value: null, label: Text('All')),
                                ButtonSegment<bool?>(value: true, label: Text('Long')),
                                ButtonSegment<bool?>(value: false, label: Text('Short')),
                             ],
                             selected: <bool?>{currentDir},
                             multiSelectionEnabled: false,
                             emptySelectionAllowed: true,
                             onSelectionChanged: (Set<bool?> newSelection) { ref.read(reportDirectionFilterProvider.notifier).state = newSelection.first; },
                           );
                         }),
                      // Clear All Button (might need Spacer if layout allows)
                      // const Spacer(), // Add if Row has extra space
                       IconButton(
                         icon: const Icon(Icons.clear_all),
                         tooltip: 'Clear All Filters', iconSize: 20, visualDensity: VisualDensity.compact,
                         onPressed: () {
                           ref.read(reportStartDateProvider.notifier).state = null;
                           ref.read(reportEndDateProvider.notifier).state = null;
                           ref.read(reportSelectedPairProvider.notifier).state = null;
                           ref.read(reportSelectedStrategyProvider.notifier).state = null;
                           ref.read(reportDirectionFilterProvider.notifier).state = null;
                         },
                       )
                    ],
                  ),
                ),
              ),
            ),
          ), // End Filter Card Padding

          // --- 2. Metrics Section (REVISED) ---
        
          Card( // Added Card wrapper
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            shape: cardShape,
            color: cardColor,
            elevation: cardElevation,
            child: Padding( // Added inner Padding
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              child: Row( // This row was originally inside the outer Padding
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Metric 1: Total Trades
                  Column(
                    mainAxisSize: MainAxisSize.min, // Use minimum space vertically
                    crossAxisAlignment: CrossAxisAlignment.center, // Center text horizontally
                    children: [
                      Text(
                        'Total Trades',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant, // Lighter label
                            ),
                      ),
                      const SizedBox(height: 2), // Small space
                      Text(
                        totalTrades.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface, // Default value color
                              fontWeight: FontWeight.bold, // Bold value
                            ),
                      ),
                    ],
                  ),

                  // Metric 2: Net P/L
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Net P/L',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormat.format(netPL), // Use currency format
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: netPL >= 0 ? Colors.green : Colors.red, // Green/Red color
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),

                  // Metric 3: Win Rate
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Win Rate',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${percentFormat.format(winRate)}%', // Use percent format
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ), // Closing parenthesis for the Column
            ), // Closing parenthesis for inner Padding
          ), // Closing parenthesis for Card
          // --- 3. Scrollable Area for Detailed Report Content ---
          Expanded( // Takes remaining vertical space
            child: filteredTradesAsyncValue.when( // Handles loading/error
              data: (_) {
                return ListView(
                  padding: const EdgeInsets.all(12.0),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align headers left
                      children: [
                        ExpansionTile(
                          shape: const Border(), // Removes border when expanded
                          collapsedShape: const Border(), // Removes border when collapsed
                          title: _buildSectionHeader('Overall Performance', context), 
                          initiallyExpanded: true, // Keep this section open initially
                          tilePadding: EdgeInsets.zero, // Remove default padding
                          childrenPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0), // Add padding inside
                          children: [
                            _ReportMetricRow(label: 'Total P/L', value: currencyFormat.format(netPL), valueColor: netPL >= 0 ? Colors.green : Colors.red),
                            _ReportMetricRow(label: 'Average Trade P/L', value: currencyFormat.format(reportAvgTradePl), valueColor: reportAvgTradePl >= 0 ? Colors.green : Colors.red),
                            _ReportMetricRow(label: 'Profit Factor', value: reportProfitFactor.isFinite ? numberFormat.format(reportProfitFactor) : (reportProfitFactor.isInfinite ? 'Inf.' : 'N/A')),
                            _ReportMetricRow(label: 'Trade Expectancy', value: currencyFormat.format(reportExpectancy), valueColor: reportExpectancy >= 0 ? Colors.green : Colors.red),
                          ], // Closes the children list
                        ), // Closes the ExpansionTile
                        _buildSectionHeader('Trade Stats', context),
                        _ReportMetricRow(label: 'Total Number of Trades', value: totalTrades.toString()),
                        _ReportMetricRow(label: 'Number of Winning Trades', value: reportWins.toString()),
                        _ReportMetricRow(label: 'Number of Losing Trades', value: reportLosses.toString()),
                        _ReportMetricRow(label: 'Number of Break Even Trades', value: reportBE.toString()),
                        _ReportMetricRow(label: 'Largest Profit', value: currencyFormat.format(reportLargestWin), valueColor: Colors.green),
                        _ReportMetricRow(label: 'Largest Loss', value: currencyFormat.format(reportLargestLoss.abs()), valueColor: Colors.red),
                        _ReportMetricRow(label: 'Total Commissions', value: currencyFormat.format(reportTotalComm)),
                        _ReportMetricRow(label: 'Total Swap', value: currencyFormat.format(reportTotalSwap)),
                        _ReportMetricRow(label: 'Total Fees', value: currencyFormat.format(reportTotalFees)),

                        _buildSectionHeader('Hold Times', context),
                        _ReportMetricRow(label: 'Average Hold Time (All)', value: formatDuration(reportAvgHoldTime)),
                        _ReportMetricRow(label: 'Average Hold Time (Wins)', value: formatDuration(reportAvgWinTime)),
                        _ReportMetricRow(label: 'Average Hold Time (Losses)', value: formatDuration(reportAvgLossTime)),

                        _buildSectionHeader('Streaks', context),
                        _ReportMetricRow(label: 'Max Consecutive Wins', value: maxConsecutiveWins.toString()),
                        _ReportMetricRow(label: 'Max Consecutive Losses', value: maxConsecutiveLosses.toString()),

                        _buildSectionHeader('Daily Stats', context),
                        _ReportMetricRow(label: 'Total Trading Days', value: totalTradingDays.toString()),
                        _ReportMetricRow(label: 'Winning Days', value: winningDays.toString()),
                        _ReportMetricRow(label: 'Losing Days', value: losingDays.toString()),
                        _ReportMetricRow(label: 'Breakeven Days', value: breakevenDays.toString()),
                        _ReportMetricRow(label: 'Average Daily P/L', value: currencyFormat.format(avgDailyPL), valueColor: avgDailyPL >= 0 ? Colors.green : Colors.red),
                      ],
                    ),
                  ],
                );
              },
              error: (error, stack) => Center(child: Text('Error loading report data: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ), // End Expanded
        ],
      ), // End Main Column
    ); // End Scaffold
  }
} // End ReportPage Class

// --- Helper Widgets & Functions for ReportPage ---

// Helper widget for the filter chips/buttons
class _FilterChipWidget extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _FilterChipWidget({ required this.label, required this.value, required this.onTap });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      icon: Text(label, style: Theme.of(context).textTheme.labelSmall),
      label: Text(
        value,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: onTap,
    );
  }
}

// Compact Metric Widget
class _CompactMetricItem extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _CompactMetricItem({ required this.title, required this.value, this.valueColor });

   @override
   Widget build(BuildContext context) {
     final primaryTextColor = Theme.of(context).colorScheme.onSurface;
     final secondaryTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 8.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisSize: MainAxisSize.min,
         children: [
           Text(
             title,
             style: Theme.of(context).textTheme.labelMedium?.copyWith(color: secondaryTextColor),
             overflow: TextOverflow.ellipsis,
           ),
           const SizedBox(height: 2),
           Text(
             value,
             style: Theme.of(context).textTheme.titleLarge?.copyWith(
                   color: valueColor ?? primaryTextColor,
                   fontWeight: FontWeight.bold,
                 ),
              overflow: TextOverflow.ellipsis,
           ),
         ],
       ),
     );
   }
}

// Duration Formatter
String formatDuration(Duration duration) {
   if (duration <= Duration.zero) return 'N/A';
   final days = duration.inDays;
   final hours = duration.inHours.remainder(24);
   final minutes = duration.inMinutes.remainder(60);
   List<String> parts = [];
   if (days > 0) parts.add('${days}d');
   if (hours > 0) parts.add('${hours}h');
   if (minutes > 0 || parts.isEmpty) parts.add('${minutes}m');
   if (parts.length > 2) {
     parts = parts.sublist(0, 2);
   }
   return parts.join(' ');
}

// NEW Helper Widget for Report Page Metrics List
class _ReportMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReportMetricRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {return Padding(
    // Keep existing padding:
    padding: const EdgeInsets.symmetric(vertical: 6.0), // Increased vertical padding slightly
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3, // Keep flex factors
          child: Text(
            label, // The metric label (e.g., "Win Rate")
            style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Use bodyMedium style
                  // Make label text lighter grey (secondary text color):
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12), // Keep spacing
        Expanded(
          flex: 2, // Keep flex factors
          child: Text(
            value, // The metric value (e.g., "55.0%")
            textAlign: TextAlign.right, // Keep alignment
            style: Theme.of(context).textTheme.bodyLarge?.copyWith( // Use bodyLarge style
                  // Use provided valueColor (for P/L) or default text color:
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600, // Keep slightly bold
                ),
          ),
        ),
      ],
    ),
  );
  }
}
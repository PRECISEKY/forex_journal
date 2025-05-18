import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:fl_chart/fl_chart.dart'; // NEW: Import fl_chart
import 'dart:math'; // For max() function
import '../../data/local/database.dart'; // Make sure this is imported
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart'; // <-- ADD THIS LINE

// Provider to hold the selected start date for filtering
final dashboardStartDateProvider = StateProvider.autoDispose<DateTime?>((ref) => null);
// Provider to hold the selected end date for filtering
final dashboardEndDateProvider = StateProvider.autoDispose<DateTime?>((ref) => null);
// NEW: Filter State Providers
final dashboardSelectedPairProvider = StateProvider.autoDispose<Pair?>((ref) => null);
final dashboardSelectedStrategyProvider = StateProvider.autoDispose<Strategy?>((ref) => null);
// NEW: Filter for Direction (null = All, true = Long, false = Short)
final dashboardDirectionFilterProvider = StateProvider.autoDispose<bool?>((ref) => null);

// Provider to watch filtered trades based on date range
final filteredTradesProvider = StreamProvider.autoDispose<List<Trade>>((ref) {
  final endDate = ref.watch(dashboardEndDateProvider);
  final selectedPair = ref.watch(dashboardSelectedPairProvider); // NEW
  final selectedStrategy = ref.watch(dashboardSelectedStrategyProvider); // NEW
  final startDate = ref.watch(dashboardStartDateProvider);
  final tradeDao = ref.watch(tradeDaoProvider);

  // Call DAO method with ALL filters
  return tradeDao.watchFilteredTrades(
    startDate: startDate,
    endDate: endDate,
    pairId: selectedPair?.id, // Pass selected pair's ID (or null)
    strategyId: selectedStrategy?.id, // Pass selected strategy's ID (or null)
  );
});

// --- NEW: Metric Providers ---

// Provider for Total Trades count
final totalTradesProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(filteredTradesProvider).maybeWhen(
        data: (trades) => trades.length,
        orElse: () => 0,
      );
});

// Provider for Net Profit/Loss
final netPLProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(filteredTradesProvider).maybeWhen(
        data: (trades) => trades.fold(
          0.0,
          (sum, trade) => sum + (trade.actualProfitLoss ?? 0.0),
        ),
        orElse: () => 0.0,
      );
});

// Provider for Win Count
final winCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(filteredTradesProvider).maybeWhen(
        data: (trades) => trades.where((t) => (t.actualProfitLoss ?? 0.0) > 0).length,
        orElse: () => 0,
      );
});

// Provider for Loss Count
final lossCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(filteredTradesProvider).maybeWhen(
        data: (trades) => trades.where((t) => (t.actualProfitLoss ?? 0.0) < 0).length,
        orElse: () => 0,
      );
});

// Provider for Win Rate (%)
final winRateProvider = Provider.autoDispose<double>((ref) {
  final wins = ref.watch(winCountProvider);
  final losses = ref.watch(lossCountProvider);
  final totalClosed = wins + losses;
  if (totalClosed == 0) {
    return 0.0;
  }
  return (wins / totalClosed) * 100.0;
});

// --- NEW: Advanced Metric Providers ---

// Provider for Average Winning Trade P/L
final avgWinPlProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(filteredTradesProvider).valueOrNull ?? [];
  final winningTrades = trades.where((t) => (t.actualProfitLoss ?? 0.0) > 0).toList();
  if (winningTrades.isEmpty) return 0.0;
  final totalWinPl = winningTrades.fold(0.0, (sum, t) => sum + t.actualProfitLoss!);
  return totalWinPl / winningTrades.length;
});

// Provider for Average Losing Trade P/L
final avgLossPlProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(filteredTradesProvider).valueOrNull ?? [];
  final losingTrades = trades.where((t) => (t.actualProfitLoss ?? 0.0) < 0).toList();
  if (losingTrades.isEmpty) return 0.0;
  final totalLossPl = losingTrades.fold(0.0, (sum, t) => sum + t.actualProfitLoss!);
  return totalLossPl / losingTrades.length;
});

// Provider for Profit Factor
final profitFactorProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(filteredTradesProvider).valueOrNull ?? [];
  final grossProfit = trades.where((t) => (t.actualProfitLoss ?? 0.0) > 0).fold(0.0, (sum, t) => sum + t.actualProfitLoss!);
  final grossLoss = trades.where((t) => (t.actualProfitLoss ?? 0.0) < 0).fold(0.0, (sum, t) => sum + t.actualProfitLoss!);
  if (grossLoss == 0) return grossProfit > 0 ? double.infinity : 0.0;
  return grossProfit / grossLoss.abs();
});

// Provider for Average Holding Time
final avgHoldingTimeProvider = Provider.autoDispose<Duration>((ref) {
  final trades = ref.watch(filteredTradesProvider).valueOrNull ?? [];
  if (trades.isEmpty) return Duration.zero;
  Duration totalDuration = Duration.zero;
  int validDurationCount = 0;
  for (final trade in trades) {
    if (trade.exitDate.isAfter(trade.entryDate)) {
      totalDuration += trade.exitDate.difference(trade.entryDate);
      validDurationCount++;
    }
  }
  return validDurationCount == 0 ? Duration.zero : Duration(microseconds: totalDuration.inMicroseconds ~/ validDurationCount);
});

// --- NEW: More Advanced Metric Providers ---

// Provider for Largest Winning Trade P/L
final largestWinProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(filteredTradesProvider).valueOrNull ?? [];
  final winningPLs = trades
      .map((t) => t.actualProfitLoss ?? 0.0) // Get P/L, treat null as 0
      .where((pl) => pl > 0); // Filter for wins only
  if (winningPLs.isEmpty) {
    return 0.0; // No wins
  }
  return winningPLs.reduce(max); // Find the maximum value
});

// Provider for Largest Losing Trade P/L
final largestLossProvider = Provider.autoDispose<double>((ref) {
  final trades = ref.watch(filteredTradesProvider).valueOrNull ?? [];
  final losingPLs = trades
      .map((t) => t.actualProfitLoss ?? 0.0)
      .where((pl) => pl < 0); // Filter for losses only
  if (losingPLs.isEmpty) {
    return 0.0; // No losses
  }
  return losingPLs.reduce(min); // Find the minimum value (most negative)
});

// Provider for Expectancy per Trade
final expectancyProvider = Provider.autoDispose<double>((ref) {
  // Depend on previously calculated metrics
  final winRate = ref.watch(winRateProvider); // Percentage (0-100)
  final avgWin = ref.watch(avgWinPlProvider); // Positive value
  final avgLoss = ref.watch(avgLossPlProvider); // Negative value or zero

  // Handle cases where avgLoss is 0 (no losses)
  if (avgLoss == 0) {
      // If win rate > 0 and avgWin > 0, expectancy is effectively avgWin
      // If win rate is 0 or avgWin is 0, expectancy is 0
      return (winRate > 0 && avgWin > 0) ? avgWin : 0.0;
  }

  final lossRate = 100.0 - winRate; // Percentage
  // Formula: (Win% * AvgWin) - (Loss% * Abs(AvgLoss))
  final expectancy = ((winRate / 100.0) * avgWin) - ((lossRate / 100.0) * avgLoss.abs());
  return expectancy;
});

// NEW: Helper class to hold chart data and axis bounds/interval
class EquityCurveData {
  final List<FlSpot> spots;
  final double minY;
  final double maxY;
  final double yAxisInterval; // Store the calculated nice interval

  EquityCurveData({
    required this.spots,
    required this.minY,
    required this.maxY,
    required this.yAxisInterval,
  });
}

// Helper function to calculate a 'nice' interval for chart axes
double _calculateNiceInterval(double range, {int targetSteps = 4}) {
  if (range <= 0) return 1.0; // Avoid issues with zero or negative range

  double rawInterval = range / targetSteps;
  double magnitude = pow(10, (log(rawInterval) / log(10)).floor()).toDouble();
  double residual = rawInterval / magnitude;

  // Snap to nice numbers (1, 2, 5, 10) * magnitude
  double niceResidual;
  if (residual <= 1.5) {
    niceResidual = 1;
  } else if (residual <= 3) {
    niceResidual = 2; // Or sometimes 2.5 is used
  } else if (residual <= 7) {
    niceResidual = 5;
  } else {
    niceResidual = 10;
  }

  return niceResidual * magnitude;
}

// NEW: Provider to calculate Equity Curve data points AND axis bounds/interval
final equityCurveSpotsProvider = Provider.autoDispose<EquityCurveData>((ref) {
  final tradesAsyncValue = ref.watch(filteredTradesProvider);

  return tradesAsyncValue.maybeWhen(
    data: (trades) {
      List<FlSpot> spots = [];
      double cumulativePl = 0.0;
      double minY = 0.0;
      double maxY = 0.0;

      spots.add(const FlSpot(0, 0)); // Start point

      for (int i = 0; i < trades.length; i++) {
        cumulativePl += trades[i].actualProfitLoss ?? 0.0;
        spots.add(FlSpot((i + 1).toDouble(), cumulativePl));
        if (cumulativePl < minY) minY = cumulativePl;
        if (cumulativePl > maxY) maxY = cumulativePl;
      }

      // --- Calculate Nice Bounds & Interval ---
      double range = maxY - minY;
      // Avoid division by zero / issues with flat lines
      if (range.abs() < 0.01) {
        range = 100.0; // Use a default range if data is flat
        minY = cumulativePl - 50.0; // Center the flat line
        maxY = cumulativePl + 50.0;
      }

      double niceInterval = _calculateNiceInterval(range.abs()); // Use helper function

      // Adjust min/max slightly to align with nice intervals and add padding
      // Make minY a multiple of the interval, rounded down
      minY = (minY / niceInterval).floor() * niceInterval;
      // Make maxY a multiple of the interval, rounded up
      maxY = (maxY / niceInterval).ceil() * niceInterval;

      // Ensure min/max aren't identical after rounding
      if (maxY == minY) {
        maxY = minY + niceInterval;
      }

      return EquityCurveData(
        spots: spots,
        minY: minY,
        maxY: maxY,
        yAxisInterval: niceInterval, // Store the calculated interval
      );
    },
    orElse: () => EquityCurveData(spots: [], minY: 0, maxY: 100, yAxisInterval: 25), // Default state
  );
});

// Helper class to hold data for one bar in the P/L chart
class DailyPLDataPoint {
  final DateTime date; // The specific day
  final double totalPL; // Sum of P/L for that day

  DailyPLDataPoint({required this.date, required this.totalPL});
}

// NEW: Provider to calculate total P/L per day
final dailyPLProvider = Provider.autoDispose<List<DailyPLDataPoint>>((ref) {
  // Watch the filtered trades
  final trades = ref.watch(filteredTradesProvider).valueOrNull ?? [];
  if (trades.isEmpty) return [];

  // Group P/L by day (using exitDate for grouping)
  final Map<DateTime, double> plByDay = {};
  for (final trade in trades) {
    // Normalize date to midnight to group by day correctly
    final day = DateTime(trade.exitDate.year, trade.exitDate.month, trade.exitDate.day);
    final pl = trade.actualProfitLoss ?? 0.0;
    plByDay.update(day, (value) => value + pl, ifAbsent: () => pl);
  }

  // Convert map to sorted list of data points
  final dataPoints = plByDay.entries
                      .map((entry) => DailyPLDataPoint(date: entry.key, totalPL: entry.value))
                      .toList();
  // Sort by date ascending
  dataPoints.sort((a, b) => a.date.compareTo(b.date));

  return dataPoints;
});

// --- NEW: Provider for Calendar Heatmap Data ---
final heatmapDataProvider = Provider.autoDispose<Map<DateTime, double>>((ref) {
  // 1. Watch the filtered trades provider (reacts to date/pair/strategy filters)
  final tradesAsyncValue = ref.watch(filteredTradesProvider);

  // Use maybeWhen to handle loading/error states, return empty map if no data
  return tradesAsyncValue.maybeWhen(
    data: (trades) {
      // 2. Create a map to store P/L per day
      final Map<DateTime, double> dailyPLMap = {};

      // 3. Loop through each trade
      for (final trade in trades) {
        // Ensure P/L is not null, default to 0.0 if it is
        final pl = trade.actualProfitLoss ?? 0.0;
        // Get the date of the trade exit, ignoring the time (normalize to midnight)
        final dateOnly = DateTime(trade.exitDate.year, trade.exitDate.month, trade.exitDate.day);

        // 4. Add the trade's P/L to the total for that day
        dailyPLMap.update(
          dateOnly, // The key is the date
          (existingPL) => existingPL + pl, // If date exists, add to it
          ifAbsent: () => pl, // If date doesn't exist, set it to this trade's P/L
        );
      }
      // 5. Return the map containing {Date: Total P/L for that Date}
      return dailyPLMap;
    },
    // If trades are loading or there's an error, return an empty map
    orElse: () => <DateTime, double>{},
  );
});
// --- END: New Provider ---

// --- NEW: Provider for P/L by Day of the Week ---
final plByWeekdayProvider = Provider.autoDispose<List<double>>((ref) {
  // 1. Watch the filtered trades
  final tradesAsyncValue = ref.watch(filteredTradesProvider);

  // Use maybeWhen to handle loading/error, return list of zeros if no data
  return tradesAsyncValue.maybeWhen(
    data: (trades) {
      // 2. Create a list to hold P/L for each weekday (index 0=Mon, 6=Sun)
      // Initialize all days with 0.0 P/L
      final List<double> weekdayPL = List.filled(7, 0.0);

      // 3. Loop through each trade
      for (final trade in trades) {
        // Get the weekday (Monday=1, Sunday=7) from the exit date
        final int weekday = trade.exitDate.weekday;
        // Get the P/L (default to 0.0 if null)
        final double pl = trade.actualProfitLoss ?? 0.0;

        // 4. Add the P/L to the correct day's total
        // We use weekday - 1 because list indices are 0-based (0=Mon, 6=Sun)
        if (weekday >= 1 && weekday <= 7) { // Basic safety check
          weekdayPL[weekday - 1] += pl;
        }
      }
      // 5. Return the list containing P/L sums for Mon, Tue, Wed, Thu, Fri, Sat, Sun
      return weekdayPL;
    },
    // If trades are loading or error, return a list of 7 zeros
    orElse: () => List.filled(7, 0.0),
  );
});
// --- END: New Provider ---

// Helper class to hold data for P/L per pair
class PairPLData {
  final String pairName;
  final double totalPL;
  PairPLData({required this.pairName, required this.totalPL});
}

// --- NEW: Provider for P/L by Pair ---
final plByPairProvider = Provider.autoDispose<List<PairPLData>>((ref) {
  // 1. Watch the filtered trades
  final tradesAsyncValue = ref.watch(filteredTradesProvider);

  return tradesAsyncValue.maybeWhen(
    data: (trades) {
      // 2. Create a map to store P/L per pair name
      final Map<String, double> plByPairMap = {};

      // 3. Loop through each trade
      for (final trade in trades) {
        // Use the pair name as the key
        final String pairKey = trade.pair;
        final double pl = trade.actualProfitLoss ?? 0.0;

        // 4. Add the trade's P/L to the total for that pair
        plByPairMap.update(
          pairKey,
          (existingPL) => existingPL + pl,
          ifAbsent: () => pl,
        );
      }

      // 5. Convert the map to a list of PairPLData objects
      final List<PairPLData> resultList = plByPairMap.entries.map((entry) {
        return PairPLData(pairName: entry.key, totalPL: entry.value);
      }).toList();

      // 6. Sort the list (e.g., by P/L descending - highest profit first)
      resultList.sort((a, b) => b.totalPL.compareTo(a.totalPL));

      // 7. Return the sorted list
      return resultList;
    },
    // If trades are loading or error, return an empty list
    orElse: () => [],
  );
});
// --- END: New Provider ---

// Helper function to format Duration into a readable string
String formatDuration(Duration duration) {
  if (duration <= Duration.zero) return 'N/A';
  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);
  List<String> parts = [];
  if (days > 0) parts.add('${days}d');
  if (hours > 0) parts.add('${hours}h');
  if (minutes > 0 || parts.isEmpty) parts.add('${minutes}m');
  return parts.length > 2 ? parts.sublist(0, 2).join(' ') : parts.join(' ');
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  // NEW: Show Date Range Picker Dialog
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
      ref.read(dashboardStartDateProvider.notifier).state = picked.start;
      ref.read(dashboardEndDateProvider.notifier).state = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
    }
  }

  // NEW: Show Pair Selection Dialog
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
              ref.read(dashboardSelectedPairProvider.notifier).state = newValue;
              Navigator.of(context).pop();
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
        );
      },
    );
  }

  // NEW: Show Strategy Selection Dialog
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
              ref.read(dashboardSelectedStrategyProvider.notifier).state = newValue;
              Navigator.of(context).pop();
            },
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the date providers to react to changes
    final startDate = ref.watch(dashboardStartDateProvider);
    final endDate = ref.watch(dashboardEndDateProvider);
    final filteredTradesAsyncValue = ref.watch(filteredTradesProvider);

    final totalTrades = ref.watch(totalTradesProvider);
    final netPL = ref.watch(netPLProvider);
    final winRate = ref.watch(winRateProvider);
    final EquityCurveData equityCurveData = ref.watch(equityCurveSpotsProvider);

    final avgWinPl = ref.watch(avgWinPlProvider);
    // NEW: Watch daily P/L data
    final List<DailyPLDataPoint> dailyPLData = ref.watch(dailyPLProvider);

    final avgLossPl = ref.watch(avgLossPlProvider);
    final profitFactor = ref.watch(profitFactorProvider);
    final avgHoldTime = ref.watch(avgHoldingTimeProvider);

    // NEW: Watch new metric providers
    final largestWin = ref.watch(largestWinProvider);
    final largestLoss = ref.watch(largestLossProvider); // Negative or zero
    final expectancy = ref.watch(expectancyProvider);

    final dateFormat = DateFormat.yMd(); // Format for displaying dates
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final percentFormat = NumberFormat("##0.0#", "en_US");
    final numberFormat = NumberFormat("##0.0#", "en_US");

    // NEW: Watch selected filters
    final selectedPair = ref.watch(dashboardSelectedPairProvider);
    final selectedStrategy = ref.watch(dashboardSelectedStrategyProvider);

    // NEW: Watch lists needed for dropdowns
    final allPairsAsync = ref.watch(allPairsStreamProvider);
    final allStrategiesAsync = ref.watch(allStrategiesStreamProvider);

    return Scaffold(
      body: Column(
        children: [
          // --- Filter Section ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChipWidget(
                        label: 'Dates:',
                        value: (startDate == null && endDate == null)
                            ? 'All Time'
                            : '${startDate != null ? dateFormat.format(startDate) : '...'} - ${endDate != null ? dateFormat.format(endDate) : '...'}',
                        onTap: () => _showDateRangeFilterDialog(context, ref, startDate, endDate),
                      ),
                      const SizedBox(width: 8),
                      allPairsAsync.when(
                        data: (pairs) => _FilterChipWidget(
                          label: 'Pair:',
                          value: selectedPair?.name ?? 'All Pairs',
                          onTap: () => _showPairFilterDialog(context, ref, pairs, selectedPair),
                        ),
                        loading: () => const ActionChip(label: Text('Pair: Loading...'), onPressed: null),
                        error: (e, s) => ActionChip(label: Text('Pair: Err'), onPressed: null),
                      ),
                      const SizedBox(width: 8),
                      allStrategiesAsync.when(
                        data: (strategies) => _FilterChipWidget(
                          label: 'Strategy:',
                          value: selectedStrategy?.name ?? 'All Strategies',
                          onTap: () => _showStrategyFilterDialog(context, ref, strategies, selectedStrategy),
                        ),
                        loading: () => const ActionChip(label: Text('Strategy: Loading...'), onPressed: null),
                        error: (e, s) => ActionChip(label: Text('Strategy: Err'), onPressed: null),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear_all),
                        tooltip: 'Clear All Filters',
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          ref.read(dashboardStartDateProvider.notifier).state = null;
                          ref.read(dashboardEndDateProvider.notifier).state = null;
                          ref.read(dashboardSelectedPairProvider.notifier).state = null;
                          ref.read(dashboardSelectedStrategyProvider.notifier).state = null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Expanded Scrollable Area ---
          Expanded(
            child: filteredTradesAsyncValue.when(
              data: (_) {
                return ListView(
                  padding: const EdgeInsets.all(12.0),
                  children: [
                    // --- METRICS SECTION ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        alignment: WrapAlignment.spaceEvenly,
                        children: [
                          _CompactMetricItem(
                            title: 'Net P/L',
                            value: currencyFormat.format(netPL),
                          ),
                          _CompactMetricItem(
                            title: 'Win Rate',
                            value: '${percentFormat.format(winRate)}%',
                          ),
                          _CompactMetricItem(
                            title: 'Profit Factor',
                            value: profitFactor.isFinite
                                ? numberFormat.format(profitFactor)
                                : (profitFactor.isInfinite ? 'Inf.' : 'N/A'),
                          ),
                          _CompactMetricItem(
                            title: 'Total Trades',
                            value: totalTrades.toString(),
                          ),
                          _CompactMetricItem(
                            title: 'Avg Win P/L',
                            value: currencyFormat.format(avgWinPl),
                          ),
                          _CompactMetricItem(
                            title: 'Avg Loss P/L',
                            value: currencyFormat.format(avgLossPl.abs()),
                          ),
                          _CompactMetricItem(
                            title: 'Avg Hold Time',
                            value: formatDuration(avgHoldTime),
                          ),
                          _CompactMetricItem(
                            title: 'Largest Win',
                            value: currencyFormat.format(largestWin),
                          ),
                          _CompactMetricItem(
                            title: 'Largest Loss',
                            value: currencyFormat.format(largestLoss.abs()),
                          ),
                          _CompactMetricItem(
                            title: 'Expectancy',
                            value: currencyFormat.format(expectancy),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Equity Curve Chart Card ---
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Equity Curve',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 250,
                              child: equityCurveData.spots.length > 1
                                  ? LineChart(
                                      LineChartData(
                                        minX: 0,
                                        maxX: (equityCurveData.spots.length - 1).toDouble(),
                                        minY: equityCurveData.minY,
                                        maxY: equityCurveData.maxY,
                                        // === Titles (Axis Labels) ===
                                        titlesData: FlTitlesData(
                                          show: true,
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 28,
                                              interval: max(1, ((equityCurveData.spots.length - 1) / 5).ceilToDouble()),
                                              getTitlesWidget: (value, meta) {
                                                if (value == 0 || value > meta.max || value != value.toInt()) return const SizedBox.shrink();
                                                return SideTitleWidget(
                                                  meta: meta,
                                                  space: 4,
                                                  child: Text(
                                                    value.toInt().toString(),
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 45,
                                              interval: equityCurveData.yAxisInterval,
                                              getTitlesWidget: (value, meta) {
                                                final format = NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 0);
                                                if (value == meta.max || value == meta.min) return Container();
                                                return SideTitleWidget(
                                                  meta: meta,
                                                  space: 4,
                                                  child: Text(
                                                    format.format(value),
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // === Grid Data ===
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: equityCurveData.yAxisInterval,
                                          getDrawingHorizontalLine: (value) => FlLine(
                                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                            strokeWidth: 1,
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border(
                                            left: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                                            bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                                          ),
                                        ),
                                        lineTouchData: LineTouchData(
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipItems: (touchedSpots) {
                                              return touchedSpots.map((LineBarSpot touchedSpot) {
                                                final double xValue = touchedSpot.x;
                                                final double yValue = touchedSpot.y;

                                                final plText = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(yValue);

                                                return LineTooltipItem(
                                                  'Trade ${xValue.toInt()}\nP/L: $plText',
                                                  TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontSize: 12),
                                                );
                                              }).toList();
                                            },
                                            getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: equityCurveData.spots,
                                            isCurved: true,
                                            color: Theme.of(context).colorScheme.primary,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                      ),
                                      duration: const Duration(milliseconds: 250),
                                    )
                                  : const Center(
                                      child: Text('Not enough trade data in selected range for chart.'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- NEW: Daily P/L Bar Chart Card ---
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Daily Net P/L', // Chart Title
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 250, // Chart height
                              child: dailyPLData.isNotEmpty
                                  ? BarChart(
                                      BarChartData(
                                        // --- Bar Groups (Data) ---
                                        barGroups: _createBarGroups(context, dailyPLData),

                                        // --- Styling & Axes ---
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false, // Only horizontal lines
                                          horizontalInterval: _calculateNiceInterval( // Use helper again
                                              dailyPLData.map((d) => d.totalPL).reduce((max, e) => max > e ? max : e) - // Max PL
                                              dailyPLData.map((d) => d.totalPL).reduce((min, e) => min < e ? min : e), // Min PL
                                              targetSteps: 3 // Aim for ~3 lines
                                              ),
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        borderData: FlBorderData( // Similar border as line chart
                                          show: true,
                                          border: Border(
                                            left: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                                            bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                                            top: BorderSide.none,
                                            right: BorderSide.none,
                                          ),
                                        ),
                                        titlesData: FlTitlesData( // Axis Labels/Titles
                                            show: true,
                                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            // Bottom Axis (Date)
                                            bottomTitles: AxisTitles(
                                              axisNameWidget: Text('Date', style: Theme.of(context).textTheme.labelSmall),
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 32, // Increased slightly for rotated labels potentially
                                                interval: max(1, (dailyPLData.length / 4).ceilToDouble()), // Keep interval logic
                                                getTitlesWidget: (value, meta) {
                                                  final index = value.toInt();
                                                  if (index < 0 || index >= dailyPLData.length) return const SizedBox.shrink();
                                                  final date = dailyPLData[index].date;
                                                  // Format date as 'dd\nMMM' (e.g., 10\nApr) for better fit if many bars
                                                  final text = DateFormat('dd\nMMM').format(date);
                                                  return SideTitleWidget(
                                                    meta: meta,
                                                    space: 4,
                                                    child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                                  );
                                                },
                                              ),
                                            ),

                                            // Left Axis (P/L Amount)
                                            leftTitles: AxisTitles(
                                               axisNameWidget: Text('Net P/L (\$)', style: Theme.of(context).textTheme.labelSmall), // TODO: Use actual currency symbol
                                               axisNameSize: 20, // Space for axis title
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 45, // Keep adjusted size
                                                interval: _calculateNiceInterval( // Ensure this helper exists and is used
                                                   dailyPLData.map((d) => d.totalPL).fold(0.0, (max, e) => max > e ? max : e) -
                                                   dailyPLData.map((d) => d.totalPL).fold(0.0, (min, e) => min < e ? min : e),
                                                   targetSteps: 3
                                                 ),
                                                getTitlesWidget: (value, meta) {
                                                   final format = NumberFormat.compactSimpleCurrency(locale: 'en_US', decimalDigits: 0);
                                                   // Keep existing formatting logic, using smaller/dimmer style
                                                   return SideTitleWidget(
                                                     meta: meta,
                                                     space: 4,
                                                     child: Text(format.format(value), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                                   );
                                                },
                                              ),
                                            ),
                                        ),
                                        barTouchData: BarTouchData(
                                          touchTooltipData: BarTouchTooltipData(
                                            // Use a theme color for background
                                            getTooltipColor: (spot) => Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                                            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            tooltipMargin: 8,
                                            // borderRadius: BorderRadius.circular(8), // Removed: not valid in fl_chart 1.x
                                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                               final dataPoint = dailyPLData[group.x.toInt()];
                                               final dateStr = DateFormat.yMd().format(dataPoint.date);
                                               final plStr = currencyFormat.format(dataPoint.totalPL);
                                               return BarTooltipItem(
                                                 '$dateStr\n$plStr', // Keep content
                                                 // Use light text on dark tooltip background
                                                 TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                                               );
                                            },
                                          ),
                                        ),
                                        // Align bars to bottom (for P/L centering around 0)
                                        alignment: BarChartAlignment.spaceAround,
                                        // TODO: Calculate minY/maxY dynamically for P/L axis
                                      ),
                                    )
                                  : const Center( // Placeholder if no data
                                      child: Text('No daily P/L data in selected range.'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- NEW: Heatmap Calendar Card ---
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      color: Theme.of(context).colorScheme.surfaceContainer, // Or surfaceContainerLow
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Performance Heatmap',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Consumer(
                              builder: (context, ref, child) {
                                final Map<DateTime, double> dailyPLData = ref.watch(heatmapDataProvider);
                                final Map<DateTime, int> heatmapDatasets = {};
                                dailyPLData.forEach((date, pl) {
                                  if (pl > 0) {
                                    heatmapDatasets[date] = 1;
                                  } else if (pl < 0) {
                                    heatmapDatasets[date] = 2;
                                  }
                                });

                                final heatmapColorsets = {
                                  1: Colors.green.shade400,
                                  2: Colors.red.shade400,
                                };

                                return HeatMapCalendar(
                                  flexible: true,
                                  
                                  datasets: heatmapDatasets,
                                  colorsets: heatmapColorsets,
                                  colorMode: ColorMode.color,
                                  defaultColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 40,
                                  fontSize: 10,
                                  monthFontSize: 16,
                                  weekFontSize: 12,
                                  weekTextColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                  showColorTip: false,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- NEW: P/L by Day of Week Bar Chart Card ---
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'P/L by Day of Week',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 24),
                            Consumer(
                              builder: (context, ref, child) {
                                final List<double> weeklyPLData = ref.watch(plByWeekdayProvider);

                                String getWeekdayInitial(double value) {
                                  switch (value.toInt()) {
                                    case 0: return 'M';
                                    case 1: return 'T';
                                    case 2: return 'W';
                                    case 3: return 'T';
                                    case 4: return 'F';
                                    case 5: return 'S';
                                    case 6: return 'S';
                                    default: return '';
                                  }
                                }

                                // Find max/min P/L for Y-axis scaling (add padding)
                                double maxPL = 0;
                                double minPL = 0;
                                if (weeklyPLData.isNotEmpty) {
                                  // Ensure reduce starts with a double to maintain type
                                  maxPL = weeklyPLData.reduce((max, e) => e > max ? e : max);
                                  minPL = weeklyPLData.reduce((min, e) => e < min ? e : e);
                                }
                                // Add some padding to min/max unless they are zero
                                // Explicitly declare as double and use double literals (10.0, -10.0)
                                final double maxYAxis = (maxPL <= 0 ? 10.0 : maxPL * 1.2); // Use 10.0
                                final double minYAxis = (minPL >= 0 ? -10.0 : minPL * 1.2); // Use -10.0

                                return SizedBox(
                                  height: 250,
                                  child: BarChart(
                                    BarChartData(
                                      barGroups: List.generate(weeklyPLData.length, (index) {
                                        final pl = weeklyPLData[index];
                                        final isPositive = pl >= 0;
                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: pl,
                                              color: isPositive ? Colors.green.shade400 : Colors.red.shade400,
                                              width: 16,
                                              borderRadius: isPositive
                                                  ? const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))
                                                  : const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                                            ),
                                          ],
                                        );
                                      }),
                                      maxY: maxYAxis,
                                      minY: minYAxis,
                                      titlesData: FlTitlesData(
                                        show: true,
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 28,
                                            getTitlesWidget: (value, meta) {
                                              final text = getWeekdayInitial(value);
                                              return SideTitleWidget(
                                                meta: meta,
                                                space: 4,
                                                child: Text(text, style: Theme.of(context).textTheme.bodySmall),
                                              );
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 55, // Increased from 45
                                            getTitlesWidget: (value, meta) {
                                              // --- ADD THIS CHECK ---
                                              // Don't draw labels exactly at the min/max calculated axis edges
                                              if (value == minYAxis || value == maxYAxis) return Container();
                                              // --- END ADDED CHECK ---

                                              if (value == 0 && (maxYAxis - minYAxis > 20)) return Container();
                                              final format = NumberFormat.compactSimpleCurrency(locale: 'en_US', decimalDigits: 0);
                                              return SideTitleWidget(
                                                meta: meta,
                                                space: 4,
                                                child: Text(format.format(value), style: Theme.of(context).textTheme.bodySmall),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: (maxYAxis - minYAxis) / 4,
                                        getDrawingHorizontalLine: (value) => FlLine(
                                          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                                          strokeWidth: 1,
                                        ),
                                        checkToShowHorizontalLine: (value) => value == 0,
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border(
                                          left: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                                          bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                                        ),
                                      ),
                                      barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipColor: (group) => Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                            final day = weekdays[group.x.toInt()];
                                            final pl = rod.toY;
                                            final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
                                            return BarTooltipItem(
                                              '$day\n${format.format(pl)}',
                                              TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- NEW: P/L by Pair Bar Chart Card ---
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'P/L by Pair',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 24),
                            Consumer(
                              builder: (context, ref, child) {
                                final List<PairPLData> pairPLList = ref.watch(plByPairProvider);

                                if (pairPLList.isEmpty) {
                                  return const SizedBox(
                                    height: 250,
                                    child: Center(child: Text('No pair data available for selected period.')),
                                  );
                                }

                                double maxPL = pairPLList.map((d) => d.totalPL).reduce((max, e) => e > max ? e : max);
                                double minPL = pairPLList.map((d) => d.totalPL).reduce((min, e) => e < min ? e : e);
                                final double maxYAxis = maxPL <= 0 ? 10.0 : maxPL * 1.2;
                                final double minYAxis = minPL >= 0 ? -10.0 : minPL * 1.2;

                                return SizedBox(
                                  height: 250,
                                  child: BarChart(
                                    BarChartData(
                                      barGroups: List.generate(pairPLList.length, (index) {
                                        final pairData = pairPLList[index];
                                        final pl = pairData.totalPL;
                                        final isPositive = pl >= 0;
                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: pl,
                                              color: isPositive ? Colors.green.shade400 : Colors.red.shade400,
                                              width: 16,
                                              borderRadius: isPositive
                                                  ? const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))
                                                  : const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                                            ),
                                          ],
                                        );
                                      }),
                                      maxY: maxYAxis,
                                      minY: minYAxis,
                                      titlesData: FlTitlesData(
                                        show: true,
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 32,
                                            getTitlesWidget: (value, meta) {
                                              final index = value.toInt();
                                              if (index < 0 || index >= pairPLList.length) return Container();
                                              final pairName = pairPLList[index].pairName;
                                              final shortName = pairName.length > 6 ? '${pairName.substring(0, 5)}…' : pairName;
                                              return SideTitleWidget(
                                                meta: meta,
                                                space: 4,
                                                child: Text(shortName, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
                                              );
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 55, // Increased from 45
                                            getTitlesWidget: (value, meta) {
                                              // --- ADD THIS CHECK ---
                                              // Don't draw labels exactly at the min/max calculated axis edges
                                              if (value == minYAxis || value == maxYAxis) return Container();
                                              // --- END ADDED CHECK ---

                                              if (value == 0 && (maxYAxis - minYAxis > 20)) return Container();
                                              final format = NumberFormat.compactSimpleCurrency(locale: 'en_US', decimalDigits: 0);
                                              return SideTitleWidget(
                                                meta: meta,
                                                space: 4,
                                                child: Text(format.format(value), style: Theme.of(context).textTheme.bodySmall),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        checkToShowHorizontalLine: (value) => value == 0,
                                        getDrawingHorizontalLine: (value) => FlLine(
                                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                          strokeWidth: 1,
                                        ),
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border(
                                          left: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                                          bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                                        ),
                                      ),
                                      barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipColor: (group) => Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            final pairName = pairPLList[group.x.toInt()].pairName;
                                            final pl = rod.toY;
                                            final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
                                            return BarTooltipItem(
                                              '$pairName\n${format.format(pl)}',
                                              TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }; // End of SizedBox/BarChart
                              }, // End of Consumer builder
                            ),
                    // --- END: New P/L by Pair Card ---
                    const SizedBox(height: 16),
                  ],
                ); // Close ListView
              },
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ), // Close filteredTradesAsyncValue.when
          ), // Close Expanded
        ],
      ), // Close Column
    ); // Close Scaffold
  }

  // Add this helper function INSIDE the DashboardPage class
  List<BarChartGroupData> _createBarGroups(BuildContext context, List<DailyPLDataPoint> data) {
    final greenGradient = LinearGradient(
      colors: [Colors.green.shade400, Colors.green.shade700],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    final redGradient = LinearGradient(
      colors: [Colors.red.shade400, Colors.red.shade700],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    return List.generate(data.length, (index) {
      final dataPoint = data[index];
      final isPositive = dataPoint.totalPL >= 0;

      // --- NEW: Define borderRadius conditionally ---
      final BorderRadius barRadius = isPositive
          ? const BorderRadius.only( // Round top for positive bars
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            )
          : const BorderRadius.only( // Round bottom for negative bars
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4)),
      // --- End NEW ---

      return BarChartGroupData(
        x: index, // Use simple index for X position
        barRods: [
          BarChartRodData(
            toY: dataPoint.totalPL, // The P/L value determines bar height
            gradient: isPositive ? greenGradient : redGradient,
            width: 12, // Adjust bar width
            borderRadius: barRadius, // <<< Apply conditional radius here
          ),
        ],
      );
    }); // End of List.generate
  } // End of _createBarGroups
}

// --- Helper Widget for Displaying Metrics ---
class _CompactMetricItem extends StatelessWidget {
  final String title;
  final String value;

  const _CompactMetricItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// NEW: Helper widget for the filter chips/buttons
class _FilterChipWidget extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.value,
    required this.onTap,
  });

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
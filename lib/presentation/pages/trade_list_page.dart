import 'package:drift/drift.dart' hide Column; // Add 'hide Column'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:go_router/go_router.dart'; // Import for navigation

// Import your data layer components
import '../../data/local/database.dart' hide Column; // Add 'hide Column'

// Provider that watches the stream of all trades from the DAO
final allTradesStreamProvider = StreamProvider.autoDispose<List<Trade>>((ref) {
  // Watch the tradeDaoProvider
  final tradeDao = ref.watch(tradeDaoProvider);
  // Return the stream from the DAO method
  return tradeDao.watchAllTrades();
});

class TradeListPage extends ConsumerWidget {
  const TradeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream provider to get the AsyncValue<List<Trade>>
    final tradesAsyncValue = ref.watch(allTradesStreamProvider);

    return Scaffold(
      
      body: tradesAsyncValue.when(
        // Data state: Display the list
        data: (trades) {
          if (trades.isEmpty) {
            return const Center(
              child: Text('No trades logged yet. Tap + to add your first trade!'),
            );
          }
          // Use ListView.builder for efficient scrolling
          return ListView.builder(
            itemCount: trades.length,
            itemBuilder: (context, index) {
              final trade = trades[index];
              final dateFormat = DateFormat.yMd().add_jm(); // Keep date format
              final entryDateFormatted = dateFormat.format(trade.entryDate);
              final exitDateFormatted = dateFormat.format(trade.exitDate);

              // Determine P/L display and color
              final double plValue = trade.actualProfitLoss ?? 0.0; // Default to 0 if null
              final String plDisplay = trade.actualProfitLoss?.toStringAsFixed(2) ?? 'N/A';
              final Color plColor = plValue >= 0 ? Colors.green : Colors.red;

              // Determine direction icon and color
              final IconData directionIcon = trade.isLong ? Icons.arrow_upward : Icons.arrow_downward;
              final Color directionColor = trade.isLong ? Colors.green : Colors.red;

              // NEW: Return a Card instead of ListTile
              return Card(
                // Add margin for spacing between cards
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                // Use a shape for rounded corners
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                // Updated color to use lighter grey
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                // Updated elevation to 0 for a flat look
                elevation: 0.0,
                // Ensure InkWell ripple effect respects the rounded corners
                clipBehavior: Clip.antiAlias,
                child: InkWell( // Wrap content in InkWell for tap effect and navigation
                  onTap: () {
                    // Keep navigation logic
                    context.push('/trade/${trade.id}');
                  },
                  child: Padding(
                    // Add padding inside the card
                    padding: const EdgeInsets.all(12.0),
                    child: Row( // Use a Row for layout
                      children: [
                        // Leading: Direction Icon
                        Icon(directionIcon, color: directionColor, size: 28),
                        const SizedBox(width: 12), // Spacing

                        // Middle: Pair and Dates (Expanded to take available space)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trade.pair, // Pair Name
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Entry: $entryDateFormatted', // Entry Date
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Exit:  $exitDateFormatted', // Exit Date
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12), // Spacing

                        // Trailing: Profit/Loss
                        Text(
                          plDisplay,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: plColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        // Error state: Show error message
        error: (error, stackTrace) {
          // Log error for debugging
          print('Error fetching trades: $error');
          print(stackTrace);
          return Center(
            child: Text('Error loading trades: $error'),
          );
        },
        // Loading state: Show loading indicator
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('How to log trade?'),
                content: const Text('Choose your preferred method:'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Log with Voice'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close dialog
                      context.push('/add_trade_voice'); // Navigate to voice page
                    },
                  ),
                  TextButton(
                    child: const Text('Use Form'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close the dialog
                      context.push('/add_trade'); // Navigate to original form
                    },
                  ),
                  TextButton(
                    child: const Text('Use Journey'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Close the dialog
                      context.push('/add_trade_journey'); // Navigate to NEW journey page
                    },
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add Trade',
        child: const Icon(Icons.add),
      ),
    );
  }
}
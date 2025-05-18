import 'dart:convert'; // For jsonDecode
import 'dart:io'; // For File

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For formatting
import 'package:go_router/go_router.dart';

import '../../data/local/database.dart'; // For provider and Trade class

class TradeDetailPage extends ConsumerWidget {
  final int tradeId;

  const TradeDetailPage({required this.tradeId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider family, passing the specific tradeId
    final tradeAsyncValue = ref.watch(tradeProviderFamily(tradeId));

    return Scaffold(
      appBar: AppBar(
        title: tradeAsyncValue.maybeWhen(
           data: (trade) => Text(trade?.pair ?? 'Trade Details'), // Show pair in title
           orElse: () => const Text('Trade Details'),
        ),
        actions: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Trade',
            onPressed: () {
              final trade = tradeAsyncValue.valueOrNull;
              if (trade != null) {
                context.push('/add_trade', extra: trade);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot edit while loading or if trade not found.'))
                );
              }
            },
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Delete Trade',
            onPressed: () async {
              final bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to delete this trade permanently?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text('Delete'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete == true) {
                try {
                  final dao = ref.read(tradeDaoProvider);
                  await dao.deleteTrade(tradeId);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Trade deleted successfully!'))
                    );
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete trade: $e'))
                    );
                  }
                  print('Error deleting trade: $e');
                }
              }
            },
          ),
        ],
      ),
      body: tradeAsyncValue.when(
        data: (trade) {
          if (trade == null) {
            return const Center(child: Text('Trade not found.'));
          }

          // Keep data parsing logic here
          final dateFormat = DateFormat.yMd().add_jm();
          final List<String> customTags = trade.customTagsJson != null
              ? List<String>.from(jsonDecode(trade.customTagsJson!))
              : [];
          final List<String> imagePaths = trade.imagePathsJson != null
              ? List<String>.from(jsonDecode(trade.imagePathsJson!))
              : [];

          // Define card styling
          final cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
          final cardColor = Theme.of(context).colorScheme.surfaceContainerLow;
          const cardMargin = EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0);
          const cardPadding = EdgeInsets.all(16.0);
          const double cardElevation = 0.0;

          // --- Replace old SingleChildScrollView body ---
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Card 1: Core Info ---
                Card(
                  margin: cardMargin, shape: cardShape, color: cardColor, elevation: cardElevation,
                  child: Padding(
                    padding: cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Pair:', trade.pair),
                        _buildDetailRow('Direction:', trade.isLong ? 'Long' : 'Short'),
                        _buildDetailRow('Entry Time:', dateFormat.format(trade.entryDate)),
                        _buildDetailRow('Exit Time:', dateFormat.format(trade.exitDate)),
                        if (trade.actualProfitLoss != null)
                          _buildDetailRow(
                            'Net P/L:',
                            NumberFormat.currency(symbol: '\$').format(trade.actualProfitLoss),
                          ),
                      ],
                    ),
                  ),
                ),

                // --- Card 2: Order Details ---
                Card(
                  margin: cardMargin, shape: cardShape, color: cardColor, elevation: cardElevation,
                  child: Padding(
                    padding: cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Details', style: Theme.of(context).textTheme.titleLarge),
                        const Divider(height: 20),
                        _buildDetailRow('Entry Price:', trade.entryPrice.toString()),
                        _buildDetailRow('Exit Price:', trade.exitPrice.toString()),
                        _buildDetailRow('Position Size (Lots):', trade.positionSizeLots.toString()),
                        if (trade.stopLossPrice != null)
                          _buildDetailRow('Stop Loss:', trade.stopLossPrice.toString()),
                        if (trade.takeProfitPrice != null)
                          _buildDetailRow('Take Profit:', trade.takeProfitPrice.toString()),
                        if (trade.commissionFees != null)
                          _buildDetailRow('Commissions:', NumberFormat.currency(symbol: '\$').format(trade.commissionFees)),
                        if (trade.swapFees != null)
                          _buildDetailRow('Swaps:', NumberFormat.currency(symbol: '\$').format(trade.swapFees)),
                      ],
                    ),
                  ),
                ),

                // --- Card 3: Strategy & Notes ---
                Card(
                  margin: cardMargin, shape: cardShape, color: cardColor, elevation: cardElevation,
                  child: Padding(
                    padding: cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Strategy & Notes', style: Theme.of(context).textTheme.titleLarge),
                        const Divider(height: 20),
                        if (trade.strategyId != null)
                          _buildDetailRow('Strategy ID:', trade.strategyId.toString()),
                        if (trade.confidenceScore != null)
                          _buildDetailRow('Confidence:', '${trade.confidenceScore} / 5 Stars'),
                        if (trade.reasonForEntry != null && trade.reasonForEntry!.isNotEmpty)
                          _buildDetailSection('Reason for Entry:', trade.reasonForEntry!),
                        if (trade.reasonForExit != null && trade.reasonForExit!.isNotEmpty)
                          _buildDetailSection('Reason for Exit/Management:', trade.reasonForExit!),
                      ],
                    ),
                  ),
                ),

                // --- Card 4: Custom Tags (If any) ---
                if (customTags.isNotEmpty)
                  Card(
                    margin: cardMargin, shape: cardShape, color: cardColor, elevation: cardElevation,
                    child: Padding(
                      padding: cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Custom Tags', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0, runSpacing: 4.0,
                            children: customTags.map((tag) => Chip(label: Text(tag))).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // --- Card 5: Screenshots (If any) ---
                if (imagePaths.isNotEmpty)
                  Card(
                    margin: cardMargin, shape: cardShape, color: cardColor, elevation: cardElevation,
                    child: Padding(
                      padding: cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Screenshots', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0, runSpacing: 8.0,
                            children: imagePaths.map((path) => _buildImageThumbnail(context, path, imagePaths)).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        error: (error, stack) => Center(child: Text('Error loading trade details: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // Helper widget for simple key-value rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
   // Helper widget for multi-line text sections
  Widget _buildDetailSection(String label, String value) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 8.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 4),
           Text(value),
         ],
       ),
     );
   }

   // MODIFY Helper widget for image thumbnails
   Widget _buildImageThumbnail(BuildContext context, String path, List<String> allPaths) {
      final currentIndex = allPaths.indexOf(path); // Find index of this path
      final isNetwork = path.startsWith('http');

      return GestureDetector(
        onTap: () {
          print('Tapped image index: $currentIndex'); // Debug print
          // Navigate to fullscreen viewer, passing all paths and the tapped index
          context.push('/image_view', extra: {
             'imageUrls': allPaths,
             'initialIndex': currentIndex >= 0 ? currentIndex : 0, // Handle not found case
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: isNetwork
             ? Image.network( // Use NetworkImage for Supabase URLs
                 path,
                 width: 100, height: 100, fit: BoxFit.cover,
                 loadingBuilder: (context, child, progress) =>
                   progress == null ? child : Container(width: 100, height: 100, color: Colors.grey[300], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                 errorBuilder: (context, error, stackTrace) =>
                   Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
               )
             : Image.file( // Use FileImage for local paths (if any left)
                 File(path),
                 width: 100, height: 100, fit: BoxFit.cover,
                 errorBuilder: (context, error, stackTrace) =>
                   Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
               ),
        ),
      );
   }
}
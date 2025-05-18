import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import go_router

// Import the pages we just created
import 'dashboard_page.dart';
import 'trade_list_page.dart';
import 'report_page.dart'; // Import ReportPage

// State provider to keep track of the selected index
final selectedPageIndexProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // List of the pages to be displayed
  final List<Widget> _pages = const [
    DashboardPage(),
    TradeListPage(),
    ReportPage(), // Add ReportPage placeholder
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedPageIndexProvider);
    // Define titles for each page index
    final List<String> pageTitles = ['Dashboard', 'Trades', 'Report']; // Adjust if you add more tabs later

    return Scaffold(
      appBar: AppBar(
        // Set title dynamically
        title: Text(pageTitles[selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          // Update the state provider when an item is tapped
          ref.read(selectedPageIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Trades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined), // Or Icons.summarize, etc.
            label: 'Report',
          ),
        ],
      ),
    );
  }
}
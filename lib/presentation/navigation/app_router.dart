import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

// Import your main page
import '../pages/home_page.dart';
// Import other pages if you need named routes later
import '../pages/add_trade_page.dart'; // Import AddTradePage
import '../../data/local/database.dart' show Trade; // Import Trade
import '../pages/settings/settings_page.dart'; // Import SettingsPage
import '../pages/settings/manage_strategies_page.dart'; // Import ManageStrategiesPage
import '../pages/settings/add_edit_strategy_page.dart'; // NEW: Import the Add/Edit page
import '../pages/trade_detail_page.dart'; // NEW: Import detail page
// NEW: Import pair management pages
import '../pages/settings/manage_pairs_page.dart';
import '../pages/settings/add_edit_pair_page.dart';
import '../pages/auth/login_page.dart'; // Import Login Page
import '../pages/auth/signup_page.dart'; // Import Signup Page
import '../pages/image_view_page.dart'; // Import ImageViewPage
import '../pages/add_trade_journey_page.dart'; // <-- ADD THIS LINE
import '../pages/add_trade_voice_page.dart'; // <-- ADD THIS
// Import the Strategy data class
import '../../data/local/database.dart' show Strategy;
// Provider for the router instance
final routerProvider = Provider<GoRouter>((ref) {
  // Get the Supabase auth instance
  final auth = Supabase.instance.client.auth;

  return GoRouter(
    initialLocation: '/', // Still start trying to go to home

    // --- NEW: Listen to auth changes to trigger redirects ---
    refreshListenable: GoRouterRefreshStream(auth.onAuthStateChange),

    // --- NEW: Redirect Logic ---
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      final bool loggedIn = auth.currentUser != null;

      // If user is NOT logged in and trying to access anything other than login/signup -> redirect to login
      if (!loggedIn && !loggingIn) {
        return '/login';
      }

      // If user IS logged in and trying to access login/signup -> redirect to home
      if (loggedIn && loggingIn) {
        return '/';
      }

      // Otherwise, no redirect needed
      return null;
    },

    // --- Routes ---
    routes: [
      // Existing Routes (now protected by redirect)
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/add_trade',
        builder: (context, state) {
          final Trade? tradeToEdit = state.extra as Trade?;
          // Build AddTradePage, passing the optional trade
          return AddTradePage(tradeToEdit: tradeToEdit);
        },
      ),
      GoRoute(
        path: '/add_trade_journey', // The path for the new page
        builder: (context, state) => const AddTradeJourneyPage(), // Builds the page
      ),
      // --- ADD THIS NEW ROUTE ---
      GoRoute(
        path: '/add_trade_voice', // The path for the voice page
        builder: (context, state) => const AddTradeVoicePage(), // Builds the new page
      ),
      // --- END ADDED ROUTE ---
      GoRoute(
        path: '/image_view',
        builder: (context, state) {
          // Extract arguments passed via 'extra'
          final arguments = state.extra as Map<String, dynamic>?;
          final List<String> imageUrls = arguments?['imageUrls'] ?? [];
          final int initialIndex = arguments?['initialIndex'] ?? 0;

          if (imageUrls.isEmpty) {
          // Handle error case: navigate back or show error
          return const Scaffold(body: Center(child: Text('No image URLs provided')));
        }
        return ImageViewPage(imageUrls: imageUrls, initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: '/trade/:tradeId',
        builder: (context, state) {
          // Extract the ID from the path parameters
          final tradeId = int.tryParse(state.pathParameters['tradeId'] ?? '');
          if (tradeId == null) {
            // Handle invalid ID case, maybe redirect or show error
            return const Scaffold(body: Center(child: Text('Invalid Trade ID')));
          }
          return TradeDetailPage(tradeId: tradeId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'strategies', // Path will be /settings/strategies
            builder: (context, state) => const ManageStrategiesPage(),
            routes: [
              GoRoute(
                path: 'add', // Path: /settings/strategies/add
                builder: (context, state) {
                  // Check if a Strategy object was passed via 'extra' for editing
                  final Strategy? strategyToEdit = state.extra as Strategy?;
                  // Pass it to the page constructor
                  return AddEditStrategyPage(strategyToEdit: strategyToEdit);
                },
              ),
              // TODO: Add route for editing later ('edit/:id')
            ],
          ),
          GoRoute(
            path: 'pairs', // Path: /settings/pairs
            builder: (context, state) => const ManagePairsPage(),
            routes: [
              GoRoute(
                path: 'add', // Path: /settings/pairs/add
                builder: (context, state) {
                  // No longer needs to check 'extra' here
                  return const AddEditPairPage(editPairId: null); // Explicitly pass null ID
                },
              ),
              // NEW: Route for editing existing pairs using ID from path
              GoRoute(
                path: 'edit/:pairId', // Path: /settings/pairs/edit/123
                builder: (context, state) {
                  // Extract ID from path parameter
                  final String? idParam = state.pathParameters['pairId'];
                  final int? editPairId = int.tryParse(idParam ?? '');
                  if (editPairId == null) {
                    // Handle invalid/missing ID - maybe redirect or show error page
                    print("Error: Invalid Pair ID in route: $idParam");
                    // Return an error view or redirect, for now just build Add page
                    return const AddEditPairPage(editPairId: null);
                  }
                  // Pass the ID to the page constructor
                  return AddEditPairPage(editPairId: editPairId);
                },
              ),
            ],
          ),
          // TODO: Add sub-routes for managing tags, etc. later
        ],
      ),

      // NEW: Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

// Helper class needed for refreshListenable (add this outside the provider)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
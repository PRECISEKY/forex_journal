import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'data/remote/sync_service.dart'; // Import file containing performInitialSync

// Import the router provider
import 'package:forex_journal/presentation/navigation/app_router.dart';

Future<void> main() async { // Make main async
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // --- NEW: Initialize Supabase ---
  try {
    await Supabase.initialize(
      // Replace with YOUR Supabase URL and Anon Key
      url: 'https://kunpjbhgjmlcbphhpqbf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt1bnBqYmhnam1sY2JwaGhwcWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM3NjE1MTksImV4cCI6MjA1OTMzNzUxOX0.ZhsXDqsSI16zGDd5TWNGb8kcOeHS7i8SuTM6ttz4CJc',
    );
    print('Supabase initialized successfully!');
  } catch (e) {
    // Handle initialization error (important for production)
    print('Error initializing Supabase: $e');
    // Maybe show an error screen or prevent app start
    return; // Exit if Supabase fails to initialize
  }
  // --- End Supabase Initialization ---

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget { // Change here
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState(); // Change here
}

class _MyAppState extends ConsumerState<MyApp> { // New State class
  @override
  void initState() {
    super.initState();
    // Check auth state and trigger initial sync if logged in
    _triggerInitialSyncOnLoad();
  }

  Future<void> _triggerInitialSyncOnLoad() async {
    // Give Supabase client a moment to potentially load session
    await Future.delayed(const Duration(milliseconds: 100));
    final auth = Supabase.instance.client.auth;
    if (auth.currentUser != null) {
      print('User already logged in on startup, triggering initial sync...');
      // Trigger the sync using the provider
      ref.read(initialSyncTriggerProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep this watch:
    final router = ref.watch(routerProvider);

    // ---> ADD THIS LINE BACK (or ensure it's here) <---
    final baseTextTheme = GoogleFonts.jostTextTheme(Theme.of(context).textTheme);

    return MaterialApp.router(
      title: 'Forex Journal',

      // --- Light Theme ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0), // Using blueGrey as seed for subtle greys/blues
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Apply the font to the entire theme
        textTheme: baseTextTheme,
      ),

      // --- Dark Theme ---
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(0, 255, 255, 255), // Use the same seed for consistency
          brightness: Brightness.dark, // Important: Specify dark brightness
        ),
        useMaterial3: true,
        // Apply the font to the dark theme too
        textTheme: baseTextTheme.apply(
           bodyColor: Colors.white.withOpacity(0.87), // Adjust default text colors for dark mode
           displayColor: Colors.white.withOpacity(0.87),
        ),
      ),

      themeMode: ThemeMode.dark, // Or force .light / .dark
      routerConfig: router,
    );
  }
}

// Add a dummy provider that just triggers the sync when read
final initialSyncTriggerProvider = FutureProvider.autoDispose<void>((ref) async {
  print("Initial Sync Provider Triggered");
  // Ensure user is logged in before running (safety check)
  if (Supabase.instance.client.auth.currentUser != null) {
    // Read the service, then call its method (no 'ref' argument needed)
    await ref.read(syncServiceProvider).performInitialSync(); // CORRECTED CALL
  }
});

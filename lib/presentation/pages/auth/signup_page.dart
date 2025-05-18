import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use ConsumerStatefulWidget
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class SignupPage extends ConsumerStatefulWidget { // Change to ConsumerStatefulWidget
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // State for loading indicator

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; }); // Show loading indicator

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final supabase = Supabase.instance.client;

      try {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          // TODO: Add email redirect URL if using email confirmation in Supabase settings
          // emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
        );

         // Check if signup requires confirmation (depends on Supabase settings)
         final bool requiresConfirmation = response.user?.appMetadata['provider'] == 'email' && response.session == null;

         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(requiresConfirmation
                     ? 'Signup successful! Please check your email for a confirmation link.'
                     : 'Signup successful!'),
                 backgroundColor: Colors.green,
               ),
             );
             // Navigate back to login AFTER showing snackbar
              context.go('/login'); // Use go to replace stack
         }

      } on AuthException catch (e) {
        // Handle Supabase specific auth errors
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Signup failed: ${e.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
         }
      } catch (e) {
         // Handle other generic errors
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('An unexpected error occurred: $e'),
                 backgroundColor: Theme.of(context).colorScheme.error,
               ),
             );
          }
      } finally {
        // Ensure loading indicator is hidden even if errors occur
         if (mounted) {
            setState(() { _isLoading = false; });
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView( // Allow scrolling
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch button
              children: [
                const Text(
                  'Create your Journal Account',
                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                   textAlign: TextAlign.center,
                ),
                 const SizedBox(height: 30),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true, // Hide password
                  validator: (value) {
                     if (value == null || value.isEmpty || value.length < 6) {
                       return 'Password must be at least 6 characters';
                     }
                     return null;
                  },
                ),
                 const SizedBox(height: 30),
                // Signup Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp, // Disable button when loading
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 16),
                // Link to Login
                TextButton(
                  onPressed: _isLoading ? null : () => context.go('/login'), // Use go
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
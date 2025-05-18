import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/remote/sync_service.dart'; // CORRECT (3 dots)
class LoginPage extends ConsumerStatefulWidget { // Change to ConsumerStatefulWidget
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
   bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
     if (_formKey.currentState!.validate()) {
       setState(() { _isLoading = true; });

       final email = _emailController.text.trim();
       final password = _passwordController.text.trim();
       final supabase = Supabase.instance.client;

       try {
          await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          print('Login successful, starting initial sync...');
          // Read the service, then call its method (no 'ref' argument needed)
          await ref.read(syncServiceProvider).performInitialSync(); // CORRECTED CALL

           // Login successful - router redirect will handle navigation
           // No need to explicitly navigate here if redirect works
           // if (mounted) context.go('/'); // Usually not needed

       } on AuthException catch (e) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Login failed: ${e.message}'),
                 backgroundColor: Theme.of(context).colorScheme.error,
               ),
             );
          }
       } catch (e) {
            if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('An unexpected error occurred: $e'),
                 backgroundColor: Theme.of(context).colorScheme.error,
               ),
             );
          }
       } finally {
          if (mounted) {
             setState(() { _isLoading = false; });
          }
       }
     }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
             key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 const Text(
                  'Welcome Back!',
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
                    return null; // <<< ADD THIS LINE
                  },
                ),
                const SizedBox(height: 16),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null; // <<< ADD THIS LINE
                  },
                ),
                 const SizedBox(height: 30),
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _logIn,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Login'),
                ),
                 const SizedBox(height: 16),
                // Link to Signup
                TextButton(
                  onPressed: _isLoading ? null : () => context.push('/signup'), // Use push here
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
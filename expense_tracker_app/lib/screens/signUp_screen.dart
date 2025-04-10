import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_app/service/api_service.dart';
import 'package:expense_tracker_app/provider/exspense_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  final _secureStorage = const FlutterSecureStorage();

  bool _loading = false;
  String? _error;

  Future<void> _signup() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result['token'] != null) {
        // 🔐 Save token securely
        await _secureStorage.write(key: 'auth_token', value: result['token']);

        // 🧠 Fetch expenses immediately after signup
        final provider = context.read<ExpenseProvider>();
        await provider.fetchExpenses();

        if (!mounted) return;

        // 🚀 Navigate to your test/home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _error = result['error'] ?? 'Signup failed');
      }
    } catch (e) {
      setState(() => _error = 'Signup failed: ${e.toString()}');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color(0xFF0B2956),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter username' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (val) => val == null || val.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (val) =>
                        val == null || val.length < 6
                            ? 'Min 6 characters'
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2956),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    _loading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text("Sign Up"),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

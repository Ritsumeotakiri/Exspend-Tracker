import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:expense_tracker_app/service/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  final _secureStorage = const FlutterSecureStorage();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result['token'] != null) {
        // Store the token securely
        await _secureStorage.write(key: 'auth_token', value: result['token']);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        // Navigator.pushReplacementNamed(context, '/testing');
      } else {
        setState(() {
          _error = result['error'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login error: ${e.toString()}';
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Enter email' : null,
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
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2956),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    _loading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text("Login"),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

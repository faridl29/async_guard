import 'package:flutter/material.dart';
import 'package:async_guard/async_guard.dart';

void main() => runApp(const AsyncGuardExample());

class AsyncGuardExample extends StatelessWidget {
  const AsyncGuardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'async_guard Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const LoginPage(),
    );
  }
}

// ─── Simulated API ──────────────────────────────────────────────────────────

class FakeApi {
  /// Simulates a login request with a 2-second delay.
  static Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required.');
    }

    return 'token_abc123';
  }
}

// ─── Login Page ─────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'user@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  bool _isLoading = false;
  String? _result;
  String? _error;

  // ── Example 1: Using the top-level guard() function ────────────────────

  Future<void> _loginWithGuard() async {
    final token = await guard<String>(
      () => FakeApi.login(
        _emailController.text,
        _passwordController.text,
      ),
      id: 'login',
      onLoading: (loading) => setState(() {
        _isLoading = loading;
        if (loading) {
          _result = null;
          _error = null;
        }
      }),
      onSuccess: (token) =>
          setState(() => _result = 'Login success! Token: $token'),
      onError: (e) => setState(() => _error = 'Login failed: $e'),
      timeout: const Duration(seconds: 5),
    );

    debugPrint('guard() returned: $token');
  }

  // ── Example 2: Using the extension syntax ──────────────────────────────

  Future<void> _loginWithExtension() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    final token = await FakeApi.login(
      _emailController.text,
      _passwordController.text,
    ).guard(
      id: 'login_ext',
      onSuccess: (token) {
        if (mounted) setState(() => _result = 'Extension login! Token: $token');
      },
      onError: (e) {
        if (mounted) setState(() => _error = 'Extension failed: $e');
      },
    );

    if (mounted) setState(() => _isLoading = false);
    debugPrint('extension guard() returned: $token');
  }

  // ── Example 3: Using safeAsync for lifecycle safety ────────────────────

  @override
  void initState() {
    super.initState();
    // Safe to call async here without worrying about dispose.
    safeAsync(this, () async {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('initState async completed safely.');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('async_guard Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Input fields ─────────────────────────────────────────
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ── guard() button ───────────────────────────────────────
            ElevatedButton(
              onPressed: _isLoading ? null : _loginWithGuard,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login with guard()'),
            ),
            const SizedBox(height: 12),

            // ── Extension button ─────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loginWithExtension,
              icon: const Icon(Icons.extension),
              label: const Text('Login with .guard() extension'),
            ),
            const SizedBox(height: 12),

            // ── GuardedButton widget ────────────────────────────────
            const Divider(),
            Text(
              'GuardedButton widget (auto double-tap protection):',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            GuardedButton(
              onTap: () => FakeApi.login(
                _emailController.text,
                _passwordController.text,
              ),
              child: const Text('Submit with GuardedButton'),
            ),
            const SizedBox(height: 24),

            // ── Result display ───────────────────────────────────────
            if (_result != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _result!,
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
              ),
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

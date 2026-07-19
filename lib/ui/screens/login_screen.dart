import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [_usernameController.text.trim(), _passwordController.text.trim()],
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isNotEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainShell(userRole: result.first['role'].toString())));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Identifiants invalides')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF2ECC71)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.local_pharmacy_rounded, size: 70, color: Color(0xFF1E88E5)),
                  const SizedBox(height: 16),
                  const Text('PharmaOne', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Connexion sécurisée', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Nom d\'utilisateur', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _loading ? null : _login,
                    icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login),
                    label: Text(_loading ? 'Connexion...' : 'Se connecter'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Comptes de démonstration : admin/admin123, pharmacien/pharma123, caissier/caisse123', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'notes_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _apiService = ApiService();
  final _storageService = StorageService();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final token = await _apiService.login(username, password);

    if (token != null) {
      await _storageService.saveToken(token);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NotesScreen()),
      );
    } else {
      setState(() {
        _error = "Login failed. Check username and password.";
      });
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(
              onPressed: _goToRegister,
              child: Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _apiService = ApiService();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  String? _error;
  String? _success;

  void _register() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    if (password != passwordConfirm) {
      setState(() {
        _error = "Passwords do not match";
        _success = null;
      });
      return;
    }

    final request = await _apiService.register(username, password, passwordConfirm);

    debugPrint(jsonEncode(request));

    if (request != null && request[0]['status'] == 'success') {
      setState(() {
        _error = null;
        _success = "success.";
      });
    } else {
      setState(() {
        _error = request != null ? request[0]['message'] : "registration failed";
        _success = null;
      });
    }
  }

  void _goToLogin() {
    Navigator.pop(context); // просто назад к логину
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            if (_success != null)
              Text(_success!, style: TextStyle(color: Colors.green)),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _passwordConfirmController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: Text('Register')),
            TextButton(
              onPressed: _goToLogin,
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

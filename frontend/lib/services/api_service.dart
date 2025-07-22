import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://10.0.2.2:8080'; 

  Future<List<dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data; 
      } else {
        return [data]; 
      }
    } else {
      return null;
    }
  }

  Future<List<dynamic>?> register(String username, String password, String passwordConfirm) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'password_confirm': passwordConfirm,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data; 
      } else {
        return [data]; 
      }
    } else {
      return null;
    }
  }

}

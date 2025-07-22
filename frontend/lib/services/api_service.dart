import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

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

  Future<List<dynamic>?> createNote(String title) async {
    final token = await StorageService().getToken();
    final idUser = await StorageService().getUserIdInt();
    final response = await http.post(
      Uri.parse('$baseUrl/api/createNote'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'id_user': idUser,
      }),
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

  Future<Map<String, dynamic>?> getUserNotes() async {
    final token = await StorageService().getToken();
    final idUser = await StorageService().getUserIdInt();

    final response = await http.post(
      Uri.parse('$baseUrl/api/getAllUserNotes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_user': idUser,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?>? getNoteById(int noteID) async {
    final token = await StorageService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/getNoteById'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
          'id_note': noteID,
        }),
      );

    if (response.statusCode == 200 || response.statusCode == 400) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
      } else {
        return null;
    }
  }

  Future<bool> updateNote(int noteId, String text) async {
    final token = await StorageService().getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/updateNote'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_note': noteId,
        'content': text,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteNote(int noteId) async {
    final token = await StorageService().getToken(); 
    final response = await http.post(
      Uri.parse('$baseUrl/api/deleteNote'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_note': noteId,
      }),
    );

    return response.statusCode == 200;
  }
}

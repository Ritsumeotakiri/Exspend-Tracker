import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://ce40-175-100-11-25.ngrok-free.app/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': 'Login failed', 'statusCode': response.statusCode};
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {'error': 'Signup failed', 'statusCode': response.statusCode};
    }
  }
}

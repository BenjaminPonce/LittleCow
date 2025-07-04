import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  
  static Future<String?> login(String username, String password) async {
    final url = Uri.parse("${ApiService.baseUrl}/login/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );  

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await ApiService.setToken(data['token']);
        return data['token'];

      } else {
        return null;
      }
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }  

  static void logout() async {
    ApiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  static Future<Map<String, dynamic>> register(String username, String password, String sexo, String correo) async {
    final url = Uri.parse("${ApiService.baseUrl}/register/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "sexo": sexo,
          "correo": correo,
        }),
      );

      print("Register response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 201) {
      return {"success": true};
    } else {
      
      try {
        final data = jsonDecode(response.body);
        String errorMsg = "";
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMsg += "$key: ${value.join(", ")}\n";
            } else {
              errorMsg += "$key: $value\n";
            }
          });
        } else {
          errorMsg = data.toString();
        }
        return {"success": false, "error": errorMsg.trim()};
      } catch (e) {
        return {"success": false, "error": "Error desconocido del backend"};
      }
    }
    } catch (e) {
    print("Error en registro: $e");
    return {"success": false, "error": "Error de conexión"};
    }
  }
}
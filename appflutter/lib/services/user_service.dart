import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class UserService {
  
  static Future<Map<String, dynamic>?> getPerfilUsuario() async {
    final url = Uri.parse("${ApiService.baseUrl}/perfil/");
    if (ApiService.token == null) return null;

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}"
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error al obtener perfil: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Excepción al obtener perfil: $e");
      return null;
    }
  }

    static Future<List<Map<String, dynamic>>> getMisGrupos() async {
  final url = Uri.parse("${ApiService.baseUrl}/mis-grupos/");
    if (ApiService.token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}"
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("Error al obtener grupos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Excepción al obtener grupos: $e");
      return [];
    }
  }
}
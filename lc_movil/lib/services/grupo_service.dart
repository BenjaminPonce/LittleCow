import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crear_grupo_model.dart';

class GrupoService {
  static const String baseUrl = "http://localhost:8000/api";

  // NUEVO: headers dinámicos
  Map<String, String> getHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Token $token',
  };

  Future<Map<String, dynamic>> crearGrupoCompleto(GrupoCreacion grupo, String token) async {
    try {
      print('Enviando: ${grupo.toJson()}'); // Debug
      final response = await http.post(
        Uri.parse('$baseUrl/grupos/crear_grupo_completo/'),
        headers: getHeaders(token),
        body: json.encode(grupo.toJson()),
      );

      print('Respuesta: ${response.statusCode} ${response.body}'); // Debug crucial

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error en servicio: $e'); // Debug
      rethrow;
      }
  }

  Future<Map<String, dynamic>> agregarIntegrante({
    required String grupoId,
    required String username,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/grupos/$grupoId/agregar_integrante/'),
        headers: getHeaders(token),
        body: json.encode({'username': username}),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al agregar integrante: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> distribuirGasto({
    required String grupoId,
    required double montoTotal,
    required String distribucion,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/grupos/$grupoId/distribuir_gasto'),
        headers: getHeaders(token),
        body: json.encode({
          'monto_total': montoTotal,
          'distribucion': distribucion,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al distribuir gasto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsuarios(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/'),
        headers: getHeaders(token),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Error al cargar usuarios');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
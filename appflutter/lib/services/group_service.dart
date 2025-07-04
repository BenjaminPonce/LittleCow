import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class GroupService {  

  static Future<int?> crearGrupo(String nombre, double ingreso) async {
    final url = Uri.parse("${ApiService.baseUrl}/crear-grupo/");
    if (ApiService.token == null) return null;

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}"
        },
        body: jsonEncode({
          "nombre": nombre,
          "ingreso_personal": ingreso,
        }),
      );

      print("Crear grupo response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        print("Error al crear grupo: ${response.body}");
      }

      return null;
    } catch (e) {
      print("Excepción al crear grupo: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDetalleGrupo(int grupoId) async {
    final url = Uri.parse("${ApiService.baseUrl}/detalle-grupo/$grupoId/");
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
        print("Error al obtener detalle del grupo: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Excepción al obtener detalle grupo: $e");
      return null;
    }
  }

  static Future<String?> agregarIntegrante({
    required int grupoId,
    required String username,
    required double ingreso,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/grupos/$grupoId/agregar-integrante/");
    if (ApiService.token == null) return null;

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}"
        },
        body: jsonEncode({
          "username": username,
          "ingreso_personal": ingreso,
        }),
      );

      if (response.statusCode == 201) {
        return null; // éxito
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Error desconocido';
      }
    } catch (e) {
      print("Error al agregar integrante: $e");
      return 'Error de red';
    }
  }

  static Future<String?> eliminarIntegrante({
    required int grupoId,
    required String username,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/grupos/$grupoId/eliminar-integrante/");
    if (ApiService.token == null) return null;

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}"
        },
        body: jsonEncode({
          "username": username,
        }),
      );

      if (response.statusCode == 200) {
        return null; // éxito
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Error desconocido';
      }
    } catch (e) {
      print("Error al eliminar integrante: $e");
      return 'Error de red';
    }
  }

    static Future<String?> eliminarGrupo(int grupoId) async {
    final url = Uri.parse("${ApiService.baseUrl}/grupos/$grupoId/eliminar-grupo/");
    if (ApiService.token == null) return 'Sesión no válida';

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}"
        },
      );

      if (response.statusCode == 200) return null;
      final data = jsonDecode(response.body);
      return data['error'] ?? 'Error desconocido';
    } catch (e) {
      print("Error al eliminar grupo: $e");
      return 'Error de red';
    }
  }

  static Future<String?> salirDeGrupo(int grupoId) async {
    final url = Uri.parse("${ApiService.baseUrl}/grupos/$grupoId/salir/");
    if (ApiService.token == null) return 'Sesión no válida';

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}"
        },
      );

      if (response.statusCode == 200) return null;
      final data = jsonDecode(response.body);
      return data['error'] ?? 'Error desconocido';
    } catch (e) {
      print("Error al salir del grupo: $e");
      return 'Error de red';
    }
  }

  static Future<String?> reportarIntegrante({
    required int grupoId,
    required String username,
    required String comentario,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/grupos/$grupoId/reportar/");
    if (ApiService.token == null) return 'No autenticado';

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}"
        },
        body: jsonEncode({
          "reportado_username": username,
          "comentario": comentario,
        }),
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Error al reportar';
      }
    } catch (e) {
      print("Error al reportar integrante: $e");
      return 'Error de red';
    }
  }
}
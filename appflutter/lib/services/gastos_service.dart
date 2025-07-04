import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class GastosService {

  static Future<bool> distribuirGasto({
    required int grupoId,
    required String metodo, // 'EQUITATIVO' o 'PERSONALIZADO'
    Map<String, double>? porcentajes,
    }) async {
    final url = Uri.parse("${ApiService.baseUrl}/grupos/$grupoId/distribuir-gasto/");
    if (ApiService.token == null) return false;

    final Map<String, dynamic> body = {
    "metodo_distribucion": metodo,
    };

    if (metodo == "PERSONALIZADO" && porcentajes != null) {
    body["porcentajes"] = Map<String, dynamic>.from(porcentajes);
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}",
        },
        body: jsonEncode(body),
      );

      print("Distribuir gasto response: ${response.statusCode} - ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error al distribuir gasto: $e");
      return false;
    }
  }  

  static Future<bool> modificarGasto({
    required int grupoId,
    required double montoNuevo,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/grupos/$grupoId/modificar-gasto/");
    if (ApiService.token == null) return false;

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}",
        },
        body: jsonEncode({"monto_total": montoNuevo}),
      );

      print("Modificar gasto response: ${response.statusCode} - ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error al modificar gasto: $e");
      return false;
    }
  }

  static Future<bool> crearGastoPersonalizado({
    required double monto,
    required String metodo,
    required int grupoId,
    Map<String, double>? porcentajes,
  }) async {
    final url = Uri.parse("${ApiService.baseUrl}/crear-gasto/");
    if (ApiService.token == null) return false;

    final body = {
      "monto_total": monto,
      "metodo_distribucion": metodo,
      "grupo": grupoId,
    };

    if (metodo == 'PERSONALIZADO' && porcentajes != null) {
      body['porcentajes'] = porcentajes;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token ${ApiService.token}",
        },
        body: jsonEncode(body),
      );

      print("Respuesta gasto: ${response.statusCode} - ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("Error al crear gasto: $e");
      return false;
    }
  }  
}
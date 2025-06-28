import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8000/api/"; // Usa la IP de tu backend si es necesario

  Future<List<dynamic>> getGastos() async {
    final response = await http.get(Uri.parse('${baseUrl}gastos/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar gastos');
    }
  }

    // Nuevo método para crear gastos
  Future<Map<String, dynamic>> crearGasto({
    required String descripcion,
    required double monto,
    required int pagadorId,
    required int grupoId,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl}gastos/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'descripcion': descripcion,
        'monto': monto,
        'pagador': pagadorId,
        'grupo': grupoId,
      }),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al crear gasto: ${response.body}');
    }
  }
}


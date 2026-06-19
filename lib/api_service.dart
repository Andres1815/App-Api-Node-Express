import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "http://10.0.2.2:3000";

  static Future<List<dynamic>> getRetos() async {
    final response =
        await http.get(Uri.parse('$baseUrl/retos'));

    return jsonDecode(response.body);
  }

  static Future<void> crearReto(
      String titulo,
      String descripcion) async {

    await http.post(
      Uri.parse('$baseUrl/retos'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(
        {
        'titulo': titulo,
        'descripcion': descripcion,
        'completado': false
      }
      
      ),
    );
  }

  static Future<void> actualizarReto(
      int id,
      bool completado) async {

    await http.put(
      Uri.parse('$baseUrl/retos/$id'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'completado': completado
      }),
    );
  }

  static Future<void> eliminarReto(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/retos/$id'),
    );
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/cita_model.dart';

class ApiServiceCita {
  static const String baseUrl = '${Config.baseUrl}/api/citas';

  static Future<List<Cita>> listarCitas() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Cita>.from(data.map((model) => Cita.fromJson(model)));
    } else {
      throw Exception('Failed to load citas');
    }
  }

  static Future<void> agregarCita(Cita cita) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(cita.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add cita: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Cita?> obtenerCita(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Cita.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to get cita');
    }
  }

  static Future<void> editarCita(int id, Cita cita) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(cita.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update cita: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> eliminarCita(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete cita');
    }
  }
}
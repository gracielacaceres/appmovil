import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/venta_model.dart'; // Asegúrate de tener este archivo

class VentaService {
  static const String baseUrl = '${Config.baseUrl}/api/ventas';

  static Future<List<Venta>> getActiveVentas() async {
    final response = await http.get(Uri.parse('$baseUrl/estado/activo'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Venta>.from(data.map((model) => Venta.fromJson(model)));
    } else {
      throw Exception('Failed to load active ventas');
    }
  }

  static Future<List<Venta>> getInactiveVentas() async {
    final response = await http.get(Uri.parse('$baseUrl/estado/inactivo'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Venta>.from(data.map((model) => Venta.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive ventas');
    }
  }

  static Future<Venta> getVentaById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Venta.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load venta');
    }
  }

  static Future<void> createVenta(Venta venta) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registrar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(venta.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create venta: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateVenta(int id, Venta venta) async {
    final url = Uri.parse('$baseUrl/$id');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode(venta.toJson());

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Handle success case
      } else {
        throw Exception(
            'Failed to update venta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update venta: $e');
    }
  }

  static Future<void> logicalDeleteVenta(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/eliminar/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to logically delete venta');
    }
  }

  static Future<void> activateVenta(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/restaurar/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate venta');
    }
  }
}
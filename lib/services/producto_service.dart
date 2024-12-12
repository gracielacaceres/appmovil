import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/producto_model.dart';

class ApiServiceProducto {
  static const String baseUrl = '${Config.baseUrl}/api/productos';

  static Future<List<Producto>> listarProductos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Producto>.from(data.map((model) => Producto.fromJson(model)));
    } else {
      throw Exception('Failed to load productos');
    }
  }

  static Future<void> agregarProducto(Producto producto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(producto.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception(
          'Failed to add producto: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Producto?> obtenerProducto(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Producto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to get producto');
    }
  }

  static Future<void> editarProducto(int id, Producto producto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(producto.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update producto: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> eliminarProducto(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/eliminar/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete producto: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> restaurarProducto(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/restaurar/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to restore producto: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<bool> checkExistingProducto(String nombre) async {
    final response = await http.get(Uri.parse('$baseUrl/check-nombre/$nombre'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as bool;
    } else {
      throw Exception('Failed to check if category name exists');
    }
  }
}
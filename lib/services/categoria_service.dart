import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/categoria_model.dart';

class ApiServiceCategoria {
  static const String baseUrl = '${Config.baseUrl}/api/categorias';

  static Future<List<Categoria>> listarCategorias() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Categoria>.from(data.map((model) => Categoria.fromJson(model)));
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Categoria>> listarCategoriasPorEstado(String estado) async {
    final response = await http.get(Uri.parse('$baseUrl/estado/$estado'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Categoria>.from(data.map((model) => Categoria.fromJson(model)));
    } else {
      throw Exception('Failed to load categories by state');
    }
  }

  static Future<void> agregarCategoria(Categoria categoria) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(categoria.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add category: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Categoria?> obtenerCategoria(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Categoria.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to get category');
    }
  }

  static Future<void> editarCategoria(int id, Categoria categoria) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(categoria.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update category: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> eliminarCategoria(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/eliminar/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }

  static Future<void> restaurarCategoria(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/restaurar/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to restore category');
    }
  }

  static Future<bool> checkExistingCategoria(String nombre) async {
    final response = await http.get(Uri.parse('$baseUrl/check-nombre/$nombre'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as bool;
    } else {
      throw Exception('Failed to check if category name exists');
    }
  }
}
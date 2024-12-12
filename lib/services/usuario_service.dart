import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/usuario_model.dart';

class ApiServiceUsuario {
  static const String baseUrl = '${Config.baseUrl}/usuarios';

  static Future<Usuario?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Credenciales incorrectas');
    }
  }

  static Future<List<Usuario>> listarUsuarios() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Usuario>.from(data.map((model) => Usuario.fromJson(model)));
    } else {
      throw Exception('Failed to load usuarios');
    }
  }

  static Future<void> agregarUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(usuario.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add usuario: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Usuario?> obtenerUsuario(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Usuario.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to get usuario');
    }
  }

  static Future<void> editarUsuario(int id, Usuario usuario) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(usuario.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update usuario: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> eliminarUsuario(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete usuario');
    }
  }

  static Future<void> recuperarCuenta(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/recuperar/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to restore usuario');
    }
  }

  static Future<bool> checkExistingUsuario(String nombre) async {
    final response = await http.get(Uri.parse('$baseUrl/check-nombre/$nombre'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as bool;
    } else {
      throw Exception('Failed to check if category name exists');
    }
  }

  static Future<List<Usuario>> getActiveUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/activos'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Usuario>.from(data.map((model) => Usuario.fromJson(model)));
    } else {
      throw Exception('Failed to load active usuarios');
    }
  }

  static Future<List<Usuario>> getInactiveUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/inactivos'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Usuario>.from(data.map((model) => Usuario.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive usuarios');
    }
  }
}
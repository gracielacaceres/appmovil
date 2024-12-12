import 'package:flutter/material.dart';
import 'package:myapp/models/usuario_model.dart';
import 'package:myapp/services/usuario_service.dart';

class UsuarioSelectionScreen extends StatefulWidget {
  const UsuarioSelectionScreen({super.key});

  @override
  _UsuarioSelectionScreenState createState() => _UsuarioSelectionScreenState();
}

class _UsuarioSelectionScreenState extends State<UsuarioSelectionScreen> {
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  late TextEditingController _controladorBusqueda;

  @override
  void initState() {
    super.initState();
    _controladorBusqueda = TextEditingController();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
  try {
    final usuarios = await ApiServiceUsuario.getActiveUsuarios();
    setState(() {
      _usuarios = usuarios;
      _usuariosFiltrados = usuarios;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar los usuarios: $e'),
      ),
    );
  }
}

  void _filtrarUsuarios(String consulta) {
    setState(() {
      _usuariosFiltrados = _usuarios
          .where((usuario) =>
              usuario.nombre!.toLowerCase().contains(consulta.toLowerCase()) ||
              usuario.apellido!.toLowerCase().contains(consulta.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 172, 221),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Lista de Usuarios',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controladorBusqueda,
              decoration: InputDecoration(
                labelText: 'Buscar usuario',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filtrarUsuarios,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _usuariosFiltrados.length,
              itemBuilder: (context, index) {
                final usuario = _usuariosFiltrados[index];
                return ListTile(
                  title: Text('${usuario.nombre} ${usuario.apellido}'),
                  onTap: () {
                    Navigator.pop(context, usuario);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }
}

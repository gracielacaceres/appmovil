// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/screens/pages/usuario/usuario_modal_page.dart';
import 'package:myapp/services/usuario_service.dart';
import 'package:myapp/models/usuario_model.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late List<Usuario> _usuarioList = [];
  late List<Usuario> _filteredUsuarioList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterUsuarios);
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
  try {
    List<Usuario> activeUsuarios = await ApiServiceUsuario.getActiveUsuarios();
    List<Usuario> inactiveUsuarios = await ApiServiceUsuario.getInactiveUsuarios();
    _usuarioList = [...activeUsuarios, ...inactiveUsuarios];
    _usuarioList.sort((a, b) => a.nombre!.compareTo(b.nombre!)); // Ordena por nombres
    _filteredUsuarioList = _usuarioList; // Inicialmente, muestra todos los usuarios
    setState(() {});
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar los usuarios: $e')),
    );
  }
}

  void _filterUsuarios() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsuarioList = _usuarioList.where((usuario) {
        return usuario.nombre!.toLowerCase().contains(query) ||
            usuario.apellido!.toLowerCase().contains(query) ||
            (usuario.email != null && usuario.email!.toLowerCase().contains(query)) ||
            usuario.tipoDeDocumento!.toLowerCase().contains(query) ||
            usuario.numeroDeDocumento!.contains(query);
      }).toList();
      _filteredUsuarioList.sort((a, b) => a.nombre!.compareTo(b.nombre!)); // Ordena la lista filtrada
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const SizedBox(height: 16.0), // Espacio de 16.0 puntos arriba del TextField
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar usuarios',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      _navigateToUsuarioDetail(Usuario.empty());
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                child: Text(
                  'Activos',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Inactivos',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildUsuarioList(true),
                  _buildUsuarioList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsuarioList(bool showActive) {
    List<Usuario> filteredUsuarios = _filteredUsuarioList
        .where((usuario) => usuario.activo == (showActive ? 1 : 0))
        .toList();

    if (filteredUsuarios.isEmpty) {
      return Center(
        child: Text(showActive
            ? 'No hay Usuarios activos'
            : 'No hay Usuarios inactivos'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredUsuarios.length,
      itemBuilder: (context, index) {
        Usuario usuario = filteredUsuarios[index];
        bool isActive = usuario.activo == 1;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              '${usuario.nombre} ${usuario.apellido}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '${usuario.tipoDeDocumento}: ${usuario.numeroDeDocumento}',
              style: const TextStyle(
                color: Color.fromARGB(255, 79, 79, 79),
                fontSize: 12,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '${usuario.nombre!.substring(0, 1)}${usuario.apellido!.substring(0, 1)}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            trailing: isActive
                ? IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Color.fromARGB(255, 248, 0, 0),
                      size: 20,
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, usuario);
                    },
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.restore,
                      color: Color.fromARGB(255, 0, 104, 248),
                      size: 20,
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, usuario);
                    },
                  ),
            onTap: () {
              if (isActive) {
                _navigateToUsuarioDetail(usuario);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se puede abrir el formulario para usuarios inactivos.',
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    );
  }

  void _showConfirmationDialog(BuildContext context, Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              usuario.activo == 1 ? "Eliminar Usuario" : "Restaurar Usuario"),
          content: Text(usuario.activo == 1
              ? "¿Estás seguro de eliminar este usuario?"
              : "¿Estás seguro de restaurar este usuario?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (usuario.activo == 1) {
                  _deleteUsuario(context, usuario.idUsuario!);
                } else {
                  _restoreUsuario(context, usuario.idUsuario!);
                }
              },
              child: Text(
                  usuario.activo == 1 ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteUsuario(BuildContext context, int usuarioId) async {
    try {
      await ApiServiceUsuario.eliminarUsuario(usuarioId);
      _loadUsuarios();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el usuario: $e')),
      );
    }
  }

  void _restoreUsuario(BuildContext context, int usuarioId) async {
    try {
      await ApiServiceUsuario.recuperarCuenta(usuarioId);
      _loadUsuarios();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario restaurado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar el usuario: $e')),
      );
    }
  }

  void _handleUsuarioSaved(Usuario usuario, bool isNewUsuario) {
    _loadUsuarios();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewUsuario
              ? 'Usuario insertado exitosamente'
              : 'Usuario editado exitosamente',
        ),
      ),
    );
  }

  void _navigateToUsuarioDetail(Usuario usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsuarioModalPage(
          usuario: usuario,
          onUsuarioSaved: _handleUsuarioSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
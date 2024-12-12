// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/screens/pages/categoria/categoria_modal_page.dart';
import 'package:myapp/services/categoria_service.dart';
import 'package:myapp/models/categoria_model.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  _CategoriasPageState createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  late List<Categoria> _categoriaList = [];
  late List<Categoria> _filteredCategoriaList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterCategorias);
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    try {
      List<Categoria> activeCategorias = await ApiServiceCategoria.listarCategoriasPorEstado("A");
      List<Categoria> inactiveCategorias = await ApiServiceCategoria.listarCategoriasPorEstado("I");
      _categoriaList = [...activeCategorias, ...inactiveCategorias];
      _filteredCategoriaList = _categoriaList;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las categorias: $e')),
      );
    }
  }

  void _filterCategorias() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategoriaList = _categoriaList.where((categoria) {
        return categoria.nombre.toLowerCase().contains(query);
      }).toList();
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
              const SizedBox(height: 16.0),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar Categoria',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      _navigateToCategoriaDetail(Categoria.empty());
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
                  _buildCategoriaList(true),
                  _buildCategoriaList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaList(bool showActive) {
    List<Categoria> filteredCategorias = _filteredCategoriaList
        .where((categoria) => categoria.estado == (showActive ? 'A' : 'I'))
        .toList();

    if (filteredCategorias.isEmpty) {
      return Center(
        child: Text(showActive
            ? 'No hay categorias activos'
            : 'No hay categorias inactivos'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredCategorias.length,
      itemBuilder: (context, index) {
        Categoria categoria = filteredCategorias[index];
        bool isActive = categoria.estado == 'A';
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
              categoria.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                categoria.nombre.substring(0, 1),
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
                      _showConfirmationDialog(context, categoria);
                    },
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.restore,
                      color: Color.fromARGB(255, 0, 104, 248),
                      size: 20,
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, categoria);
                    },
                  ),
            onTap: () {
              if (isActive) {
                _navigateToCategoriaDetail(categoria);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se puede abrir el formulario para categorias inactivos.',
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

  void _showConfirmationDialog(BuildContext context, Categoria categoria) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(categoria.estado == 'A'
              ? "Eliminar Categoria"
              : "Restaurar Categoria"),
          content: Text(categoria.estado == 'A'
              ? "¿Estás seguro de eliminar esta categoria?"
              : "¿Estás seguro de restaurar esta categoria?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (categoria.estado == 'A') {
                  _deleteCategoria(context, categoria.idCategoria);
                } else {
                  _restoreCategoria(context, categoria.idCategoria);
                }
              },
              child: Text(
                  categoria.estado == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategoria(BuildContext context, int categoriaId) async {
    try {
      await ApiServiceCategoria.eliminarCategoria(categoriaId);
      _loadCategorias();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria eliminado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el Categoria: $e')),
      );
    }
  }

  void _restoreCategoria(BuildContext context, int categoriaId) async {
    try {
      await ApiServiceCategoria.restaurarCategoria(categoriaId);
      _loadCategorias();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria restaurado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar el Categoria: $e')),
      );
    }
  }

  void _handleCategoriaSaved(Categoria categoria, bool isNewCategoria) {
    _loadCategorias();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewCategoria
              ? 'Categoria insertado exitosamente'
              : 'Categoria editado exitosamente',
        ),
      ),
    );
  }

  void _navigateToCategoriaDetail(Categoria categoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriaModalPage(
          categoria: categoria,
          onCategoriaSaved: _handleCategoriaSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCategorias);
    _searchController.dispose();
    super.dispose();
  }
}
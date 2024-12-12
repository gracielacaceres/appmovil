// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/models/categoria_model.dart';
import 'package:myapp/services/categoria_service.dart';

class CategoriaSelectionScreen extends StatefulWidget {
  const CategoriaSelectionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoriaSelectionScreenState createState() => _CategoriaSelectionScreenState();
}

class _CategoriaSelectionScreenState extends State<CategoriaSelectionScreen> {
  List<Categoria> _categorias = [];
  List<Categoria> _filteredCategorias = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    try {
      final categorias = await ApiServiceCategoria.listarCategoriasPorEstadoActivo();
      setState(() {
        _categorias = categorias;
        _filteredCategorias = categorias;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las categorías: $e'),
        ),
      );
    }
  }

  void _filterCategorias(String query) {
    setState(() {
      _filteredCategorias = _categorias
          .where((categoria) =>
              categoria.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Categoría'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar categoría',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterCategorias,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCategorias.length,
              itemBuilder: (context, index) {
                final categoria = _filteredCategorias[index];
                return ListTile(
                  title: Text(categoria.nombre),
                  onTap: () {
                    Navigator.pop(context, categoria);
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
    _searchController.dispose();
    super.dispose();
  }
}
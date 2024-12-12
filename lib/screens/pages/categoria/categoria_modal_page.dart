// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/models/categoria_model.dart';
import 'package:myapp/services/categoria_service.dart';

class CategoriaModalPage extends StatefulWidget {
  final Categoria categoria;
  final Function(Categoria, bool) onCategoriaSaved;

  const CategoriaModalPage({
    super.key,
    required this.categoria,
    required this.onCategoriaSaved,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoriaModalPageState createState() => _CategoriaModalPageState();
}

class _CategoriaModalPageState extends State<CategoriaModalPage> {
  late TextEditingController _nombreController;
  late TextEditingController _estadoController;
  bool _isNewCategoria = false;

  bool _nombreExists = false; // Variable para verificar si el nombre ya existe
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.categoria.nombre);
    _estadoController = TextEditingController(text: widget.categoria.estado);

    _isNewCategoria = widget.categoria.idCategoria == 0;

    // Verificar si el nombre inicial ya existe al inicio
    _checkNombreExists(_nombreController
        .text); // Llama al método _checkNombreExists con el nombre inicial
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoria = Categoria(
      idCategoria: widget.categoria.idCategoria,
      nombre: _nombreController.text,
      estado: _estadoController.text,
    );

    try {
      if (_isNewCategoria) {
        await ApiServiceCategoria.agregarCategoria(categoria);
      } else {
        await ApiServiceCategoria.editarCategoria(categoria.idCategoria, categoria);
      }

      widget.onCategoriaSaved(categoria, _isNewCategoria);

      Navigator.of(context).pop(); // Cierra la pantalla de modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la categoría: $e'),
        ),
      );
    }
  }

  String? _validateNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre';
    }

    // Verificar que cada palabra empiece con mayúscula y permitir espacios
    final RegExp nameRegExp = RegExp(r'^[A-ZÁÉÍÓÚÜÑ][a-zA-Záéíóúüñ\s]*$');

    if (!nameRegExp.hasMatch(value)) {
      return 'Cada palabra debe empezar con mayúscula';
    }

    if (_nombreExists) {
      return 'El nombre ya está registrado';
    }

    return null;
  }

  String? _validateEstado(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el estado';
    }
    return null;
  }

  void _checkNombreExists(String value) async {
    if (value.isNotEmpty) {
      bool nombreExists =
          await ApiServiceCategoria.checkExistingCategoria(value);
      setState(() {
        _nombreExists = nombreExists;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isNewCategoria ? 'Nueva Categoría' : widget.categoria.nombre,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.category),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) async {
                    // Limpiar la bandera de documento existente al cambiar el valor
                    setState(() {
                      _nombreExists = false;
                    });
                    // Verificar si el documento existe al cambiar el valor
                    if (value.isNotEmpty) {
                      bool nombreExists =
                          await ApiServiceCategoria.checkExistingCategoria(
                              value);
                      setState(() {
                        _nombreExists = nombreExists;
                      });
                    }
                  },
                  validator:
                      _validateNombre, // Valida el nombre según _nombreExists
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _estadoController,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: null, // Permite escribir varias líneas
                  keyboardType: TextInputType.multiline,
                  validator: _validateEstado,
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isNewCategoria
                            ? 'Guardar Categoría'
                            : 'Guardar Cambios',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

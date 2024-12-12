// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/producto_model.dart';
import 'package:myapp/models/categoria_model.dart' as categoria_model;
import 'package:myapp/screens/pages/producto/categoria_selection_screen.dart';
import 'package:myapp/services/categoria_service.dart';
import 'package:myapp/services/producto_service.dart';

class ProductoModalPage extends StatefulWidget {
  final Producto producto;
  final Function(Producto, bool) onProductoSaved;

  const ProductoModalPage({
    super.key,
    required this.producto,
    required this.onProductoSaved,
  });

  @override
  _ProductoModalPageState createState() => _ProductoModalPageState();
}

class _ProductoModalPageState extends State<ProductoModalPage> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _fechaExpiracionController;
  late DateTime _selectedDate;
  late categoria_model.Categoria _selectedCategoria = categoria_model.Categoria(idCategoria: 0, nombre: '', estado:("A"));
  bool _nombreExists = false;
  bool _isNewProducto = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _unidadMedidaOptions = ['litros', 'gramos', 'unidades'];
  late String _selectedUnidadMedida;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _descripcionController = TextEditingController(text: widget.producto.descripcion);
    _precioController = TextEditingController(text: widget.producto.precio > 0 ? widget.producto.precio.toString() : '');
    _stockController = TextEditingController(text: widget.producto.stock > 0 ? widget.producto.stock.toString() : '');
    _selectedDate = widget.producto.fechaExpiracion ?? DateTime.now();
    _fechaExpiracionController = TextEditingController(
      text: widget.producto.fechaExpiracion != null ? _formatDate(widget.producto.fechaExpiracion!) : '',
    );
    _isNewProducto = widget.producto.idProducto == 0;
    _selectedUnidadMedida = widget.producto.unidadMedida.isNotEmpty ? widget.producto.unidadMedida : _unidadMedidaOptions.first;

    if (_isNewProducto) {
      _loadCategorias();
    } else {
      _loadCategoriasAndSelectCategoria();
    }
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaExpiracionController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _loadCategoriasAndSelectCategoria() async {
    try {
      final categorias = await ApiServiceCategoria.listarCategoriasPorEstadoActivo();
      final selectedCategoria = categorias.firstWhere(
        (categoria) => categoria.idCategoria == widget.producto.categoria.idCategoria,
        orElse: () => categoria_model.Categoria(idCategoria: 0, nombre: '', estado:("A")),
      );
      setState(() {
        _selectedCategoria = selectedCategoria;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las categorías: $e'),
        ),
      );
    }
  }

  Future<void> _loadCategorias() async {
    try {
      final categorias = await ApiServiceCategoria.listarCategoriasPorEstadoActivo();
      setState(() {
        if (categorias.isNotEmpty) {
          _selectedCategoria = categorias.first;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las categorías: $e'),
        ),
      );
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    DateTime? selectedDate = _selectedDate;
    if (_fechaExpiracionController.text.isEmpty) {
      selectedDate = null;
    }

    try {
      final producto = Producto(
        idProducto: widget.producto.idProducto,
        imagen: widget.producto.imagen,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        precio: double.tryParse(_precioController.text) ?? 0.0,
        stock: double.tryParse(_stockController.text) ?? 0.0,
        unidadMedida: _selectedUnidadMedida,
        fechaIngreso: widget.producto.fechaIngreso,
        fechaExpiracion: selectedDate,
        estado: widget.producto.estado,
        categoria: Categoria(
          idCategoria: _selectedCategoria.idCategoria,
          nombre: _selectedCategoria.nombre,
        ),
      );

      if (_isNewProducto) {
        await ApiServiceProducto.agregarProducto(producto);
      } else {
        await ApiServiceProducto.editarProducto(producto.idProducto, producto);
      }
      widget.onProductoSaved(producto, _isNewProducto);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el producto: $e'),
        ),
      );
    }
  }

  String? _validateNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre del producto';
    }
    final RegExp nameRegExp = RegExp(r'^[A-ZÁÉÍÓÚÜÑ][a-zA-Záéíóúüñ\s]*$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Cada palabra debe empezar con mayúscula';
    }
    if (_nombreExists) {
      return 'El nombre ya está registrado';
    }
    return null;
  }

  String? _validateDescripcion(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la descripción del producto';
    }
    return null;
  }

  String? _validatePrecio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el precio';
    }
    final RegExp numericRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!numericRegex.hasMatch(value)) {
      return 'Ingresa un precio válido';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Ingresa un precio válido';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el stock';
    }
    final stock = double.tryParse(value);
    if (stock == null || stock <= 0) {
      return 'Ingresa un stock válido (mayor que cero)';
    }
    return null;
  }

  String? _validateFechaExpiracion(String? value) {
    if (value != null && value.isNotEmpty) {
      final DateTime? fechaExpiracion = DateFormat('dd-MMM-yyyy').parse(value);
      if (fechaExpiracion == null) {
        return 'Fecha de expiración inválida';
      }
      final DateTime today = DateTime.now();
      if (!fechaExpiracion.isAfter(today)) {
        return 'La fecha de expiración debe ser mayor a la fecha actual';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _fechaExpiracionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isNewProducto ? 'Nuevo Producto' : widget.producto.nombre,
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
                    prefixIcon: Icon(Icons.label),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    setState(() {
                      _nombreExists = false;
                    });
                    if (value.isNotEmpty) {
                      _checkNombreExists(value);
                    }
                  },
                  validator: _validateNombre,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _validateDescripcion,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    _navigateToCategoriaListScreen();
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                      suffixIcon: Icon(Icons.navigate_next),
                    ),
                    child: Text(
                      _selectedCategoria.nombre.isNotEmpty ? _selectedCategoria.nombre : '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precioController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: 'S/. ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validatePrecio,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateStock,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedUnidadMedida,
                  decoration: const InputDecoration(
                    labelText: 'Unidad de Medida',
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  items: _unidadMedidaOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUnidadMedida = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fechaExpiracionController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Expiración',
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  validator: _validateFechaExpiracion,
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
                        _isNewProducto ? 'Guardar Producto' : 'Guardar Cambios',
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

  void _checkNombreExists(String value) async {
    try {
      bool nombreExists = await ApiServiceProducto.checkExistingProducto(value);
      setState(() {
        _nombreExists = nombreExists;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar la existencia del nombre: $e'),
        ),
      );
    }
  }

  void _navigateToCategoriaListScreen() async {
    final selectedCategoria = await Navigator.push<categoria_model.Categoria?>(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoriaSelectionScreen(),
      ),
    );

    if (selectedCategoria != null) {
      setState(() {
        _selectedCategoria = selectedCategoria;
      });
    }
  }
}
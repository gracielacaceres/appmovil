import 'package:flutter/material.dart';
import 'package:myapp/models/producto_model.dart';
import 'package:myapp/services/producto_service.dart';

class ProductoSelectionScreen extends StatelessWidget {
  const ProductoSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Selecciona Productos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const ProductoList(),
    );
  }
}

class ProductoList extends StatefulWidget {
  const ProductoList({super.key});

  @override
  _ProductoListState createState() => _ProductoListState();
}

class _ProductoListState extends State<ProductoList> {
  late TextEditingController _searchController;
  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _cargarProductos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await ApiServiceProducto.listarProductos();
      setState(() {
        _productos = productos;
        _productosFiltrados = productos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los productos: $e'),
        ),
      );
    }
  }

  void _filtrarProductos(String consulta) {
    setState(() {
      _productosFiltrados = _productos
          .where((producto) =>
              producto.nombre.toLowerCase().contains(consulta.toLowerCase()))
          .toList();
    });
  }

  void _mostrarDetallesProducto(Producto producto) {
    Navigator.pop(context, producto);
  }

  Widget _construirItemProducto(Producto producto) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      shadowColor: Colors.blue.withOpacity(0.2),
      child: InkWell(
        onTap: () => _mostrarDetallesProducto(producto),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Precio de Venta: S/.${producto.precio.toStringAsFixed(2)}\nUnidad de Venta: ${producto.unidadMedida}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar producto',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _filtrarProductos,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _productosFiltrados.length,
            itemBuilder: (context, index) {
              final producto = _productosFiltrados[index];
              return _construirItemProducto(producto);
            },
          ),
        ),
      ],
    );
  }
}
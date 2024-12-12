// producto_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/models/producto_model.dart';
import 'package:myapp/services/producto_service.dart';
import 'package:myapp/screens/pages/producto/producto_modal_page.dart';

class ProductoPage extends StatefulWidget {
  const ProductoPage({super.key});

  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  late List<Producto> _productList = [];
  late List<Producto> _filteredProductList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterProducts);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      List<Producto> activeProducts = await ApiServiceProducto.listarProductosActivos();
      List<Producto> inactiveProducts = await ApiServiceProducto.listarProductosInactivos();
      _productList = [...activeProducts, ...inactiveProducts];
      _filteredProductList = _productList;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los productos: $e')),
      );
    }
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProductList = _productList.where((product) {
        String priceString = product.precio.toString();
        String stockString = product.stock.toString();
        return product.nombre.toLowerCase().contains(query) ||
            priceString.contains(query) ||
            product.unidadMedida.toLowerCase().contains(query) ||
            stockString.contains(query) ||
            product.categoria.nombre.toLowerCase().contains(query);
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
                  hintText: 'Buscar productos',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      _navigateToProductDetail(Producto(
                        idProducto: 0,
                        imagen: '',
                        nombre: '',
                        descripcion: '',
                        precio: 0.0,
                        stock: 0.0,
                        unidadMedida: '',
                        fechaIngreso: DateTime.now(),
                        categoria: Categoria(idCategoria: 0, nombre: ''),
                      ));
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
                  _buildProductList(true),
                  _buildProductList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(bool showActive) {
    List<Producto> filteredProducts = _filteredProductList
        .where((product) => product.estado == (showActive ? 1 : 0))
        .toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(showActive
            ? 'No hay productos activos'
            : 'No hay productos inactivos'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        Producto product = filteredProducts[index];
        bool isActive = product.estado == 1;
        return _buildProductListItem(product, isActive);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    );
  }

  Widget _buildProductListItem(Producto product, bool isActive) {
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
          product.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Precio de Venta: ${product.precio}\nUnidad de Venta: ${product.unidadMedida}',
          style: const TextStyle(
            color: Color.fromARGB(255, 79, 79, 79),
            fontSize: 12,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            product.nombre.substring(0, 1),
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
                  _showConfirmationDialog(context, product);
                },
              )
            : IconButton(
                icon: const Icon(
                  Icons.restore,
                  color: Color.fromARGB(255, 0, 104, 248),
                  size: 20,
                ),
                onPressed: () {
                  _showConfirmationDialog(context, product);
                },
              ),
        onTap: () {
          if (isActive) {
            _navigateToProductDetail(product);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No se puede abrir el formulario para productos inactivos.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, Producto product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              product.estado == 1 ? "Eliminar Producto" : "Restaurar Producto"),
          content: Text(product.estado == 1
              ? "¿Estás seguro de eliminar este producto?"
              : "¿Estás seguro de restaurar este producto?"),
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
                if (product.estado == 1) {
                  _deleteProduct(context, product.idProducto);
                } else {
                  _restoreProduct(context, product.idProducto);
                }
              },
              child: Text(
                product.estado == 1 ? "Sí, Eliminar" : "Sí, Restaurar",
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(BuildContext context, int productId) async {
    try {
      await ApiServiceProducto.eliminarProducto(productId);
      _loadProducts();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el Producto: $e')),
      );
    }
  }

  void _restoreProduct(BuildContext context, int productId) async {
    try {
      await ApiServiceProducto.restaurarProducto(productId);
      _loadProducts();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto restaurado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar el Producto: $e')),
      );
    }
  }

  void _handleProductSaved(Producto product, bool isNewProduct) {
    _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewProduct
              ? 'Producto insertado exitosamente'
              : 'Producto editado exitosamente',
        ),
      ),
    );
  }

  void _navigateToProductDetail(Producto product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoModalPage(
          producto: product,
          onProductoSaved: _handleProductSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }
}
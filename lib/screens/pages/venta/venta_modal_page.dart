import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myapp/models/usuario_model.dart';
import 'package:myapp/models/detalle_venta_model.dart';
import 'package:myapp/models/venta_model.dart';
import 'package:myapp/models/producto_model.dart';
import 'package:myapp/screens/pages/venta/usuario_selection_screen.dart';
import 'package:myapp/screens/pages/venta/producto_selection_screen.dart';
import 'package:myapp/services/venta_service.dart';

class VentaModalPage extends StatefulWidget {
  final Venta venta;
  final Function(Venta, bool) onVentaSaved;

  const VentaModalPage({
    Key? key,
    required this.venta,
    required this.onVentaSaved,
  }) : super(key: key);

  @override
  _VentaModalPageState createState() => _VentaModalPageState();
}

class _VentaModalPageState extends State<VentaModalPage> {
  late TextEditingController _usuarioController;
  List<DetalleVenta> _detallesVenta = [];

  @override
  void initState() {
    super.initState();
    _usuarioController =
        TextEditingController(text: widget.venta.usuario.nombre);
    _detallesVenta.addAll(widget.venta.detalles);
  }

  void _guardarVenta() async {
    if (_usuarioController.text.isEmpty || _detallesVenta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
        ),
      );
      return;
    }

    try {
      final venta = Venta(
        idVenta: widget.venta.idVenta,
        usuario: widget.venta.usuario,
        fechaVenta: widget.venta.fechaVenta.isNotEmpty
            ? widget.venta.fechaVenta
            : DateTime.now().toIso8601String(),
        montoTotal: _calcularMontoTotal(),
        estado: widget.venta.estado,
        detalles: _detallesVenta,
      );

      if (widget.venta.idVenta == null) {
        await VentaService.createVenta(venta);
      } else {
        await VentaService.updateVenta(venta.idVenta!, venta);
      }

      widget.onVentaSaved(venta, widget.venta.idVenta == null);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la venta: $e')),
      );
    }
  }

  void _seleccionarUsuario() async {
    final usuarioSeleccionado = await Navigator.push<Usuario?>(
      context,
      MaterialPageRoute(
        builder: (context) => const UsuarioSelectionScreen(),
      ),
    );

    if (usuarioSeleccionado != null) {
      setState(() {
        widget.venta.usuario = usuarioSeleccionado;
        _usuarioController.text = usuarioSeleccionado.nombre ?? '';
      });
    }
  }

  void _agregarProducto() async {
    final productoSeleccionado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductoSelectionScreen()),
    );

    if (productoSeleccionado != null) {
      _mostrarDetallesProducto(productoSeleccionado);
    }
  }

  void _mostrarDetallesProducto(Producto producto) {
    double cantidad = 1;
    TextEditingController cantidadController = TextEditingController(
      text: cantidad.toStringAsFixed(producto.unidadMedida == 'Kilo' ? 2 : 0),
    );

    bool permitirDecimales = producto.unidadMedida == 'Kilo';

    DetalleVenta? detalleExistente;
    for (var detalle in _detallesVenta) {
      if (detalle.producto.idProducto == producto.idProducto) {
        detalleExistente = detalle;
        break;
      }
    }

    if (detalleExistente != null) {
      cantidad = detalleExistente.cantidad;
      cantidadController.text =
          cantidad.toStringAsFixed(permitirDecimales ? 2 : 0);
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Precio de Venta: S/.${producto.precio.toStringAsFixed(2)}\n Unidad de Venta: ${producto.unidadMedida}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Stock: ${producto.stock}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (cantidad > 0) {
                            if (permitirDecimales) {
                              cantidad -= 0.1;
                            } else {
                              cantidad--;
                            }
                            cantidad = _redondearDecimales(
                                cantidad, permitirDecimales ? 2 : 0);
                            cantidadController.text = cantidad
                                .toStringAsFixed(permitirDecimales ? 2 : 0);
                          }
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ingrese la cantidad'),
                            content: TextField(
                              controller: cantidadController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: permitirDecimales),
                              decoration: const InputDecoration(
                                hintText: 'Cantidad',
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    cantidad = double.parse(value);
                                    cantidad = _redondearDecimales(
                                        cantidad, permitirDecimales ? 2 : 0);
                                  });
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 30,
                        child: Text(
                          cantidad.toStringAsFixed(permitirDecimales ? 2 : 0),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (permitirDecimales) {
                            cantidad += 0.1;
                          } else {
                            cantidad++;
                          }
                          cantidad = _redondearDecimales(
                              cantidad, permitirDecimales ? 2 : 0);
                          cantidadController.text = cantidad
                              .toStringAsFixed(permitirDecimales ? 2 : 0);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Total: S/.${(producto.precio * cantidad).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (detalleExistente != null) {
                          setState(() {
                            detalleExistente!.cantidad = cantidad;
                          });
                        } else {
                          setState(() {
                            _detallesVenta.add(DetalleVenta(
                              producto: producto,
                              cantidad: cantidad,
                              precioUnitario: producto.precio,
                              subtotal: producto.precio * cantidad,
                            ));
                          });
                        }
                        Navigator.pop(context);
                        _actualizarFormulario();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        detalleExistente != null
                            ? 'Actualizar cantidad'
                            : 'Agregar a la venta',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _redondearDecimales(double numero, int decimales) {
    num fac = pow(10, decimales);
    return (numero * fac).round() / fac;
  }

  Widget _construirListaProductos() {
    return Expanded(
      child: ListView.builder(
        itemCount: _detallesVenta.length,
        itemBuilder: (context, index) {
          final detalleVenta = _detallesVenta[index];
          final producto = detalleVenta.producto;
          final precioTotal = detalleVenta.cantidad * producto.precio;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              onTap: () {
                _mostrarDetallesProducto(producto);
              },
              title: Text(producto.nombre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${detalleVenta.cantidad} x S/.${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: S/.${precioTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _detallesVenta.removeAt(index);
                    _actualizarFormulario();
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  double _calcularMontoTotal() {
    double montoTotal = 0;
    for (var detalleVenta in _detallesVenta) {
      montoTotal += detalleVenta.cantidad * detalleVenta.producto.precio;
    }
    return montoTotal;
  }

  void _actualizarFormulario() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 149, 243),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.venta.idVenta == null ? 'Nueva Venta' : 'Editar Venta',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _seleccionarUsuario,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _usuarioController.text.isNotEmpty
                      ? _usuarioController.text
                      : 'Selecciona un usuario',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _agregarProducto,
              child: const Text('Añadir Producto'),
            ),
            const SizedBox(height: 16),
            _construirListaProductos(),
            const SizedBox(height: 16),
            Text(
              'Monto a pagar: S/.${_calcularMontoTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardarVenta,
              child: Text(widget.venta.idVenta == null
                  ? 'Guardar Venta'
                  : 'Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}

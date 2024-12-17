// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:myapp/models/venta_model.dart';
import 'package:myapp/services/venta_service.dart';
import 'package:myapp/screens/pages/venta/venta_modal_page.dart';

class VentaPage extends StatefulWidget {
  const VentaPage({super.key});

  @override
  _VentaPageState createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  late List<Venta> _listaVentas = [];
  late List<Venta> _listaVentasFiltradas = [];
  late TextEditingController _controladorBusqueda;

  @override
  void initState() {
    super.initState();
    _controladorBusqueda = TextEditingController();
    _controladorBusqueda.addListener(_filtrarVentas);
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    try {
      List<Venta> ventasActivas = await VentaService.getActiveVentas();
      List<Venta> ventasInactivas = await VentaService.getInactiveVentas();
      _listaVentas = [...ventasActivas, ...ventasInactivas];
      _listaVentasFiltradas = _listaVentas;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las ventas: $e')),
      );
    }
  }

  void _filtrarVentas() {
    String consulta = _controladorBusqueda.text.toLowerCase();
    setState(() {
      _listaVentasFiltradas = _listaVentas.where((venta) {
        bool coincideNombreCliente = venta.usuario.nombre?.toLowerCase().contains(consulta) ?? false;
        bool coincideTotal = venta.montoTotal.toString().contains(consulta);
        bool coincideFechaHora = venta.fechaVenta.contains(consulta);
        return coincideNombreCliente || coincideTotal || coincideFechaHora;
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
                controller: _controladorBusqueda,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar Venta',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black, size: 28),
                    onPressed: () {
                      _navegarADetalleVenta(Venta.empty());
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
              Tab(child: Text('Activas', style: TextStyle(color: Colors.black))),
              Tab(child: Text('Inactivas', style: TextStyle(color: Colors.black))),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _construirListaVentas(true),
                  _construirListaVentas(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirListaVentas(bool mostrarActivas) {
    List<Venta> ventasFiltradas = _listaVentasFiltradas
        .where((venta) => venta.estado == (mostrarActivas ? 'A' : 'I'))
        .toList();

    if (ventasFiltradas.isEmpty) {
      return Center(
        child: Text(mostrarActivas ? 'No hay ventas activas' : 'No hay ventas inactivas'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: ventasFiltradas.length,
      itemBuilder: (context, index) {
        Venta venta = ventasFiltradas[index];
        bool esActiva = venta.estado == 'A';
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'N° de venta: ${venta.idVenta}\nCliente: ${venta.usuario.nombre}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${venta.fechaVenta}'),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: S/.${venta.montoTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    esActiva ? Icons.delete : Icons.restore,
                    color: esActiva ? Colors.red : Colors.blue,
                    size: 24,
                  ),
                  onPressed: () {
                    _mostrarDialogoConfirmacion(context, venta);
                  },
                ),
              ],
            ),
            onTap: () {
              if (esActiva) {
                _navegarADetalleVenta(venta);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se puede abrir el formulario para ventas inactivas.'),
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

  void _mostrarDialogoConfirmacion(BuildContext context, Venta venta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(venta.estado == 'A' ? "Eliminar Venta" : "Restaurar Venta"),
          content: Text(venta.estado == 'A'
              ? "¿Estás seguro de eliminar esta venta?"
              : "¿Estás seguro de restaurar esta venta?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (venta.estado == 'A') {
                  _eliminarVenta(context, venta.idVenta!);
                } else {
                  _restaurarVenta(context, venta.idVenta!);
                }
              },
              child: Text(venta.estado == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _eliminarVenta(BuildContext context, int idVenta) async {
    try {
      await VentaService.logicalDeleteVenta(idVenta);
      _cargarVentas();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta eliminada exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la venta: $e')),
      );
    }
  }

  void _restaurarVenta(BuildContext context, int idVenta) async {
    try {
      await VentaService.activateVenta(idVenta);
      _cargarVentas();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta restaurada exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar la venta: $e')),
      );
    }
  }

  void _manejarVentaGuardada(Venta venta, bool esNuevaVenta) {
    _cargarVentas();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          esNuevaVenta ? 'Venta insertada exitosamente' : 'Venta editada exitosamente',
        ),
      ),
    );
  }

  void _navegarADetalleVenta(Venta venta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VentaModalPage(
          venta: venta,
          onVentaSaved: _manejarVentaGuardada, onVentaGuardada: (Venta venta, bool esVentaNueva) {  },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controladorBusqueda.removeListener(_filtrarVentas);
    _controladorBusqueda.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/screens/pages/producto/producto_page.dart';
import 'package:myapp/screens/pages/categoria/categoria_page.dart';
import 'package:myapp/screens/pages/venta/venta_page.dart';
import 'package:myapp/screens/pages/usuario/usuario_page.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/sidebar/my_drawer_header.dart';

class HomePage extends StatefulWidget {
  final String userRole;

  const HomePage({Key? key, required this.userRole}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var currentPage = DrawerSections.dashboard;

  @override
  Widget build(BuildContext context) {
    Widget container;
    var appBarTitle = DrawerSections.dashboard.title;

    switch (currentPage) {
      case DrawerSections.dashboard:
        container = const Center(child: Text('Dashboard'));
        break;
      case DrawerSections.productos:
        container = const ProductoPage();
        appBarTitle = DrawerSections.productos.title;
        break;
      case DrawerSections.categorias:
        container = const CategoriasPage(); // Asegúrate de que el nombre de la clase sea correcto
        appBarTitle = DrawerSections.categorias.title;
        break;
      case DrawerSections.ventas:
        container = const VentaPage();
        appBarTitle = DrawerSections.ventas.title;
        break;
      case DrawerSections.usuarios:
        container = const UsuariosPage();
        appBarTitle = DrawerSections.usuarios.title;
        break;
      case DrawerSections.logout:
        container = const LoginScreen();
        appBarTitle = DrawerSections.logout.title;
        break;
    }

    return container;
  }

  Widget MyDrawerList(String userRole) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          menuItem(DrawerSections.dashboard),
          menuItem(DrawerSections.productos),
          menuItem(DrawerSections.categorias),
          menuItem(DrawerSections.ventas),
          if (userRole == 'admin') menuItem(DrawerSections.usuarios),
          const Divider(),
          menuItem(DrawerSections.logout),
        ],
      ),
    );
  }

  Widget menuItem(DrawerSections section) {
    return Material(
      color: currentPage == section ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (section == DrawerSections.logout) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pop(context);
            setState(() {
              currentPage = section;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  _getIconForSection(section),
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForSection(DrawerSections section) {
    switch (section) {
      case DrawerSections.dashboard:
        return Icons.dashboard_outlined;
      case DrawerSections.productos:
        return Icons.sell;
      case DrawerSections.categorias:
        return Icons.category;
      case DrawerSections.ventas:
        return Icons.point_of_sale;
      case DrawerSections.usuarios:
        return Icons.person;
      case DrawerSections.logout:
        return Icons.logout;
    }
  }
}

enum DrawerSections {
  dashboard,
  productos,
  categorias,
  ventas,
  usuarios,
  logout,
}

extension DrawerSectionExtension on DrawerSections {
  String get title {
    switch (this) {
      case DrawerSections.dashboard:
        return "Dashboard";
      case DrawerSections.productos:
        return "Productos";
      case DrawerSections.categorias:
        return "Categorías";
      case DrawerSections.ventas:
        return "Ventas";
      case DrawerSections.usuarios:
        return "Usuarios";
      case DrawerSections.logout:
        return "Cerrar Sesión";
    }
  }
}
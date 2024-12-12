class Producto {
  int idProducto;
  String imagen;
  String nombre;
  String descripcion;
  double precio;
  double stock;
  String unidadMedida;
  DateTime fechaIngreso;
  DateTime? fechaExpiracion;
  int estado;
  Categoria categoria;

  Producto({
    required this.idProducto,
    required this.imagen,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.unidadMedida,
    required this.fechaIngreso,
    this.fechaExpiracion,
    this.estado = 1, // Valor por defecto
    required this.categoria,
  });

  // Convertir un JSON en un objeto Producto
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['idProducto'] ?? 0,
      imagen: json['imagen'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      unidadMedida: json['unidadMedida'] ?? '',
      fechaIngreso: DateTime.parse(json['fechaIngreso']),
      fechaExpiracion: json['fechaExpiracion'] != null
          ? DateTime.parse(json['fechaExpiracion'])
          : null,
      estado: json['estado'] ?? 1,
      categoria: Categoria.fromJson(json['categoria']),
    );
  }

  // Convertir un objeto Producto a JSON
  Map<String, dynamic> toJson() {
    return {
      'idProducto': idProducto,
      'imagen': imagen,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'unidadMedida': unidadMedida,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'fechaExpiracion': fechaExpiracion?.toIso8601String(),
      'estado': estado,
      'categoria': categoria.toJson(),
    };
  }
}

class Categoria {
  int idCategoria;
  String nombre;

  Categoria({
    required this.idCategoria,
    required this.nombre,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: json['idCategoria'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategoria': idCategoria,
      'nombre': nombre,
    };
  }
}

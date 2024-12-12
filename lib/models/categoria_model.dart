  class Categoria {
    final int idCategoria;
    final String nombre;
    final String estado;

    Categoria({
      required this.idCategoria,
      required this.nombre,
      required this.estado,
    });

    factory Categoria.fromJson(Map<String, dynamic> json) {
      return Categoria(
        idCategoria: json['idCategoria'] ?? 0,
        nombre: json['nombre'] ?? '',
        estado: json['estado'] ?? '',
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'idCategoria': idCategoria,
        'nombre': nombre,
        'estado': estado,
      };
    }

    static Categoria empty() {
      return Categoria(
        idCategoria: 0,
        nombre: '',
        estado: '',
      );
    }
  }
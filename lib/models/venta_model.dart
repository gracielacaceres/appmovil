import 'package:myapp/models/usuario_model.dart';
import 'package:myapp/models/detalle_venta_model.dart';

class Venta {
  int? idVenta;
  Usuario usuario;
  String fechaVenta;
  double montoTotal;
  String estado;
  List<DetalleVenta> detalles;

  Venta({
    this.idVenta,
    required this.usuario,
    required this.fechaVenta,
    required this.montoTotal,
    this.estado = 'A',
    required this.detalles,
  });

  factory Venta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Failed to parse JSON');
    }

    return Venta(
      idVenta: json['idVenta'],
      usuario: Usuario.fromJson(json['usuario'] ?? {}),
      fechaVenta: json['fechaVenta'] ?? '',
      montoTotal: json['montoTotal']?.toDouble() ?? 0.0,
      estado: json['estado'] ?? 'A',
      detalles: (json['detalles'] as List<dynamic>?)
              ?.map((e) => DetalleVenta.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idVenta': idVenta,
      'usuario': usuario.toJson(),
      'fechaVenta': fechaVenta,
      'montoTotal': montoTotal,
      'estado': estado,
      'detalles': detalles.map((i) => i.toJson()).toList(),
    };
  }

  static Venta empty() {
    return Venta(
      idVenta: null,
      usuario: Usuario.empty(),
      fechaVenta: DateTime.now().toIso8601String(),
      montoTotal: 0.0,
      estado: 'A',
      detalles: [],
    );
  }
}
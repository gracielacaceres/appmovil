import 'package:myapp/models/producto_model.dart';

class DetalleVenta {
  int? idDetalleVenta;
  Producto producto;
  double cantidad;
  double precioUnitario;
  double subtotal;

  DetalleVenta({
    this.idDetalleVenta,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      idDetalleVenta: json['idDetalleVenta'],
      producto: Producto.fromJson(json['producto']),
      cantidad: json['cantidad']?.toDouble() ?? 0.0,
      precioUnitario: json['precioUnitario']?.toDouble() ?? 0.0,
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDetalleVenta': idDetalleVenta,
      'producto': producto.toJson(),
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
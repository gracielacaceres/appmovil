class Cita {
  final int id;
  final String fecha;
  final String hora;
  final String nota; // Este es el servicio ahora
  final String estado;
  final int idCliente;
  final int idBarbero;

  Cita({
    required this.id,
    required this.fecha,
    required this.hora,
    this.nota = '', // Nota como opcional
    required this.estado,
    required this.idCliente,
    required this.idBarbero,
  });

  // Método para convertir JSON a un objeto Cita
  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['idCita'],
      fecha: json['fecha'],
      hora: json['hora'],
      nota: json['nota'] ?? '',
      estado: json['estado'],
      idCliente: json['cliente']['idUsuario'],
      idBarbero: json['barbero']['idUsuario'],
    );
  }

  // Método para convertir objeto Cita a JSON
  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'hora': hora,
      'nota': nota, // Incluir nota en el JSON
      'estado': estado,
      'idCliente': idCliente,
      'idBarbero': idBarbero,
    };
  }
}

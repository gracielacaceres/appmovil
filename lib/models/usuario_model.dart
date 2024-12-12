class Usuario {
  int? idUsuario;
  String? tipoDeDocumento;
  String? numeroDeDocumento;
  String? nombre;
  String? apellido;
  String? celular;
  String? email;
  String? password;
  String? rol;
  int? activo;

  Usuario({
    this.idUsuario,
    this.tipoDeDocumento,
    this.numeroDeDocumento,
    this.nombre,
    this.apellido,
    this.celular,
    this.email,
    this.password,
    this.rol,
    this.activo = 1,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      tipoDeDocumento: json['tipoDeDocumento'],
      numeroDeDocumento: json['numeroDeDocumento'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      celular: json['celular'],
      email: json['email'],
      password: json['password'],
      rol: json['rol'],
      activo: json['activo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'tipoDeDocumento': tipoDeDocumento,
      'numeroDeDocumento': numeroDeDocumento,
      'nombre': nombre,
      'apellido': apellido,
      'celular': celular,
      'email': email,
      'password': password,
      'rol': rol,
      'activo': activo,
    };
  }

  static Usuario empty() {
    return Usuario(
      idUsuario: null,
      tipoDeDocumento: '',
      numeroDeDocumento: '',
      nombre: '',
      apellido: '',
      celular: '',
      email: '',
      password: '',
      rol: '',
      activo: 1,
    );
  }
}
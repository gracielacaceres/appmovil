import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/usuario_model.dart';
import 'package:myapp/services/usuario_service.dart';

class UsuarioModalPage extends StatefulWidget {
  final Usuario usuario;
  final Function(Usuario, bool) onUsuarioSaved;

  const UsuarioModalPage({
    super.key,
    required this.usuario,
    required this.onUsuarioSaved,
  });

  @override
  _UsuarioModalPageState createState() => _UsuarioModalPageState();
}

class _UsuarioModalPageState extends State<UsuarioModalPage> {
  late TextEditingController _numeroDeDocumentoController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _celularController;
  late TextEditingController _passwordController;
  String _selectedTipoDeDocumento = 'DNI';
  bool _isNewUsuario = false;
  bool _documentExists = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _numeroDeDocumentoController = TextEditingController(text: widget.usuario.numeroDeDocumento);
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _apellidoController = TextEditingController(text: widget.usuario.apellido);
    _emailController = TextEditingController(text: widget.usuario.email);
    _celularController = TextEditingController(text: widget.usuario.celular);
    _passwordController = TextEditingController(text: widget.usuario.password);

    _isNewUsuario = widget.usuario.idUsuario == null;
    if (!_isNewUsuario) {
      _selectedTipoDeDocumento = widget.usuario.tipoDeDocumento ?? 'DNI';
    }
  }

  void _saveChanges() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final usuario = Usuario(
    idUsuario: widget.usuario.idUsuario,
    tipoDeDocumento: _selectedTipoDeDocumento,
    numeroDeDocumento: _numeroDeDocumentoController.text,
    nombre: _nombreController.text,
    apellido: _apellidoController.text,
    email: _emailController.text,
    celular: _celularController.text,
    password: _passwordController.text,
    rol: widget.usuario.rol,
    activo: widget.usuario.activo,
  );

  try {
    if (_isNewUsuario) {
      await ApiServiceUsuario.agregarUsuario(usuario);
    } else {
      if (usuario.idUsuario != null) {
        await ApiServiceUsuario.editarUsuario(usuario.idUsuario!, usuario);
      } else {
        throw Exception('User ID is null');
      }
    }

    widget.onUsuarioSaved(usuario, _isNewUsuario);

    Navigator.of(context).pop();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al guardar el usuario: $e'),
      ),
    );
  }
}

  String? _validateNumeroDeDocumento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el número de documento';
    }
    if (_selectedTipoDeDocumento == 'DNI' && value.length != 8) {
      return 'El DNI debe tener exactamente 8 dígitos';
    } else if (_selectedTipoDeDocumento == 'CNE' && value.length != 20) {
      return 'El CNE debe tener exactamente 20 dígitos';
    }

    if (_documentExists) {
      return 'El número de documento ya está registrado';
    }

    return null;
  }

  String? _validateNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre';
    }
    final RegExp nameRegExp = RegExp(r'^[a-zA-Záéíóúüñ\s]+$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Ingresa solo letras en el nombre';
    }
    return null;
  }

  String? _validateApellido(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el apellido';
    }
    final RegExp lastNameRegExp = RegExp(r'^[a-zA-Záéíóúüñ\s]+$');
    if (!lastNameRegExp.hasMatch(value)) {
      return 'Ingresa solo letras en el apellido';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(value)) {
        return 'Ingresa un correo electrónico válido';
      }
    }
    return null;
  }

  String? _validateCelular(String? value) {
    if (value != null && value.isNotEmpty) {
      final RegExp digitsOnlyRegExp = RegExp(r'^\d+$');
      if (!digitsOnlyRegExp.hasMatch(value)) {
        return 'El número de teléfono debe contener solo números';
      }
      if (!value.startsWith('9')) {
        return 'El número de teléfono debe comenzar con 9';
      }
      if (value.length != 9) {
        return 'El número de teléfono debe tener 9 dígitos';
      }
    }
    return null;
  }

  List<TextInputFormatter> _getInputFormatters() {
    return [FilteringTextInputFormatter.digitsOnly];
  }

  @override
  void dispose() {
    _numeroDeDocumentoController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isNewUsuario ? 'Nuevo Usuario' : '${widget.usuario.nombre} ${widget.usuario.apellido}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTipoDeDocumento,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTipoDeDocumento = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Documento',
                    prefixIcon: Icon(Icons.account_box),
                  ),
                  items: <String>['DNI', 'CNE'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numeroDeDocumentoController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Documento',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  inputFormatters: _getInputFormatters(),
                  onChanged: (value) async {
                    setState(() {
                      _documentExists = false;
                    });
                    if (value.isNotEmpty) {
                      bool documentExists = await ApiServiceUsuario.checkExistingUsuario(value);
                      setState(() {
                        _documentExists = documentExists;
                      });
                    }
                  },
                  validator: _validateNumeroDeDocumento,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: _validateNombre,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: _validateApellido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _celularController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: _validateCelular,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isNewUsuario ? 'Guardar Usuario' : 'Guardar Cambios',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
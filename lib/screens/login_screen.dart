import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/usuario_service.dart';
import 'package:myapp/screens/pages/dashboard.dart'; // Adjust this path according to your project structure

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isVisible = false;
  bool isLoading = false;
  String errorMessage = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      String email = emailController.text;
      String password = passwordController.text;

      try {
        final usuario = await ApiServiceUsuario.login(email, password);
        if (usuario != null && usuario.rol == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          setState(() {
            errorMessage = 'Usuario o Contraseña es invalido';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "lib/assets/login.png", // Adjust this path according to your project structure
                    width: 210,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Correo electrónico es requerido";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Correo electrónico",
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Contraseña es requerida";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: "Contraseña",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: Icon(isVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue,
                    ),
                    child: TextButton(
                      onPressed: _login,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "LOGIN",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _sexoController = TextEditingController();
  final _correoController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;

  void _register() async {
  final username = _usernameController.text.trim();
  final password = _passwordController.text;
  final sexo = _sexoController.text;
  final correo = _correoController.text;

  final result = await AuthService.register(username, password, sexo, correo);

  if (result["success"] == true) {
    setState(() {
      _successMessage = "¡Registro exitoso! Ahora inicia sesión.";
      _errorMessage = null;
    });
  } else {
    setState(() {
      _errorMessage = result["error"] ?? "Error desconocido";
      _successMessage = null;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrarse")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Nombre de usuario"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: "Correo electrónico"),
              keyboardType: TextInputType.emailAddress,
            ),
            DropdownButtonFormField<String>(
              value: _sexoController.text.isNotEmpty ? _sexoController.text : null,
              decoration: const InputDecoration(labelText: "Sexo"),
              items: const [
                DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                DropdownMenuItem(value: "Prefiero no decirlo", child: Text("Prefiero no decirlo")),
              ],
              onChanged: (value) {
                setState(() {
                  _sexoController.text = value ?? "";
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text("Registrarse"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("¿Ya tienes cuenta? Inicia sesión"),
            ),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            if (_successMessage != null)
              Text(_successMessage!, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

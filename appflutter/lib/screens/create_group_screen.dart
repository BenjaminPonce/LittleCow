import 'package:flutter/material.dart';
import '../services/group_service.dart';
import 'home_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nombreController = TextEditingController();
  String? _mensaje;
  final TextEditingController _ingresoController = TextEditingController();

  void _crearGrupo() async {
    final nombre = _nombreController.text.trim();
    final ingreso = double.tryParse(_ingresoController.text.trim());

    if (nombre.isEmpty || ingreso == null || ingreso < 0) {
      setState(() => _mensaje = "Datos inválidos");
      return;
    }

    final grupoId = await GroupService.crearGrupo(nombre, ingreso);
    if (grupoId != null) {
      setState(() {
        _mensaje = null; // Limpia mensaje si todo va bien
      });

      //  Ir a la pantalla principal automáticamente
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );

    } else {
      setState(() {
        _mensaje = "Error al crear grupo";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Grupo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre del grupo"),
            ),
            TextField(
              controller: _ingresoController,
              decoration: const InputDecoration(labelText: "Tu ingreso personal"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _crearGrupo,
              child: const Text("Crear"),
            ),
            if (_mensaje != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _mensaje!,
                  style: TextStyle(
                    color: _mensaje == "Grupo creado con éxito" ? Colors.green : Colors.red,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

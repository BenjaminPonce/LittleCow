import 'package:flutter/material.dart';
import '../../controllers/crear_grupo_controller.dart';

class AgregarIntegranteDialog extends StatefulWidget {
  final CrearGrupoController controller;

  const AgregarIntegranteDialog({
    super.key,
    required this.controller,
  });

  @override
  State<AgregarIntegranteDialog> createState() => _AgregarIntegranteDialogState();
}

class _AgregarIntegranteDialogState extends State<AgregarIntegranteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person_add, color: Colors.green),
          SizedBox(width: 8),
          Text('Agregar Integrante'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingrese el nombre de usuario del integrante a agregar:',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 16),
            
            // Solo pedir el username
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
                hintText: 'ej: juan_perez',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el nombre de usuario';
                }
                if (value.trim().length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            Text(
              'Nota: El porcentaje e ingreso personal se configurarán después.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _agregarIntegrante,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Agregar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _agregarIntegrante() async {
    if (_formKey.currentState!.validate()) {
      await widget.controller.agregarIntegrante(
        username: _usernameController.text.trim(),
      );
      
      if (widget.controller.error == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Integrante agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
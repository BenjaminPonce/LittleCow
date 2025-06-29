import 'package:flutter/material.dart';
import '../../controllers/crear_grupo_controller.dart';

class ModificarMontoDialog extends StatefulWidget {
  final CrearGrupoController controller;

  const ModificarMontoDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _ModificarMontoDialogState createState() => _ModificarMontoDialogState();
}

class _ModificarMontoDialogState extends State<ModificarMontoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.controller.montoTotal > 0) {
      _montoController.text = widget.controller.montoTotal.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.orange),
          SizedBox(width: 8),
          Text('Modificar Monto'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingrese el monto total del gasto compartido',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              decoration: InputDecoration(
                labelText: 'Monto Total',
                prefixText: '\$',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el monto';
                }
                final monto = double.tryParse(value);
                if (monto == null || monto <= 0) {
                  return 'El monto debe ser mayor a 0';
                }
                return null;
              },
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
          onPressed: _modificarMonto,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: Text('Modificar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _modificarMonto() {
    if (_formKey.currentState!.validate()) {
      final monto = double.parse(_montoController.text);
      widget.controller.modificarMonto(monto);
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Monto actualizado: \$${monto.toStringAsFixed(2)}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }
}
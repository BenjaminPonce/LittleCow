import 'package:flutter/material.dart';
import '../services/gastos_service.dart';

class CrearGastoScreen extends StatefulWidget {
  final int grupoId;
  //const CrearGastoScreen({super.key, required this.grupoId});

  final List<Map<String, dynamic>> integrantes; // Agregado

  const CrearGastoScreen({
    super.key,
    required this.grupoId,
    required this.integrantes,
  });

  @override
  State<CrearGastoScreen> createState() => _CrearGastoScreenState();
}

class _CrearGastoScreenState extends State<CrearGastoScreen> {
  final _montoController = TextEditingController();
  String _metodo = 'EQUITATIVO';
  String? _mensaje;

  Map<String, double> _porcentajes = {};

  @override
  void initState() {
    super.initState();
    // Inicializar porcentajes en 0
    for (var i in widget.integrantes) {
      _porcentajes[i['username']] = 0;
    }
  }

  void _crearGasto() async {
    final monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      setState(() => _mensaje = "Monto inválido");
      return;
    }

    if (_metodo == 'PERSONALIZADO') {
      final suma = _porcentajes.values.fold(0.0, (a, b) => a + b);
      if ((suma - 100).abs() > 0.01) {
        setState(() => _mensaje = "La suma de porcentajes debe ser 100");
        return;
      }
      // Validar que ningún porcentaje sea mayor al máximo permitido (si quieres)

      final exito = await GastosService.crearGastoPersonalizado(
        monto: monto,
        metodo: _metodo,
        grupoId: widget.grupoId,
        porcentajes: _metodo == 'PERSONALIZADO' ? _porcentajes : null,
      );

      if (exito) {
        Navigator.pop(context, true);
      } else {
        setState(() => _mensaje = "Error al crear gasto");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Gasto")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _montoController,
              decoration: const InputDecoration(labelText: "Monto"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _metodo,
              items: const [
                DropdownMenuItem(value: 'EQUITATIVO', child: Text('Equitativo')),
                DropdownMenuItem(value: 'PROPORCIONAL', child: Text('Proporcional')),
                DropdownMenuItem(value: 'PERSONALIZADO', child: Text('Personalizado')),
              ],
              onChanged: (value) => setState(() => _metodo = value!),
              decoration: const InputDecoration(labelText: "Método de distribución"),
            ),

            const SizedBox(height: 20),
            if (_metodo == 'PERSONALIZADO') ...[
              const Text("Asignar porcentajes a integrantes:"),
              ...widget.integrantes.map((i) {
                return TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "${i['username']} (%)"),
                  onChanged: (val) {
                    final porcentaje = double.tryParse(val) ?? 0;
                    setState(() {
                      _porcentajes[i['username']] = porcentaje;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 10),
              Text(
                "Total: ${_porcentajes.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}%",
                style: TextStyle(
                    color: (_porcentajes.values.fold(0.0, (a, b) => a + b) - 100).abs() > 0.01
                        ? Colors.red
                        : Colors.green),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(onPressed: _crearGasto, child: const Text("Crear")),
            if (_mensaje != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(_mensaje!),
              )
          ],
        ),
      ),
    );
  }
}

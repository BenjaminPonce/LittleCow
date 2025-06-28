import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NuevoGastoScreen extends StatefulWidget {
  @override
  _NuevoGastoScreenState createState() => _NuevoGastoScreenState();
}

class _NuevoGastoScreenState extends State<NuevoGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  final ApiService _api = ApiService();
  bool _cargando = false;

  Future<void> _guardarGasto() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);
      
      try {
        await _api.crearGasto(
          descripcion: _descripcionController.text,
          monto: double.parse(_montoController.text),
          pagadorId: 1, // Por ahora usamos un ID fijo, después implementarás usuarios
          grupoId: 1,   // Por ahora usamos un ID fijo, después implementarás grupos
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gasto creado exitosamente')),
        );
        
        Navigator.pop(context, true); // Regresa con resultado true
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Gasto'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción del gasto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardarGasto,
                  child: _cargando 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Guardar Gasto', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }
}
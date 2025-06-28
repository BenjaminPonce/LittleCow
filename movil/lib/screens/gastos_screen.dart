import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'nuevo_gasto_screen.dart';

class GastosScreen extends StatefulWidget {
  @override
  _GastosScreenState createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _gastos;

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  void _cargarGastos() {
    setState(() {
      _gastos = api.getGastos();
    });
  }

  Future<void> _navegarANuevoGasto() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NuevoGastoScreen()),
    );
    
    // Si se creó un gasto exitosamente, recarga la lista
    if (resultado == true) {
      _cargarGastos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _gastos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay gastos', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _navegarANuevoGasto,
                    child: Text('Agregar primer gasto'),
                  ),
                ],
              ),
            );
          }
          
          final gastos = snapshot.data!;
          return ListView.builder(
            itemCount: gastos.length,
            itemBuilder: (context, index) {
              final gasto = gastos[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.receipt, color: Colors.white),
                  ),
                  title: Text(gasto['descripcion']),
                  subtitle: Text('Fecha: ${gasto['fecha'].substring(0, 10)}'),
                  trailing: Text(
                    '\$${gasto['monto']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarANuevoGasto,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
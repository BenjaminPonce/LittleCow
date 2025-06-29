import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LittleCow'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 100,
              color: Colors.blue.shade600,
            ),
            SizedBox(height: 24),
            Text(
              'Gestor de Gastos Compartidos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/crear-grupo'),
                icon: Icon(Icons.add),
                label: Text('Crear grupo de gasto compartido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
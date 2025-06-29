import 'package:flutter/material.dart';

class DatosSection extends StatelessWidget {
  final TextEditingController nombreController;
  final bool enabled;

  const DatosSection({
    super.key,
    required this.nombreController,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nombreController,
              enabled: enabled,
              decoration: InputDecoration(
                labelText: 'Nombre del grupo',
                hintText: 'Ej: Vacaciones familiares 2024',
                prefixIcon: Icon(Icons.group, color: Colors.blue.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingrese el nombre del grupo';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
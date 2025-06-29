import 'package:flutter/material.dart';
import '../models/crear_grupo_model.dart';

class ActualizarTablaSection extends StatelessWidget {
  final List<Integrante> integrantes;
  final double montoTotal;

  const ActualizarTablaSection({
    Key? key,
    required this.integrantes,
    required this.montoTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: Colors.blue.shade600),
                SizedBox(width: 8),
                Text(
                  'ACTUALIZAR TABLA DE COMPONENTES',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Información del grupo
            if (montoTotal > 0) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monto Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      '\$${montoTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            
            // Tabla de integrantes
            if (integrantes.isNotEmpty) ...[
              Text(
                'Integrantes del Grupo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    // Header
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      children: [
                        _buildTableHeader('Nombre'),
                        _buildTableHeader('Porcentaje'),
                        _buildTableHeader('Monto'),
                      ],
                    ),
                    // Rows
                    ...integrantes.map((integrante) => TableRow(
                      children: [
                        _buildTableCell(integrante.nombre),
                        _buildTableCell('${integrante.porcentaje?.toStringAsFixed(1) ?? '0.0'}%'),
                        _buildTableCell('\$${_calcularMontoIntegrante(integrante).toStringAsFixed(2)}'),
                      ],
                    )).toList(),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay integrantes agregados',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Crea un grupo y agrega integrantes para ver la tabla',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  double _calcularMontoIntegrante(Integrante integrante) {
    if (montoTotal <= 0 || integrante.porcentaje == null) return 0.0;
    return (montoTotal * integrante.porcentaje!) / 100;
  }
}
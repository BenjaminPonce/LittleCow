import 'package:flutter/material.dart';
import '../controllers/crear_grupo_controller.dart';

class ControlSection extends StatelessWidget {
  final CrearGrupoController controller;
  final VoidCallback onAgregarIntegrante;
  final VoidCallback onModificarMonto;
  final VoidCallback onDistribuirGasto;
  final VoidCallback onVolver;
  final VoidCallback onConfirmar;

  const ControlSection({
    Key? key,
    required this.controller,
    required this.onAgregarIntegrante,
    required this.onModificarMonto,
    required this.onDistribuirGasto,
    required this.onVolver,
    required this.onConfirmar,
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
            Text(
              'Control',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            
            // Grid de botones como en la interfaz
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children: [
                _buildControlButton(
                  icon: Icons.person_add,
                  label: 'Agregar\nintegrante',
                  onPressed: controller.grupoCreado != null ? onAgregarIntegrante : null,
                  color: Colors.green,
                ),
                _buildControlButton(
                  icon: Icons.edit,
                  label: 'Modificar\nmonto',
                  onPressed: controller.grupoCreado != null ? onModificarMonto : null,
                  color: Colors.orange,
                ),
                _buildControlButton(
                  icon: Icons.share,
                  label: 'Distribuir\ngasto',
                  onPressed: controller.grupoCreado != null && 
                             controller.montoTotal > 0 && 
                             controller.integrantes.isNotEmpty 
                      ? onDistribuirGasto 
                      : null,
                  color: Colors.purple,
                ),
                _buildControlButton(
                  icon: Icons.arrow_back,
                  label: 'Volver',
                  onPressed: onVolver,
                  color: Colors.grey,
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Botón Confirmar central (siguiendo el diagrama)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.loading || controller.grupoCreado != null 
                    ? null 
                    : onConfirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getConfirmarButtonColor(),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: controller.loading
                    ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_getConfirmarButtonIcon(), size: 20),
                          SizedBox(width: 8),
                          Text(
                            _getConfirmarButtonText(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color : Colors.grey.shade300,
        foregroundColor: onPressed != null ? Colors.white : Colors.grey.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: onPressed != null ? 2 : 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfirmarButtonColor() {
    if (controller.grupoCreado != null) return Colors.green;
    return Colors.blue.shade600;
  }

  IconData _getConfirmarButtonIcon() {
    if (controller.grupoCreado != null) return Icons.check_circle;
    return Icons.add_circle;
  }

  String _getConfirmarButtonText() {
    if (controller.grupoCreado != null) return 'Grupo Creado';
    return 'Confirmar';
  }
}
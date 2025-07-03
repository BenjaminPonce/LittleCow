import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/crear_grupo_controller.dart';
import '../widgets/datos_section.dart';
import '../widgets/control_section.dart';
import '../widgets/actualizar_tabla_section.dart';
import '../widgets/dialogs/agregar_integrante_dialog.dart';
import '../widgets/dialogs/modificar_monto_dialog.dart';

class CrearGrupoView extends StatefulWidget {
  @override
  _CrearGrupoViewState createState() => _CrearGrupoViewState();
}

class _CrearGrupoViewState extends State<CrearGrupoView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CrearGrupoController>(context, listen: false).cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear grupo de gasto compartido'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _volverAlSistema(context),
        ),
      ),
      body: Consumer<CrearGrupoController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sección Datos (habilitar_en_nombre_grupo)
                  DatosSection(
                    nombreController: _nombreController,
                    enabled: !controller.loading && controller.grupoCreado == null,
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Sección Control (presionar_en_confirm + otras acciones)
                  ControlSection(
                    controller: controller,
                    onAgregarIntegrante: () => _agregarIntegrante(context, controller),
                    onModificarMonto: () => _modificarMonto(context, controller),
                    onDistribuirGasto: () => _distribuirGasto(controller),
                    onVolver: () => _volverAlSistema(context),
                    onConfirmar: () => _confirmarCreacion(controller),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Sección Actualizar tabla de componentes
                  ActualizarTablaSection(
                    integrantes: controller.integrantes,
                    montoTotal: controller.montoTotal,
                  ),
                  
                  // Mostrar errores si existen
                  if (controller.error != null)
                    _buildErrorSection(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorSection(CrearGrupoController controller) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Card(
        color: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.red.shade200),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade600),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.error!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.clearError,
                icon: Icon(Icons.close, color: Colors.red.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Implementa la secuencia: Presionar_en_confirm()
  Future<void> _confirmarCreacion(CrearGrupoController controller) async {
    if (_formKey.currentState!.validate()) {
      // Enviar_nom_grupo(nom_grupo)
      await controller.crearGrupoCompartido(_nombreController.text.trim());
      
      // Confirmar_grupo_creado + Confirmar_jefe_de_grupo
      if (controller.error == null && controller.grupoCreado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Grupo "${controller.grupoCreado!.nombre}" creado exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Agregar integrante al grupo (después de creación)
  void _agregarIntegrante(BuildContext context, CrearGrupoController controller) {
    if (controller.grupoCreado == null) {
      _mostrarMensajeError('Debe crear un grupo primero');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AgregarIntegranteDialog(
        controller: controller,
      ),
    );
  }

  // Modificar monto del gasto compartido
  void _modificarMonto(BuildContext context, CrearGrupoController controller) {
    if (controller.grupoCreado == null) {
      _mostrarMensajeError('Debe crear un grupo primero');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => ModificarMontoDialog(
        controller: controller,
      ),
    );
  }

  // Distribuir gasto compartido
  Future<void> _distribuirGasto(CrearGrupoController controller) async {
    if (controller.grupoCreado == null) {
      _mostrarMensajeError('Debe crear un grupo primero');
      return;
    }

    if (controller.montoTotal <= 0) {
      _mostrarMensajeError('Debe establecer un monto mayor a 0');
      return;
    }

    if (controller.integrantes.isEmpty) {
      _mostrarMensajeError('Debe agregar al menos un integrante');
      return;
    }

    // Confirmar distribución
    final confirmar = await _mostrarDialogoConfirmacion(
      'Distribuir Gasto',
      '¿Está seguro de distribuir \$${controller.montoTotal.toStringAsFixed(2)} entre ${controller.integrantes.length} integrantes?',
    );

    if (confirmar == true) {
      await controller.distribuirGasto();
      
      if (controller.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gasto distribuido exitosamente'),
            backgroundColor: Colors.purple,
          ),
        );
      }
    }
  }

  // Volver al sistema LittleCow
  void _volverAlSistema(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Text(mensaje),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion(String titulo, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }
}
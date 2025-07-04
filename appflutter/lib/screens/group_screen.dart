import 'package:appflutter/services/gastos_service.dart';
import 'package:flutter/material.dart';
import '../services/group_service.dart';

class GrupoDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;

  const GrupoDetalleScreen({super.key, required this.grupo});

  @override
  State<GrupoDetalleScreen> createState() => _GrupoDetalleScreenState();
}

class _GrupoDetalleScreenState extends State<GrupoDetalleScreen> {
  Map<String, dynamic>? _detalle;
  bool _cargando = true;
  final _usernameController = TextEditingController();
  final _ingresoController = TextEditingController();
  String? _mensajeError;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() {
      _cargando = true;
    });

    final data = await GroupService.getDetalleGrupo(widget.grupo['id']);
    setState(() {
      _detalle = data;
      _cargando = false;
    });
  }

  Future<void> _agregarIntegrante() async {
    final username = _usernameController.text.trim();
    final ingreso = double.tryParse(_ingresoController.text.trim());

    if (username.isEmpty || ingreso == null || ingreso <= 0) {
      setState(() => _mensajeError = "Datos inválidos");
      return;
    }

    final error = await GroupService.agregarIntegrante(
      grupoId: widget.grupo['id'],
      username: username,
      ingreso: ingreso,
    );

    if (error == null) {
      _usernameController.clear();
      _ingresoController.clear();
      setState(() {
        _mensajeError = null;
      });
      await _cargarDetalle(); // refrescar vista
    } else {
      setState(() => _mensajeError = error);
    }
  }

  Future<double?> _mostrarDialogoModificarMonto(BuildContext context, dynamic montoActual) async {
    final controller = TextEditingController(text: montoActual?.toString() ?? '');
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modificar monto total del gasto"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Nuevo monto"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                final valor = double.tryParse(controller.text);
                if (valor != null && valor > 0) {
                  Navigator.pop(context, valor);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ingrese un monto válido")),
                  );
                }
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _mostrarDialogoDistribuirGasto(BuildContext context, List integrantes) async {
    String metodoSeleccionado = 'EQUITATIVO';
    Map<String, TextEditingController> controllers = {};

    for (var integrante in integrantes) {
      controllers[integrante['username']] = TextEditingController(text: '0');
    }

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Distribuir gasto"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: metodoSeleccionado,
                    onChanged: (val) {
                      if (val != null) setState(() => metodoSeleccionado = val);
                    },
                    items: const [
                      DropdownMenuItem(value: 'EQUITATIVO', child: Text('Equitativo')),
                      DropdownMenuItem(value: 'PERSONALIZADO', child: Text('Personalizado')),
                    ],
                  ),
                  if (metodoSeleccionado == 'PERSONALIZADO') ...[
                    const SizedBox(height: 10),
                    ...integrantes.map<Widget>((i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextField(
                          controller: controllers[i['username']],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: "${i['username']} (%)",
                            hintText: "0 a 100",
                          ),
                        ),
                      );
                    }).toList(),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                onPressed: () {
                  if (metodoSeleccionado == 'PERSONALIZADO') {
                    double suma = 0;
                    final porcentajes = <String, double>{};
                    for (var username in controllers.keys) {
                      final val = double.tryParse(controllers[username]!.text) ?? 0;
                      if (val < 0 || val > 100) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Porcentajes deben estar entre 0 y 100")),
                        );
                        return;
                      }
                      suma += val;
                      porcentajes[username] = val;
                    }
                    if ((suma - 100).abs() > 0.01) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("La suma de porcentajes debe ser 100")),
                      );
                      return;
                    }
                    Navigator.pop(context, {"metodo": metodoSeleccionado, "porcentajes": porcentajes});
                  } else {
                    Navigator.pop(context, {"metodo": metodoSeleccionado, "porcentajes": null});
                  }
                },
                child: const Text("Aplicar"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gasto = _detalle!['gasto'];
    final integrantes = _detalle!['integrantes'] ?? [];
    final esJefe = _detalle!['es_jefe'] == true;

    return Scaffold(
      appBar: AppBar(title: Text("Grupo: ${_detalle!['nombre']}"),
      actions: [
        if (esJefe)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("¿Eliminar grupo?"),
                  content: const Text("Esta acción no se puede deshacer."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
                  ],
                ),
              );

              if (confirm == true) {
                final error = await GroupService.eliminarGrupo(widget.grupo['id']);
                if (error == null) {
                  Navigator.pop(context, true); // volver a lista de grupos y recargar
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
                }
              }
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("¿Salir del grupo?"),
                  content: const Text("Perderás acceso a la información del grupo."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Salir")),
                  ],
                ),
              );

              if (confirm == true) {
                final error = await GroupService.salirDeGrupo(widget.grupo['id']);
                if (error == null) {
                  Navigator.pop(context, true); // volver a lista de grupos
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
                }
              }
            },
          ),
      ],),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Jefe: ${_detalle!['jefe']}", style: const TextStyle(fontSize: 18)),
            Text("Correo: ${_detalle!['jefe_correo']}", style: const TextStyle(fontSize: 16)),
            Text("Creado el: ${_detalle!['fecha_creacion'].toString().substring(0, 10)}"),
            const SizedBox(height: 20),

            gasto != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Gasto asociado:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Monto: \$${gasto['monto_total']}"),
                      Text("Método: ${gasto['metodo_distribucion']}"),
                      //Text("Creado por: ${gasto['creado_por']}"),
                    ],
                  )
                : const Text("No hay gasto registrado."),

            const SizedBox(height: 30),
            const Text("Integrantes:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...integrantes.map<Widget>((i) {
              return ListTile(
                leading: Icon(i['es_actual'] ? Icons.person : Icons.group),
                title: Text(i['username']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ingreso: \$${i['ingreso_personal']} | Porcentaje: ${i['porcentaje']}%"),
                    if (i['monto_asignado'] != null)
                      Text("Debe pagar: \$${i['monto_asignado']}"),
                  ],
                ),
                tileColor: i['es_actual'] ? Colors.grey[200] : null,
                trailing: i['es_actual']
                  ? null // no mostrar opciones para uno mismo
                  : esJefe
                      ? IconButton( // solo jefes pueden eliminar
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Confirmar eliminación"),
                                content: Text("¿Eliminar a ${i['username']} del grupo?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final error = await GroupService.eliminarIntegrante(
                                grupoId: widget.grupo['id'],
                                username: i['username'],
                              );
                              if (error == null) {
                                await _cargarDetalle(); // recargar integrantes
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $error")),
                                );
                              }
                            }
                          },
                        )
                      : PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'reportar') {
                              final comentario = await showDialog<String>(
                                context: context,
                                builder: (_) {
                                  final controller = TextEditingController();
                                  return AlertDialog(
                                    title: Text("Reportar a ${i['username']}"),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(labelText: "Motivo"),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                                      ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Reportar")),
                                    ],
                                  );
                                },
                              );

                              if (comentario != null && comentario.trim().isNotEmpty) {
                                final error = await GroupService.reportarIntegrante(
                                  grupoId: widget.grupo['id'],
                                  username: i['username'],
                                  comentario: comentario.trim(),
                                );

                                if (error == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reporte enviado")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
                                }
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem<String>(
                              value: 'reportar',
                              child: Text("Reportar"),
                            ),
                          ],
                        ),
              );
            }).toList(),

            if (esJefe && integrantes.length >= 1) ...[
              const SizedBox(height: 30),
              const Divider(),

              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Modificar monto del gasto"),
                onPressed: () async {
                  final nuevoMonto = await _mostrarDialogoModificarMonto(context, gasto?['monto_total']);
                  if (nuevoMonto != null) {
                    final exito = await GastosService.modificarGasto(
                      grupoId: widget.grupo['id'],
                      montoNuevo: nuevoMonto,
                    );
                    if (exito) {
                      await _cargarDetalle();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Monto modificado")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al modificar monto")));
                    }
                  }
                },
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                icon: const Icon(Icons.sync_alt),
                label: const Text("Distribuir gasto"),
                onPressed: () async {
                  final resultado = await _mostrarDialogoDistribuirGasto(context, integrantes);
                  if (resultado != null) {
                    final metodo = resultado['metodo'] as String;
                    final porcentajes = resultado['porcentajes'] as Map<String, double>?;

                    final exito = await GastosService.distribuirGasto(
                      grupoId: widget.grupo['id'],
                      metodo: metodo,
                      porcentajes: porcentajes,
                    );

                    if (exito) {
                      await _cargarDetalle();
                      setState(() {}); // <<< esta línea fue agregada
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gasto distribuido correctamente")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al distribuir gasto")));
                    }
                  }
                },
              ),
            ],

            if (esJefe) ...[
              const SizedBox(height: 30),
              const Divider(),
              const Text("Agregar integrante", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Nombre de usuario"),
              ),
              TextField(
                controller: _ingresoController,
                decoration: const InputDecoration(labelText: "Ingreso personal"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _agregarIntegrante,
                child: const Text("Añadir integrante"),
              ),
              if (_mensajeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _mensajeError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

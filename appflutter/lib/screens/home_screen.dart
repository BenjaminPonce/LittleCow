import 'package:appflutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'create_group_screen.dart';
import 'login_screen.dart';
import 'group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _usuario;
  List<Map<String, dynamic>> _grupos = [];
  bool _cargando = true;

  Future<void> _cargarDatos() async {
    final perfil = await UserService.getPerfilUsuario();
    final grupos = await UserService.getMisGrupos();

    setState(() {
      _usuario = perfil;
      _grupos = grupos;
      _cargando = false;
    });
  }

  Future<void> _cargarGrupos() async {
    _grupos = await UserService.getMisGrupos();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cerrarSesion() {
    AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando || _usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Gastos Compartidos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("¡Bienvenido, ${_usuario!['username']}!",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            const Text("Tus Grupos:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final creado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                );
                if (creado == true) {
                  await _cargarDatos(); // Recargar si se creó uno nuevo
                }
              },
              child: const Text("Crear nuevo grupo"),
            ),
            const SizedBox(height: 20),
            _grupos.isEmpty
                ? const Text("No perteneces a ningún grupo.")
                : Expanded(
                    child: ListView.builder(
                      itemCount: _grupos.length,
                      itemBuilder: (context, index) {
                        final grupo = _grupos[index];
                        return Card(
                          child: ListTile(
                            title: Text(grupo['nombre']),
                            subtitle: Text(
                              "Ingreso: \$${grupo['ingreso_personal']} | Porcentaje: ${double.parse(grupo['porcentaje'].toString()).toStringAsFixed(2)}%",
                            ),
                            trailing: grupo['es_jefe']
                                ? const Icon(Icons.star, color: Colors.orange)
                                : null,
                            onTap: () async {
                              final bool? actualizado = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GrupoDetalleScreen(grupo: grupo),
                                ),
                              );
                              if (actualizado == true) {
                                await _cargarGrupos();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

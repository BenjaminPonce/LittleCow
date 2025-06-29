import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/crear_grupo_controller.dart';
import 'views/crear_grupo_view.dart';
import 'views/home_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String token = '3702a8ffa9c61825d29e4b23ce57bd67a301a339';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final controller = CrearGrupoController();
            controller.setToken('3702a8ffa9c61825d29e4b23ce57bd67a301a339');
            return controller;
          },
        ),
        // Aquí puedes agregar más controladores según necesites
      ],
      child: MaterialApp(
        title: 'LittleCow - Gastos Compartidos',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData( // ← Cambiar de CardTheme a CardThemeData
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeView(),
          '/crear-grupo': (context) => CrearGrupoView(),
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init(); // ← Carga el token desde SharedPreferences

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute =
        ApiService.token != null ? const HomeScreen() : const LoginScreen();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LittleCow (beta)',
      home: initialRoute,
    );
  }
}

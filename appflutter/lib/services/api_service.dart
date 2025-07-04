import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";
  static String? _authToken;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('token');
  }

  static String? get token => _authToken;

  static Future setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('token', token);
      _authToken = token;
    } else {
      await prefs.remove('token');
      _authToken = null;
    }
  }
}
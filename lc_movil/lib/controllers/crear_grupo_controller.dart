import 'package:flutter/foundation.dart';
import '../models/crear_grupo_model.dart';
import '../services/grupo_service.dart';

class CrearGrupoController with ChangeNotifier {
  final GrupoService _grupoService = GrupoService();

  String? _token;
  
  // Estado del controlador
  bool _loading = false;
  String? _error;
  GrupoCreacion? _grupoCreado;
  List<Integrante> _integrantes = [];
  double _montoTotal = 0.0;
  String _distribucion = '';
  List<Map<String, dynamic>> _usuariosDisponibles = [];

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  GrupoCreacion? get grupoCreado => _grupoCreado;
  List<Integrante> get integrantes => _integrantes;
  double get montoTotal => _montoTotal;
  String get distribucion => _distribucion;
  List<Map<String, dynamic>> get usuariosDisponibles => _usuariosDisponibles;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  // Implementa la secuencia del diagrama
  Future crearGrupoCompartido(String nombreGrupo) async {
    _setLoading(true);
    _clearError();
    
    try {
      final grupo = GrupoCreacion(nombre: nombreGrupo.trim());
      final resultado = await _grupoService.crearGrupoCompleto(grupo, _token!);
      
      // Procesar respuesta anidada
      _grupoCreado = GrupoCreacion.fromJson(resultado);
      
      // Mostrar datos en consola para debug
      if (kDebugMode) {
        print('✅ Grupo creado: ${_grupoCreado?.nombre}');
        print('🆔 ID: ${_grupoCreado?.id}');
        print('👑 Jefe ID: ${_grupoCreado?.jefeId}');
      }
    } catch (e) {
      _setError('Error al crear grupo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // agregar integrante al grupo
  Future<void> agregarIntegrante({required String username}) async {
    if (_grupoCreado == null) {
      _setError('Debe crear un grupo primero');
      return;
    }

    _setLoading(true);
    try {
      await _grupoService.agregarIntegrante(
        grupoId: _grupoCreado!.id!,
        username: username,
        token: _token!,
      );

      // Actualizar lista local
      _integrantes.add(Integrante(
        usuarioId: '', // Se llenará desde el backend
        nombre: username,
        porcentaje: 0.0,  // Valor por defecto
        ingresoPersonal: 0.0,  // Valor por defecto
      ));
      
      notifyListeners();
    } catch (e) {
      _setError('Error al agregar integrante: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Modificar monto del gasto compartido
  void modificarMonto(double nuevoMonto) {
    _montoTotal = nuevoMonto;
    notifyListeners();
  }

  // Distribuir gasto
  Future<void> distribuirGasto() async {
    if (_grupoCreado == null) {
      _setError('Debe crear un grupo antes de distribuir gastos');
      return;
    }

    if (_montoTotal <= 0) {
      _setError('El monto debe ser mayor a 0');
      return;
    }

    _setLoading(true);
    try {
      await _grupoService.distribuirGasto(
        grupoId: _grupoCreado!.id!,
        montoTotal: _montoTotal,
        distribucion: _distribucion,
        token: _token!,
      );
      
      if (kDebugMode) print('Gasto distribuido exitosamente');
      
    } catch (e) {
      _setError('Error al distribuir gasto: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar usuarios disponibles
  Future<void> cargarUsuarios() async {
    if (_token == null || _token!.isEmpty) {
      _setError('Token de autenticación no configurado');
      return;
    }

    _setLoading(true);
    try {
      _usuariosDisponibles = await _grupoService.getUsuarios(_token!);
    } catch (e) {
      _setError('Error al cargar usuarios: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos auxiliares
  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void resetController() {
    _grupoCreado = null;
    _integrantes.clear();
    _montoTotal = 0.0;
    _distribucion = '';
    _clearError();
    notifyListeners();
  }
}
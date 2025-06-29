class GrupoCreacion {
  final String? id;
  final String nombre;
  final String? jefeId;
  final DateTime? fechaCreacion;

  GrupoCreacion({
    this.id,
    required this.nombre,
    this.jefeId,
    this.fechaCreacion,
  });

  factory GrupoCreacion.fromJson(Map<String, dynamic> json) {
    // Manejar estructura anidada
    final grupoData = json['grupo'] ?? json;
    final jefeData = json['jefe'] ?? {};

    return GrupoCreacion(
      id: grupoData['id']?.toString(),
      nombre: grupoData['nombre'] as String,
      jefeId: jefeData['id']?.toString(), // Extrae ID del jefe
      // Campos adicionales si los necesitas
      fechaCreacion: grupoData['fecha_creacion'] != null 
          ? DateTime.tryParse(grupoData['fecha_creacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (jefeId != null) 'jefe_id': jefeId,
    };
  }
}

class Integrante {
  final String usuarioId;
  final String nombre;
  final double? porcentaje;
  final double? ingresoPersonal;

  Integrante({
    required this.usuarioId,
    required this.nombre,
    this.porcentaje,
    this.ingresoPersonal,
  });

  factory Integrante.fromJson(Map<String, dynamic> json) {
    return Integrante(
      usuarioId: json['usuario_id'].toString(),
      nombre: json['nombre'],
      porcentaje: json['porcentaje']?.toDouble(),
      ingresoPersonal: json['ingreso_personal']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre': nombre,
      'porcentaje': porcentaje,
      'ingreso_personal': ingresoPersonal,
    };
  }
}
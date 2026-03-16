class Insumo {
  String id;
  String nombre;
  double cantidadEnvase;
  String unidad;
  double costoEnvase;

  Insumo({
    required this.id,
    required this.nombre,
    required this.cantidadEnvase,
    required this.unidad,
    required this.costoEnvase,
  });

  Insumo copyWith({
    String? id,
    String? nombre,
    double? cantidadEnvase,
    String? unidad,
    double? costoEnvase,
  }) {
    return Insumo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidadEnvase: cantidadEnvase ?? this.cantidadEnvase,
      unidad: unidad ?? this.unidad,
      costoEnvase: costoEnvase ?? this.costoEnvase,
    );
  }
}

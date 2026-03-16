
class ItemReceta {
  String insumoId;
  /// Cantidad de este insumo necesaria para producir 1 unidad del producto.
  /// Se asume que está en la misma unidad de medida que el Insumo.
  double cantidadUsada;

  ItemReceta({
    required this.insumoId,
    required this.cantidadUsada,
  });

  ItemReceta copyWith({
    String? insumoId,
    double? cantidadUsada,
  }) {
    return ItemReceta(
      insumoId: insumoId ?? this.insumoId,
      cantidadUsada: cantidadUsada ?? this.cantidadUsada,
    );
  }
}

class Producto {
  String id;
  String nombre;
  List<ItemReceta> items;

  Producto({
    required this.id,
    required this.nombre,
    this.items = const [],
  });

  Producto copyWith({
    String? id,
    String? nombre,
    List<ItemReceta>? items,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      items: items ?? this.items,
    );
  }
}

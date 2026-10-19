class ItemReceta {
  String insumoId;

  /// Cantidad de este insumo necesaria para producir 1 unidad del producto.
  /// Se asume que está en la misma unidad de medida que el Insumo.
  double cantidadUsada;

  ItemReceta({required this.insumoId, required this.cantidadUsada});

  ItemReceta copyWith({String? insumoId, double? cantidadUsada}) {
    return ItemReceta(
      insumoId: insumoId ?? this.insumoId,
      cantidadUsada: cantidadUsada ?? this.cantidadUsada,
    );
  }

  Map<String, dynamic> toJson() {
    return {'insumoId': insumoId, 'cantidadUsada': cantidadUsada};
  }

  factory ItemReceta.fromJson(Map<String, dynamic> json) {
    return ItemReceta(
      insumoId: json['insumoId'],
      cantidadUsada: (json['cantidadUsada'] as num).toDouble(),
    );
  }
}

class Producto {
  String id;
  String nombre;
  List<ItemReceta> items;

  Producto({required this.id, required this.nombre, this.items = const []});

  Producto copyWith({String? id, String? nombre, List<ItemReceta>? items}) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'items': items.map((x) => x.toJson()).toList(),
    };
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      items: List<ItemReceta>.from(
        json['items']?.map((x) => ItemReceta.fromJson(x)) ?? [],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/insumo.dart';
import '../models/producto.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();

  List<Insumo> _insumos = [];
  List<Producto> _productos = [];

  List<Insumo> get insumos => _insumos;
  List<Producto> get productos => _productos;

  AppState() {
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Insumos
    final insumosString = prefs.getString('insumos');
    if (insumosString != null) {
      final List<dynamic> insumosJson = jsonDecode(insumosString);
      _insumos = insumosJson.map((i) => Insumo.fromJson(i)).toList();
    }

    // Load Productos
    final productosString = prefs.getString('productos');
    if (productosString != null) {
      final List<dynamic> productosJson = jsonDecode(productosString);
      _productos = productosJson.map((p) => Producto.fromJson(p)).toList();
    }

    // Si están vacíos, cargar la dummy data y guardar
    if (_insumos.isEmpty && _productos.isEmpty) {
      _loadDummyData();
    } else {
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final insumosString = jsonEncode(_insumos.map((i) => i.toJson()).toList());
    final productosString = jsonEncode(
      _productos.map((p) => p.toJson()).toList(),
    );

    await prefs.setString('insumos', insumosString);
    await prefs.setString('productos', productosString);
  }

  void _loadDummyData() {
    // Insumos del ejemplo
    final chocotina = Insumo(
      id: _uuid.v4(),
      nombre: 'Chocotina',
      cantidadEnvase: 500,
      unidad: 'g',
      costoEnvase: 10,
    );
    final crema = Insumo(
      id: _uuid.v4(),
      nombre: 'Crema',
      cantidadEnvase: 1,
      unidad: 'l',
      costoEnvase: 10,
    );
    final cacao = Insumo(
      id: _uuid.v4(),
      nombre: 'Cacao',
      cantidadEnvase: 100,
      unidad: 'g',
      costoEnvase: 3.5,
    );
    final lecheLiq = Insumo(
      id: _uuid.v4(),
      nombre: 'Leche Líquida',
      cantidadEnvase: 1,
      unidad: 'l',
      costoEnvase: 3,
    );
    final lechePolvo = Insumo(
      id: _uuid.v4(),
      nombre: 'Leche en Polvo',
      cantidadEnvase: 900,
      unidad: 'g',
      costoEnvase: 17,
    );
    final azucar = Insumo(
      id: _uuid.v4(),
      nombre: 'Azúcar',
      cantidadEnvase: 1000,
      unidad: 'g',
      costoEnvase: 2.5,
    );
    final emulsionante = Insumo(
      id: _uuid.v4(),
      nombre: 'Emulsionante',
      cantidadEnvase: 200,
      unidad: 'g',
      costoEnvase: 8,
    );

    _insumos = [
      chocotina,
      crema,
      cacao,
      lecheLiq,
      lechePolvo,
      azucar,
      emulsionante,
    ];

    // Producto del ejemplo
    final chocoAvellana = Producto(
      id: _uuid.v4(),
      nombre: 'Helado Choco-Avellana',
      items: [
        ItemReceta(
          insumoId: chocotina.id,
          cantidadUsada: 500 / 40,
        ), // Para que el rendimiento sea 40
        ItemReceta(insumoId: crema.id, cantidadUsada: 1 / 72), // Rendimiento 72
        ItemReceta(
          insumoId: cacao.id,
          cantidadUsada: 100 / 45,
        ), // Rendimiento 45
        ItemReceta(
          insumoId: lecheLiq.id,
          cantidadUsada: 1 / 18,
        ), // Rendimiento 18
        ItemReceta(
          insumoId: lechePolvo.id,
          cantidadUsada: 900 / 405,
        ), // Rendimiento 405
        ItemReceta(
          insumoId: azucar.id,
          cantidadUsada: 1000 / 47,
        ), // Rendimiento 47
        ItemReceta(
          insumoId: emulsionante.id,
          cantidadUsada: 200 / 514,
        ), // Rendimiento 514
      ],
    );

    _productos = [chocoAvellana];
    _saveData();
    notifyListeners();
  }

  // Métodos CRUD Insumos
  void addInsumo(Insumo insumo) {
    insumo.id = _uuid.v4();
    _insumos.add(insumo);
    _saveData();
    notifyListeners();
  }

  void updateInsumo(Insumo inInsumo) {
    final index = _insumos.indexWhere((i) => i.id == inInsumo.id);
    if (index != -1) {
      _insumos[index] = inInsumo;
      _saveData();
      notifyListeners();
    }
  }

  void deleteInsumo(String id) {
    _insumos.removeWhere((i) => i.id == id);
    // Eliminar también las referencias en los productos
    for (var producto in _productos) {
      producto.items.removeWhere((item) => item.insumoId == id);
    }
    _saveData();
    notifyListeners();
  }

  // Métodos CRUD Productos
  void addProducto(Producto producto) {
    producto.id = _uuid.v4();
    _productos.add(producto);
    _saveData();
    notifyListeners();
  }

  void updateProducto(Producto producto) {
    final index = _productos.indexWhere((p) => p.id == producto.id);
    if (index != -1) {
      _productos[index] = producto;
      _saveData();
      notifyListeners();
    }
  }

  void deleteProducto(String id) {
    _productos.removeWhere((p) => p.id == id);
    _saveData();
    notifyListeners();
  }

  // Helpers
  Insumo? getInsumoById(String id) {
    try {
      return _insumos.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }
}

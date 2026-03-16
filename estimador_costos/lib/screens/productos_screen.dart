import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/producto.dart';
import 'detalle_producto_screen.dart';

class ProductosScreen extends StatelessWidget {
  const ProductosScreen({super.key});

  void _showNuevoProductoDialog(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final nombreCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Producto'),
        content: TextField(
          controller: nombreCtrl,
          decoration: const InputDecoration(labelText: 'Nombre (ej. Helado de Fresa)'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final valNombre = nombreCtrl.text.trim();
              if (valNombre.isEmpty) return;

              final nuevoProducto = Producto(
                id: '', // provider sets uuid
                nombre: valNombre,
                items: [],
              );
              
              state.addProducto(nuevoProducto);
              Navigator.pop(ctx);
              
              // Navegar al detalle para que puedan armarlo inmediatamente
              // Note: we fetch the newly added producto (last in list)
              final recienAgregado = state.productos.last;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleProductoScreen(productoId: recienAgregado.id),
                ),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos / Recetas'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final productos = state.productos;
          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos creados.'));
          }

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.icecream),
                ),
                title: Text(producto.nombre),
                subtitle: Text('${producto.items.length} ingredientes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleProductoScreen(productoId: producto.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNuevoProductoDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
      ),
    );
  }
}

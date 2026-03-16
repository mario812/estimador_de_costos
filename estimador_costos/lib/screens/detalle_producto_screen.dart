import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/producto.dart';

class DetalleProductoScreen extends StatefulWidget {
  final String productoId;
  const DetalleProductoScreen({super.key, required this.productoId});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  void _mostrarDialogoAgregarInsumo(BuildContext context, AppState state, Producto producto) {
    String? selectedInsumoId;
    final cantidadCtrl = TextEditingController();
    
    // Filtrar los insumos que ya están en el producto
    final insumosDisponibles = state.insumos.where((i) {
      return !producto.items.any((item) => item.insumoId == i.id);
    }).toList();

    if (insumosDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya se agregaron todos los insumos disponibles.')),
      );
      return;
    }

    selectedInsumoId = insumosDisponibles.first.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            final insumoEnfocado = state.getInsumoById(selectedInsumoId!);
            return AlertDialog(
              title: const Text('Agregar Insumo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedInsumoId,
                      isExpanded: true,
                      items: insumosDisponibles.map((i) {
                        return DropdownMenuItem(
                          value: i.id,
                          child: Text(i.nombre),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateBuilder(() => selectedInsumoId = val);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Insumo'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: cantidadCtrl,
                      decoration: InputDecoration(
                        labelText: 'Cantidad usada por producto',
                        suffixText: insumoEnfocado?.unidad ?? '',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final cantidad = double.tryParse(cantidadCtrl.text) ?? 0;
                    if (cantidad <= 0 || selectedInsumoId == null) return;

                    final updatedUrl = producto.copyWith(
                      items: List.from(producto.items)..add(
                        ItemReceta(insumoId: selectedInsumoId!, cantidadUsada: cantidad)
                      ),
                    );
                    state.updateProducto(updatedUrl);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _mostrarDialogoEditarInsumo(BuildContext context, AppState state, Producto producto, ItemReceta item) {
    final cantidadCtrl = TextEditingController(text: item.cantidadUsada.toString());
    final insumoEnfocado = state.getInsumoById(item.insumoId);
    
    if (insumoEnfocado == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Editar: ${insumoEnfocado.nombre}'),
          content: TextField(
            controller: cantidadCtrl,
            decoration: InputDecoration(
              labelText: 'Cantidad usada por producto',
              suffixText: insumoEnfocado.unidad,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
               onPressed: () {
                 final updatedItems = producto.items.where((i) => i.insumoId != item.insumoId).toList();
                 state.updateProducto(producto.copyWith(items: updatedItems));
                 Navigator.pop(ctx);
               },
               child: const Text('Quitar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final cantidad = double.tryParse(cantidadCtrl.text) ?? 0;
                if (cantidad <= 0) return;

                final updatedItems = producto.items.map((i) {
                  if (i.insumoId == item.insumoId) {
                    return i.copyWith(cantidadUsada: cantidad);
                  }
                  return i;
                }).toList();

                state.updateProducto(producto.copyWith(items: updatedItems));
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final producto = state.productos.firstWhere(
          (p) => p.id == widget.productoId,
          orElse: () => Producto(id: '', nombre: 'No encontrado'),
        );

        if (producto.id.isEmpty) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Error: Producto no encontrado.')));
        }

        double costoTotalProducto = 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Text(producto.nombre),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  state.deleteProducto(producto.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Receta Final', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarDialogoAgregarInsumo(context, state, producto),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Insumo'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                      columns: const [
                        DataColumn(label: Text('Ingrediente')),
                        DataColumn(label: Text('Envase'), numeric: true),
                        DataColumn(label: Text('Costo (\$)'), numeric: true),
                        DataColumn(label: Text('Rendimiento (Cant)'), numeric: true),
                        DataColumn(label: Text('Costo / u. (\$)'), numeric: true),
                        DataColumn(label: Text('Acción')),
                      ],
                      rows: producto.items.map((item) {
                        final insumo = state.getInsumoById(item.insumoId);
                        if (insumo == null) {
                          return const DataRow(cells: [
                            DataCell(Text('Insumo eliminado')),
                            DataCell(Text('-')),
                            DataCell(Text('-')),
                            DataCell(Text('-')),
                            DataCell(Text('-')),
                            DataCell(Text('-')),
                          ]);
                        }

                        // Matemáticas:
                        // Rendimiento = envase / cantidadUsada
                        final rendimiento = insumo.cantidadEnvase / item.cantidadUsada;
                        // Costo Unitario = Costo Envase / Rendimiento
                        final costoUnitario = insumo.costoEnvase / rendimiento;
                        costoTotalProducto += costoUnitario; // Para el total

                        return DataRow(
                          cells: [
                            DataCell(Text(insumo.nombre)),
                            DataCell(Text('${insumo.cantidadEnvase.toStringAsFixed(1)} ${insumo.unidad}')),
                            DataCell(Text(insumo.costoEnvase.toStringAsFixed(2))),
                            DataCell(Text(rendimiento.round().toString())), // as per user's example
                            DataCell(Text(costoUnitario.toStringAsFixed(3))),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _mostrarDialogoEditarInsumo(context, state, producto, item),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.teal.shade50,
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Costo Total de Producción (1 u.):',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${costoTotalProducto.toStringAsFixed(3)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

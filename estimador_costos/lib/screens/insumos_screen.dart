import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/insumo.dart';

class InsumosScreen extends StatelessWidget {
  const InsumosScreen({super.key});

  void _showInsumoDialog(BuildContext context, {Insumo? insumo}) {
    final state = Provider.of<AppState>(context, listen: false);
    final isEditing = insumo != null;

    final nombreCtrl = TextEditingController(text: insumo?.nombre ?? '');
    final envaseCtrl = TextEditingController(
      text: insumo?.cantidadEnvase.toString() ?? '',
    );
    final unidadCtrl = TextEditingController(text: insumo?.unidad ?? '');
    final costoCtrl = TextEditingController(
      text: insumo?.costoEnvase.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar Insumo' : 'Nuevo Insumo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre (ej. Chocotina)',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: envaseCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cant. Envase (ej. 500)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: unidadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Unidad (ej. g, l, ml)',
                ),
              ),
              TextField(
                controller: costoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Costo del Envase (\$)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                state.deleteInsumo(insumo.id);
                Navigator.pop(ctx);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final valNombre = nombreCtrl.text.trim();
              final valEnvase = double.tryParse(envaseCtrl.text) ?? 0;
              final valUnidad = unidadCtrl.text.trim();
              final valCosto = double.tryParse(costoCtrl.text) ?? 0;

              if (valNombre.isEmpty || valUnidad.isEmpty || valEnvase <= 0)
                return;

              if (isEditing) {
                state.updateInsumo(
                  insumo.copyWith(
                    nombre: valNombre,
                    cantidadEnvase: valEnvase,
                    unidad: valUnidad,
                    costoEnvase: valCosto,
                  ),
                );
              } else {
                state.addInsumo(
                  Insumo(
                    id: '',
                    nombre: valNombre,
                    cantidadEnvase: valEnvase,
                    unidad: valUnidad,
                    costoEnvase: valCosto,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insumos')),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final insumos = state.insumos;
          if (insumos.isEmpty) {
            return const Center(child: Text('No hay insumos registrados.'));
          }

          return ListView.builder(
            itemCount: insumos.length,
            itemBuilder: (context, index) {
              final insumo = insumos[index];
              final String subtitulo =
                  '${insumo.cantidadEnvase} ${insumo.unidad} - \$${insumo.costoEnvase.toStringAsFixed(2)}';
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                title: Text(insumo.nombre),
                subtitle: Text(subtitulo),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () => _showInsumoDialog(context, insumo: insumo),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInsumoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

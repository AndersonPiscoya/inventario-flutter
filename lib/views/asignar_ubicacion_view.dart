import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Debes tener este archivo para consumir la API

class AsignarUbicacionView extends StatefulWidget {
  final int? idBien;       // <-- HAZLOS NULLABLES
  final int? idUsuario;    // <-- HAZLOS NULLABLES
  const AsignarUbicacionView({super.key, required this.idBien, required this.idUsuario});
  @override
  State<AsignarUbicacionView> createState() => _AsignarUbicacionViewState();
}


class _AsignarUbicacionViewState extends State<AsignarUbicacionView> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _ubicaciones = [];
  List<dynamic> _estados = [];
  int? _ubicacionSeleccionada;
  int? _estadoSeleccionado;
  String? _detalleTecnico;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCombos();
  }

  Future<void> _fetchCombos() async {
    setState(() => _loading = true);
    try {
      final ubicacionesRes = await ApiService.getUbicaciones(); // Implementar en tu servicio
      final estadosRes = await ApiService.getEstados();         // Implementar en tu servicio
      setState(() {
        _ubicaciones = ubicacionesRes['ubicaciones'] ?? [];
        _estados = estadosRes['estados'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar los combos.';
        _loading = false;
      });
    }
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_ubicacionSeleccionada == null || _estadoSeleccionado == null) return;

    setState(() => _loading = true);

    final body = {
      'idbien': widget.idBien,
      'tipo_mvto': 1, // El id de “asignación inicial”, reemplaza si tienes otro valor
      'fecha_mvto': DateTime.now().toIso8601String().substring(0,10), // Solo fecha
      'detalle_tecnico': _detalleTecnico ?? '',
      'documento_sustentatorio': null, // Opcional
      'idubicacion': _ubicacionSeleccionada,
      'id_estado_conservacion_bien': _estadoSeleccionado,
      'idusuario': widget.idUsuario,
    };

    final res = await ApiService.registrarMovimiento(body);
    setState(() => _loading = false);
    if (res['ok']) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ubicación inicial asignada correctamente"), backgroundColor: Colors.green)
        );
        Navigator.pop(context, true); // Cierra y devuelve “éxito” al padre
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? res['data']?['message'] ?? "Error registrando movimiento"),
            backgroundColor: Colors.red
          )
        );

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Ubicación Inicial', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: _loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(),
                ),
                items: _ubicaciones.map<DropdownMenuItem<int>>((u) => DropdownMenuItem(
                  value: u['id_ubicacion'], // <-- SIN COMILLAS EN value
                  child: Text('${u['nombre_sede']} · ${u['ambiente']} · Piso: ${u['piso_ubicacion']}'),
                )).toList(),
                onChanged: (v) => setState(() => _ubicacionSeleccionada = v),
                validator: (v) => v == null ? 'Seleccione ubicación' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Estado del Bien',
                  border: OutlineInputBorder(),
                ),
                items: _estados.map<DropdownMenuItem<int>>((e) => DropdownMenuItem(
                  value: e['id_estado'],
                  child: Text(e['nombre_estado']),
                )).toList(),
                onChanged: (v) => setState(() => _estadoSeleccionado = v),
                validator: (v) => v == null ? 'Seleccione estado' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Detalle Técnico (opcional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _detalleTecnico = v,
                maxLines: 2,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Guardar y asignar"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text("Cancelar"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

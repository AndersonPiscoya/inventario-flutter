import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';

class BienDetailView extends StatefulWidget {
  final String codigo;
  const BienDetailView({super.key, required this.codigo});

  @override
  State<BienDetailView> createState() => _BienDetailViewState();
}

class _BienDetailViewState extends State<BienDetailView> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _bien;
  bool _loading = true;
  String? _error;
  String? _origen;

  // Nuevos: para las áreas
  List<dynamic> _areas = [];
  int? _idAreaSel;

  // Para los combos Estado y Ubicación
  List<dynamic> _ubicaciones = [];
  List<dynamic> _estados = [];
  int? _idUbicacionSel;
  int? _idEstadoSel;

  @override
  void initState() {
    super.initState();
    _fetchTodo();
  }

  Future<void> _fetchTodo() async {
    await _fetchDetalleBien();
    await _fetchCombos();
  }

  Future<void> _fetchDetalleBien() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await ApiService.getDetalleBien(widget.codigo);

    setState(() {
      _loading = false;
      if (res['success']) {
        _bien = res['bien'];
        _origen = res['origen'];
        _idUbicacionSel = _bien?['idubicacion'];
        _idEstadoSel = _bien?['id_estado_conservacion_bien'];
        // NUEVO: intentar inferir área del bien si tienes ese dato (depende de tu backend)
        _idAreaSel = _bien?['idarea']; // asume que el backend retorna 'idarea' en bien
        print("[DEBUG] Carga de bien: $_bien");
      } else {
        _error = res['message'] ?? 'Bien no encontrado';
      }
    });
  }

  // Nuevo: cargar áreas
  Future<void> _fetchAreas() async {
    final resAreas = await ApiService.getAreas();
    setState(() {
      _areas = resAreas['areas'] ?? [];
      // Si no hay área seleccionada, elige la primera por defecto
      if (_areas.isNotEmpty && _idAreaSel == null) {
        _idAreaSel = _areas[0]['id_area'];
      }
    });
  }

  // Modificado: cargar ubicaciones filtrando por área seleccionada
  Future<void> _fetchUbicacionesPorArea([int? idArea]) async {
    final resUbic = await ApiService.getUbicaciones(idArea ?? _idAreaSel);
    setState(() {
      _ubicaciones = resUbic['ubicaciones'] ?? [];
      if (_ubicaciones.isNotEmpty && _idUbicacionSel == null) {
        _idUbicacionSel = _ubicaciones[0]['id_ubicacion'];
      }
    });
  }

  Future<void> _fetchCombos() async {
    await _fetchAreas();
    await _fetchUbicacionesPorArea();
    final resEst = await ApiService.getEstados();
    setState(() {
      _estados = resEst['estados'] ?? [];
      if (_estados.isNotEmpty && _idEstadoSel == null) {
        _idEstadoSel = _estados[0]['id_estado'];
      }
    });
  }

  Future<void> _guardar() async {
    if (_idUbicacionSel == null || _idEstadoSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione un área, ambiente y un estado"), backgroundColor: Colors.red),
      );
      return;
    }
    final now = DateTime.now();
    final fecha = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final movimientoData = {
      'idbien': _bien?['idbien'],
      'tipo_mvto': 2,
      'fecha_mvto': fecha,
      'detalle_tecnico': null,
      'documento_sustentatorio': null,
      'idubicacion': _idUbicacionSel,
      'id_estado_conservacion_bien': _idEstadoSel,
      'idusuario': Session.idUsuario,
    };

    final camposObligatorios = [
      movimientoData['idbien'],
      movimientoData['tipo_mvto'],
      movimientoData['fecha_mvto'],
      movimientoData['idubicacion'],
      movimientoData['id_estado_conservacion_bien'],
      movimientoData['idusuario'],
    ];
    if (camposObligatorios.any((v) => v == null || (v is String && v.trim().isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos requeridos deben estar seleccionados o disponibles."), backgroundColor: Colors.red),
      );
      return;
    }

    final res = await ApiService.registrarMovimiento(movimientoData);

    if (res['ok']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Movimiento registrado"), backgroundColor: Colors.green),
      );
      await _fetchDetalleBien();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Error'), backgroundColor: Colors.red),
      );
    }
  }

  @override 
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7FE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        appBar: AppBar(
          title: Text("Bien: ${widget.codigo}"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Detalle Bien: ${widget.codigo}", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTodo,
            tooltip: "Recargar datos",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoCard(
                title: "Información General",
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormRow(label: "Código Patrimonial", value: _bien?['codigo_patrimonial'] ?? '', readOnly: true),
                    _FormRow(label: "Denominación", value: _bien?['denominacion_bien'] ?? '', readOnly: true),
                    _FormRow(label: "Tipo de Bien", value: _bien?['nombre_tipo_bien'] ?? '', readOnly: true),
                    _FormRow(label: "Marca", value: _bien?['marca_bien'] ?? '', readOnly: true),
                    _FormRow(label: "Modelo", value: _bien?['modelo_bien'] ?? '', readOnly: true),
                    _FormRow(label: "Serie", value: _bien?['nserie_bien'] ?? '', readOnly: true),
                    _FormRow(label: "Color", value: _bien?['color_bien'] ?? '', readOnly: true),
                    _FormRow(label: "Dimensiones", value: _bien?['dimensiones_bien'] ?? '', readOnly: true),
                    _FormRow(label: "Fecha del último movimiento", value: (_bien?['fecha_mvto'] ?? 'Sin movimientos').toString(), readOnly: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: "Editar ubicación y estado",
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _idAreaSel,
                      items: _areas.map<DropdownMenuItem<int>>((a) =>
                        DropdownMenuItem(
                          value: a['id_area'],
                          child: Text(a['nombre_area']),
                        )).toList(),
                      onChanged: (nuevoArea) {
                        setState(() {
                          _idAreaSel = nuevoArea;
                          _idUbicacionSel = null;
                          _ubicaciones = [];
                        });
                        _fetchUbicacionesPorArea(nuevoArea);
                      },
                      decoration: const InputDecoration(labelText: 'Área', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _idUbicacionSel,
                      items: _ubicaciones.map<DropdownMenuItem<int>>((u) =>
                        DropdownMenuItem(
                          value: u['id_ubicacion'],
                          child: Text("${u['nombre_sede']} - ${u['ambiente']}"),
                        )).toList(),
                      onChanged: (nuevo) => setState(() => _idUbicacionSel = nuevo),
                      decoration: const InputDecoration(labelText: 'Ambiente', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _idEstadoSel,
                      items: _estados.map<DropdownMenuItem<int>>((e) =>
                        DropdownMenuItem(
                          value: e['id_estado'],
                          child: Text(e['nombre_estado']),
                        )).toList(),
                      onChanged: (nuevo) => setState(() => _idEstadoSel = nuevo),
                      decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambio"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (_bien?['foto_bien'] != null && (_bien?['foto_bien'] as String).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Column(
                    children: [
                      const Text(
                        "Foto asociada al bien:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _bien?['foto_bien'] ?? '',
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widgets auxiliares (igual, sin cambios):
class _InfoCard extends StatelessWidget {
  final String title;
  final Widget content;
  const _InfoCard({
    required this.title,
    required this.content,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              content,
            ],
          ),
        ),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final String value;
  final bool readOnly;
  const _FormRow({
    required this.label,
    required this.value,
    this.readOnly = false,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Text(
                value.isEmpty ? 'No disponible' : value,
                style: TextStyle(
                  fontSize: 14,
                  color: readOnly ? Colors.grey[600] : Colors.black87,
                  fontWeight: readOnly ? FontWeight.w400 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

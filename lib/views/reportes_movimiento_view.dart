import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportesMovimientoView extends StatefulWidget {
  const ReportesMovimientoView({super.key});
  @override
  State<ReportesMovimientoView> createState() => _ReportesMovimientoViewState();
}

class _ReportesMovimientoViewState extends State<ReportesMovimientoView> {
  final _searchController = TextEditingController();
  List<dynamic> _movimientos = [];
  bool _loading = true;
  String? _error;

  Future<void> _fetchMovimientos([String? filtro]) async {
    setState(() { _loading = true; });
    final res = await ApiService.getMovimientos(filtro);
    setState(() {
      _movimientos = res['movimientos'] ?? [];
      _loading = false;
      _error = _movimientos.isEmpty ? 'No existen movimientos' : null;
    });
  }

  Future<void> exportMovimientosToPDF(List<dynamic> movimientos) async {
    final pdf = pw.Document();
    final Uint8List logoBytes = await rootBundle
      .load('assets/images/INSIGNIA-ELA-r.png')
      .then((data) => data.buffer.asUint8List());
    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(
  pageFormat: PdfPageFormat.a4,
  build: (pw.Context context) => [
    pw.Stack(
      children: [
        pw.Positioned(
          left: 0,
          top: PdfPageFormat.a4.height * 0.18, // Puedes ajustar la posición
          child: pw.Opacity(
            opacity: 0.1,
            child: pw.Image(
              logoImage,
              width: PdfPageFormat.a4.width * 0.7, // o el tamaño que desees
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
        pw.Column(
          children: [
            pw.Header(level: 0, child: pw.Text('Reporte de Movimientos', style: pw.TextStyle(fontSize: 22))),
            pw.Table.fromTextArray(
              headers: ['Fecha', 'Código', 'Equipo', 'Ubicación', 'Estado', 'Usuario'],
              data: movimientos.map((m) => [
                m['fecha_mvto'] ?? '',
                m['codigo_patrimonial'] ?? '',
                m['denominacion_bien'] ?? '',
                '${m['nombre_sede'] ?? ''} - ${m['ambiente'] ?? ''}',
                m['nombre_estado'] ?? '',
                m['nombre_usuario'] ?? '',
              ]).toList(),
              cellStyle: pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ]
        ),
      ]
    )
  ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'IESTP ENRIQUE LOPEZ ALBUJAR',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                'Fecha: ${DateTime.now().toString().split(".")[0]}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      )
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchMovimientos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Movimientos')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (q) => _fetchMovimientos(q),
                      decoration: const InputDecoration(
                        labelText: 'Buscar Código Patrimonial',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _movimientos.isEmpty ? null : () => exportMovimientosToPDF(_movimientos),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_loading && _movimientos.isEmpty)
              const Expanded(child: Center(child: Text('No se encontraron movimientos'))),
            if (!_loading && _movimientos.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _movimientos.length,
                  itemBuilder: (context, idx) {
                    final m = _movimientos[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${m['codigo_patrimonial']?[0] ?? "-"}')),
                        title: Text(
                          'Equipo: ${m['denominacion_bien'] ?? ""}\nCódigo: ${m['codigo_patrimonial'] ?? ""}'
                        ),
                        subtitle: Text('Fecha: ${m['fecha_mvto'] ?? ""}\nUbicación: ${m['nombre_sede']} - ${m['ambiente']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(m['nombre_estado'] ?? ''),
                            Text(m['nombre_usuario'] ?? '', style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          // Puedes mostrar detalle o acción aquí
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'search_bien_view.dart';
import 'reportes_movimiento_view.dart';


class HomeView extends StatelessWidget {
  final dynamic user;
  const HomeView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?['nombre_usuario'] ?? 'Usuario';
    final dni = user?['dni_usuario'] ?? '';
    final rol = user?['rol_usuario'] ?? 'USUARIO';

    Timer? _inactivityTimer;
    Timer? _warningTimer;

    void _resetTimer() {
      _inactivityTimer?.cancel();
      _warningTimer?.cancel();

      _inactivityTimer = Timer(const Duration(minutes: 5), () {
        int countdown = 30;
        Timer? countdownTimer;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Crear el timer solo una vez al mostrar el dialogo
                if (countdownTimer == null) {
                  countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                    if (countdown > 0) {
                      setState(() => countdown--);
                    } else {
                      timer.cancel();
                      _inactivityTimer?.cancel();
                      _warningTimer?.cancel();
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                  });
                }

                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700], size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sesión Inactiva',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'No has realizado ninguna acción en 5 minutos.',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'La sesión expirará en $countdown segundos.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                countdownTimer?.cancel();
                                Navigator.of(context).pop();
                                _inactivityTimer?.cancel();
                                _warningTimer?.cancel();
                                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red[700],
                                side: BorderSide(color: Colors.red[300]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Cerrar Sesión',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                countdownTimer?.cancel();
                                Navigator.of(context).pop();
                                _resetTimer();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Extender Sesión',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      });
    }


    // ← FUNCIÓN CERRAR SESIÓN DEFINIDA PRIMERO

    // ← FUNCIÓN MOSTRAR ADVERTENCIA DEFINIDA SEGUNDA

    // ← INICIAR TIMER AL CARGAR HOMEVIEW
    _resetTimer();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _resetTimer(); // Reiniciar timer al tocar cualquier cosa
        },
        onPanUpdate: (_) {
          _resetTimer(); // Reiniciar timer al deslizar
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header, perfil y bienvenida
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 34,
                        color: Colors.deepPurple[400],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bienvenido, $name",
                            style: GoogleFonts.poppins(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: Colors.deepPurple[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Text(
                              "DNI $dni   •   $rol",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.deepPurple[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.deepPurple),
                      onPressed: () {
                        _inactivityTimer?.cancel();
                        _warningTimer?.cancel();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),

              // Card gradiente inventario principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5AE0), Color(0xFF5CE6E6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.16),
                        spreadRadius: 2,
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        "GESTIÓN DE INVENTARIO",
                        style: GoogleFonts.poppins(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Opciones principales en grid tipo cards
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 24.0, bottom: 8.0),
                child: Text(
                  "Buscar componente",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple[900],
                  ),
                ),
              ),

              // Cards principales en formato grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    // Escanear QR
                    GestureDetector(
                      onTap: () async {
                        _resetTimer(); // Reiniciar timer
                        
                        print('🔍 DEBUG: Iniciando escaneo QR');
                        
                        final scanResult = await Navigator.pushNamed(context, '/scanner');
                        
                        if (scanResult != null && scanResult is String) {
                          String codigoLeido = scanResult;
                          print('🔍 DEBUG: QR escaneado RAW: "$codigoLeido"');
                          
                          if (codigoLeido.startsWith('http')) {
                            try {
                              final uri = Uri.parse(codigoLeido);
                              print('🔍 DEBUG: URL segments: ${uri.pathSegments}');
                              if (uri.pathSegments.isNotEmpty) {
                                codigoLeido = uri.pathSegments.last;
                                print('🔍 DEBUG: Código extraído: "$codigoLeido"');
                              }
                            } catch (e) {
                              print('❌ DEBUG: Error parseando URL: $e');
                            }
                          }
                          
                          if (codigoLeido.contains('/bien/')) {
                            codigoLeido = codigoLeido.split('/bien/').last;
                            print('🔍 DEBUG: Código después de /bien/: "$codigoLeido"');
                          }
                          
                          print('🚀 DEBUG: Código final enviado: "$codigoLeido"');
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('QR escaneado: $codigoLeido'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          
                          Navigator.pushNamed(context, '/bien_detalle', arguments: codigoLeido);
                        } else {
                          print('⚠️ DEBUG: No se escaneó ningún código QR');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se detectó código QR'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F3FF),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE5F3FF).withOpacity(0.21),
                              blurRadius: 13,
                              offset: const Offset(3, 7),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.21),
                              blurRadius: 7,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFE5F3FF).withOpacity(0.22),
                                          blurRadius: 8,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(Icons.qr_code_scanner, size: 32, color: Colors.deepPurple[600]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Text(
                                "Escanear",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple[900],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "QR del bien",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.deepPurple[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Ingresar Código Manual
                    GestureDetector(
                      onTap: () {
                        _resetTimer(); // Reiniciar timer
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchBienView(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE7EB),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFDE7EB).withOpacity(0.21),
                              blurRadius: 13,
                              offset: const Offset(3, 7),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.21),
                              blurRadius: 7,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFDE7EB).withOpacity(0.22),
                                          blurRadius: 8,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(Icons.edit_note, size: 32, color: Colors.deepPurple[600]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Text(
                                "Ingresar Código",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple[900],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Manual",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.deepPurple[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Reporte
                    GestureDetector(
                      onTap: () {
                        _resetTimer(); // Reiniciar timer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportesMovimientoView(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1E8EA),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD1E8EA).withOpacity(0.21),
                              blurRadius: 13,
                              offset: const Offset(3, 7),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.21),
                              blurRadius: 7,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD1E8EA).withOpacity(0.22),
                                          blurRadius: 8,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(Icons.analytics, size: 32, color: Colors.deepPurple[600]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Text(
                                "Reporte",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple[900],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Ver estadísticas",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.deepPurple[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Ajustes
                    GestureDetector(
                      onTap: () {
                        _resetTimer(); // Reiniciar timer
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función próximamente')),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E6E6),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE6E6E6).withOpacity(0.21),
                              blurRadius: 13,
                              offset: const Offset(3, 7),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.21),
                              blurRadius: 7,
                              offset: const Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFE6E6E6).withOpacity(0.22),
                                          blurRadius: 8,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(Icons.settings, size: 32, color: Colors.deepPurple[600]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Text(
                                "Ajustes",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple[900],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Configuración",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.deepPurple[400],
                                ),
                              ),
                            ],
                          ),
                        ),
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

  void newMethod(void Function(BuildContext context) _showSessionWarning, BuildContext context) => _showSessionWarning(context);
}

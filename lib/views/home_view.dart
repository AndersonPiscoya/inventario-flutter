import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de usuario
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
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),

            // Card gradiente de título de gestión
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

            // Título sección
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

            // Cards principales
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
                      final scanResult = await Navigator.pushNamed(context, '/scanner');
                      if (scanResult != null && scanResult is String) {
                        String codigoLeido = scanResult;
                        if (codigoLeido.startsWith('http')) {
                          try {
                            final uri = Uri.parse(codigoLeido);
                            if (uri.pathSegments.isNotEmpty) {
                              codigoLeido = uri.pathSegments.last;
                            }
                          } catch (_) {}
                        }
                        if (codigoLeido.contains('/bien/')) {
                          codigoLeido = codigoLeido.split('/bien/').last;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('QR escaneado: $codigoLeido'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        Navigator.pushNamed(context, '/bien_detalle', arguments: codigoLeido);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se detectó código QR'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: CardMenu(
                      color: const Color(0xFFE5F3FF),
                      icon: Icons.qr_code_scanner,
                      title: "Escanear",
                      subtitle: "QR del bien",
                    ),
                  ),

                  // Ingresar Código Manual
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchBienView()),
                      );
                    },
                    child: CardMenu(
                      color: const Color(0xFFFDE7EB),
                      icon: Icons.edit_note,
                      title: "Ingresar Código",
                      subtitle: "Manual",
                    ),
                  ),

                  // Reporte movimiento
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReportesMovimientoView()),
                      );
                    },
                    child: CardMenu(
                      color: const Color(0xFFD1E8EA),
                      icon: Icons.analytics,
                      title: "Reporte",
                      subtitle: "Ver estadísticas",
                    ),
                  ),

                  // Ajustes (placeholder)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función próximamente')),
                      );
                    },
                    child: CardMenu(
                      color: const Color(0xFFE6E6E6),
                      icon: Icons.settings,
                      title: "Mantenimiento",
                      subtitle: "Bienes y usuarios",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Puedes mantener tu widget CardMenu reutilizable:
class CardMenu extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const CardMenu({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.21),
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
                        color: color.withOpacity(0.22),
                        blurRadius: 8,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(icon, size: 32, color: Colors.deepPurple[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple[900],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.deepPurple[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with SingleTickerProviderStateMixin {
  bool _found = false;
  bool _isTorchOn = false;
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (_found) return;

    final String? code = barcodeCapture.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      _found = true;
      setState(() {}); // Actualiza UI para mostrar éxito
      // Mostrar feedback breve y cerrar
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, code);
        }
      });
    }
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6A5AE0), // Azul-morado consistente con tu app
                  Color(0xFF5CE6E6),
                ],
              ),
            ),
          ),
          // Vista previa del escáner (ÚNICO MobileScanner - cubre toda la pantalla)
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.contain, // Ajusta el preview automáticamente a la pantalla
            
          ),
          // Overlay UI (superpuesto sobre el scanner, sin duplicados)
          SafeArea(
            child: Column(
              children: [
                // AppBar personalizada
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        tooltip: 'Cerrar',
                      ),
                      Text(
                        'Escanear QR',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleTorch,
                        icon: Icon(
                          _isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
                          color: Colors.white,
                          size: 28,
                        ),
                        tooltip: 'Linterna',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Instrucciones animadas
                      AnimatedOpacity(
                        opacity: _found ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          children: [
                            Text(
                              'Posiciona el código QR en el marco',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Marco del escáner (overlay visual puro - muestra la cámara debajo)
                            Container(
                              width: screenSize.width * 0.7,
                              height: screenSize.width * 0.7,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Stack(
                                  children: [
                                    // Área transparente para mostrar la cámara (sin MobileScanner aquí)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    // Línea de escaneo animada (overlay visual)
                                    AnimatedBuilder(
                                      animation: _scanLineAnimation,
                                      builder: (context, child) {
                                        return Positioned(
                                          top: _scanLineAnimation.value *
                                              (screenSize.width * 0.7),
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 2,
                                            color: Colors.green.withOpacity(0.8),
                                            child: LinearProgressIndicator(
                                              value: null,
                                              backgroundColor: Colors.transparent,
                                              valueColor: const AlwaysStoppedAnimation<Color>(
                                                Colors.green,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Bordes del marco con esquinas transparentes (overlay visual)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: CustomPaint(
                                          painter: ScannerFramePainter(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Mantén estable y bien iluminado',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Estado de éxito
                      AnimatedOpacity(
                        opacity: _found ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 80,
                            ),
                            Text(
                              '¡QR escaneado!',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Painter personalizado para el marco del escáner (bordes visibles, centro transparente)
class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(18),
        ),
      );

    // Dibujar solo los bordes (omitir el centro)
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        path,
        Path()..addRect(Rect.fromLTWH(20, 20, size.width - 40, size.height - 40)),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:async';
import 'package:flutter/material.dart';

class SessionTimeoutService {
  static Timer? _inactivityTimer;
  static Timer? _finalTimer;
  static bool _isRunning = false;

  // Duraciones
  static const Duration inactivityDuration = Duration(minutes: 5); // 5 minutos sin actividad
  static const Duration warningDuration = Duration(seconds: 30); // 30 segundos para extender

  // Stream para notificaciones (opcional)
  static final StreamController<bool> _sessionStream = StreamController<bool>.broadcast();
  static Stream<bool> get sessionStream => _sessionStream.stream;

  // Variables de estado
  static bool get isActive => _isRunning;
  static bool get isWarning => _finalTimer != null;

  // Context estático (usar con cuidado)
  static BuildContext? _context;

  // Inicializar con context
  static void initializeWithContext(BuildContext context) {
    _context = context;
    _startSession();
  }

  // Iniciar timer de sesión
  static void _startSession() {
    _isRunning = true;
    _resetTimer();

    print('SessionTimeout: Timer iniciado - 5 minutos de inactividad');
  }

  // Reiniciar timer al detectar actividad
  static void _resetTimer() {
    _inactivityTimer?.cancel();
    _finalTimer?.cancel();

    _inactivityTimer = Timer(inactivityDuration, _showWarning);
  }

  // Mostrar advertencia de inactividad
  static void _showWarning() {
    if (!_isRunning) return;

    print('SessionTimeout: Mostrando advertencia - 30 segundos para extender');

    if (_context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionWarningDialog();
      });
    }
  }

  // Mostrar dialog de advertencia
  static void _showSessionWarningDialog() {
    if (_context == null) return;

    int countdown = 30;
    Timer? countdownTimer;

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (countdownTimer == null) {
              countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
                if (countdown > 0) {
                  setState(() => countdown--);
                } else {
                  timer.cancel();
                  countdownTimer?.cancel();
                  Navigator.of(context).pop();
                  _logoutUser();
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              elevation: 8,
              title: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange[800],
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sesión Inactiva',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text(
                    'No has realizado ninguna acción en 5 minutos.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'La sesión expirará en $countdown segundos.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          child: OutlinedButton(
                            onPressed: () {
                              _finalTimer?.cancel();
                              Navigator.of(context).pop();
                              _logoutUser();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[700],
                              side: BorderSide(color: Colors.red[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              _finalTimer?.cancel();
                              Navigator.of(context).pop();
                              _extendSession();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Extender Sesión',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                        backgroundColor: Colors.orange[100],
                        value: countdown / 30,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
    });

    // Timer para cerrar sesión automáticamente tras 30 segundos de advertencia
    _finalTimer = Timer(warningDuration, _logoutUser);
  }

  // Extender sesión
  static void _extendSession() {
    _finalTimer?.cancel();
    _resetTimer();

    print('SessionTimeout: Sesión extendida 5 minutos más');
  }

  // Cerrar sesión
  static void _logoutUser() {
    if (!_isRunning) return;

    _isRunning = false;
    _inactivityTimer?.cancel();
    _finalTimer?.cancel();

    print('SessionTimeout: Sesión cerrada por inactividad');

    // Emitir evento para manejar logout en UI
    _sessionStream.add(false);
  }

  // Detectar actividad del usuario
  static void onUserActivity() {
    if (!_isRunning) return;

    _finalTimer?.cancel();
    _resetTimer();
  }

  // Pausar temporariamente
  static void pause() {
    _inactivityTimer?.cancel();
    _finalTimer?.cancel();
    print('SessionTimeout: Pausado temporalmente');
  }

  // Reanudar
  static void resume() {
    if (_isRunning) {
      _resetTimer();
      print('SessionTimeout: Reanudado');
    }
  }

  // Limpiar recursos
  static void dispose() {
    _isRunning = false;
    _inactivityTimer?.cancel();
    _finalTimer?.cancel();
    _sessionStream.close();
    _context = null;
  }
}

// Widget para capturar actividad
class SessionActivityDetector extends StatefulWidget {
  final Widget child;

  const SessionActivityDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SessionActivityDetector> createState() => _SessionActivityDetectorState();
}

class _SessionActivityDetectorState extends State<SessionActivityDetector> {
  late final _observer = _ActivityObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: SessionTimeoutService.onUserActivity,
      onPanUpdate: (_) => SessionTimeoutService.onUserActivity(),
      child: widget.child,
    );
  }
}

class _ActivityObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (SessionTimeoutService.isActive) {
      switch (state) {
        case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
          SessionTimeoutService.pause();
          break;
        case AppLifecycleState.resumed:
          SessionTimeoutService.resume();
          break;
        default:
          break;
      }
    }
  }
}

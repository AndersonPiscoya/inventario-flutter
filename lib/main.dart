// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/scanner_view.dart';
import 'views/bien_detail_view.dart';
import 'services/session_timeout.dart';
import 'views/asignar_ubicacion_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MODIFICACIÓN: envolvemos el MaterialApp en SessionActivityDetector
    return SessionActivityDetector(
      child: MaterialApp(
        title: 'Inventario App',
        theme: FlexThemeData.light(
          scheme: FlexScheme.blue,
          appBarStyle: FlexAppBarStyle.background,
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.blue,
          appBarStyle: FlexAppBarStyle.background,
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginView(),
          '/home': (context) {
            final user = ModalRoute.of(context)?.settings.arguments;
            return HomeView(user: user);
          },
          '/scanner': (context) => const ScannerView(),
          '/bien_detalle': (context) {
            final codigo = ModalRoute.of(context)!.settings.arguments as String;
            return BienDetailView(codigo: codigo);
          },
        },
      ),
    );
  }
}

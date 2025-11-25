// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';       // Para SocketException, HandshakeException
import 'dart:async';    // Para TimeoutException


class ApiService {
  // Base URL del backend Node.js (tu IP local o pública)
static const String _baseUrl = 'https://web-production-84102.up.railway.app';

 // ========== NUEVOS MÉTODOS PARA ÁREAS Y UBICACIONES DEPENDIENTES ==========

  // Listar áreas - GET /areas
  static Future<Map<String, dynamic>> getAreas() async {
    try {
      final uri = Uri.parse('$_baseUrl/areas');
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      final data = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'data': data,
        'ok': response.statusCode == 200 && data['ok'] == true,
        'areas': data['areas'],
        'total': data['total']
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'ok': false,
        'areas': <dynamic>[],
        'message': 'Error al listar áreas: $e'
      };
    }
  }

  // Listar ubicaciones filtrando por área - GET /ubicaciones?id_area=
  static Future<Map<String, dynamic>> getUbicaciones([int? idArea]) async {
    try {
      String url = '$_baseUrl/ubicaciones';
      if (idArea != null) url += '?id_area=$idArea';
      final uri = Uri.parse(url);
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      final data = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'data': data,
        'ok': response.statusCode == 200 && data['ok'] == true,
        'ubicaciones': data['ubicaciones'],
        'total': data['total']
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'ok': false,
        'ubicaciones': <dynamic>[],
        'message': 'Error al listar ubicaciones: $e'
      };
    }
  }


  // ========== AUTENTICACIÓN ==========

  // Login - POST /auth/login
  static Future<Map<String, dynamic>> login({
  required String dni,
  required String clave,
}) async {
  try {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'dni': dni.trim(),
            'clave': clave,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final bodyString = response.body;

    Map<String, dynamic> data;

    // Intentar decodificar JSON
    try {
      data = jsonDecode(bodyString);
    } catch (_) {
      // Si el servidor responde HTML, texto o basura
      data = {
        'ok': false,
        'message': bodyString.isEmpty
            ? 'Respuesta vacía del servidor'
            : 'Respuesta no JSON: $bodyString'
      };
    }

    return {
      'statusCode': response.statusCode,
      'data': data,
      'success': response.statusCode == 200 && data['ok'] == true,
      'user': data['user'],
      'message': data['message'] ?? 'Respuesta sin mensaje',
    };
  }

    // MANEJO DETALLADO DE ERRORES
    on HandshakeException catch (e, stack) {
      return {
        'statusCode': 0,
        'success': false,
        'user': null,
        'message': 'Error SSL: ${e.toString()}',
        'data': {
          'ok': false,
          'errorType': 'SSL_ERROR',
          'message': 'Error SSL: ${e.toString()}',
          'stack': stack.toString(),
        }
      };
    }
    on SocketException catch (e, stack) {
      return {
        'statusCode': 0,
        'success': false,
        'user': null,
        'message': 'Error de red: ${e.message}',
        'data': {
          'ok': false,
          'errorType': 'NETWORK_ERROR',
          'message': e.message,
          'stack': stack.toString(),
        }
      };
    }

    on TimeoutException catch (e, stack) {
      return {
        'statusCode': 0,
        'success': false,
        'user': null,
        'message': 'Timeout: El servidor no respondió',
        'data': {
          'ok': false,
          'errorType': 'TIMEOUT',
          'message': 'Timeout: $e',
          'stack': stack.toString(),
        }
      };
    }

    catch (e, stack) {
      // Error desconocido
      return {
        'statusCode': 0,
        'success': false,
        'user': null,
        'message': 'Excepción: $e',
        'data': {
          'ok': false,
          'errorType': 'UNKNOWN',
          'message': e.toString(),
          'stack': stack.toString(),
        }
      };
    }
  }


  // ========== GESTIÓN DE BIENES ==========

  // Obtener bien por código patrimonial - GET /bien/:codigo
  static Future<Map<String, dynamic>> getBien(String codigo) async {
    try {
      final uri = Uri.parse('$_baseUrl/bien/$codigo');
      print('🔍 DEBUG: Intentando conectar a: $uri');
      print('🔍 DEBUG: Base URL: $_baseUrl');
      print('🔍 DEBUG: Código buscando: $codigo');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 DEBUG: Status recibido: ${response.statusCode}');
      print('📡 DEBUG: Response body: ${response.body}');
      
      final data = jsonDecode(response.body);
      
      return {
        'statusCode': response.statusCode,
        'data': data,
        'success': response.statusCode == 200 && data['ok'] == true,
        'bien': data['bien'],
        'message': data['message'],
      };
    } catch (e) {
      print('❌ DEBUG ERROR: $e');
      return {
        'statusCode': 0,
        'data': {'ok': false, 'message': 'Error al consultar bien: $e'},
        'success': false,
        'bien': null,
        'message': 'Error al consultar bien',
      };
    }
  }

  // Obtener detalle completo del bien - GET /detalle-bien/:codigo
  static Future<Map<String, dynamic>> getDetalleBien(String codigo) async {
    try {
      final uri = Uri.parse('$_baseUrl/detalle-bien/$codigo');
      print('🔍 DEBUG: Intentando conectar a: $uri');
      print('🔍 DEBUG: Código buscando: $codigo');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('📡 DEBUG: Status recibido: ${response.statusCode}');
      print('📡 DEBUG: Response body: ${response.body}');
      
      final data = jsonDecode(response.body);
      
      return {
        'statusCode': response.statusCode,
        'data': data,
        'success': response.statusCode == 200 && data['ok'] == true,
        'bien': data['bien'],
        'origen': data['origen'], // 'movimiento' o 'bien'
        'message': data['message'],
      };
    } catch (e) {
      print('❌ DEBUG ERROR: $e');
      return {
        'statusCode': 0,
        'data': {'ok': false, 'message': 'Error al consultar detalle: $e'},
        'success': false,
        'bien': null,
        'origen': null,
        'message': 'Error al consultar detalle de bien',
      };
    }
  }

  // Actualizar bien - PUT /bien/:codigo
  static Future<Map<String, dynamic>> updateBien(String codigo, Map<String, dynamic> valores) async {
    try {
      final uri = Uri.parse('$_baseUrl/bien/$codigo');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(valores),
      );

      final data = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'data': data,
        'success': response.statusCode == 200 && data['ok'] == true,
        'bien': data['bien'],
        'message': data['message'],
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'data': {'ok': false, 'message': 'Error al actualizar bien: $e'},
        'success': false,
        'bien': null,
        'message': 'Error al actualizar bien',
      };
    }
  }

  // Listar bienes - GET /bienes (opcional)
  static Future<Map<String, dynamic>> getBienes() async {
    try {
      final uri = Uri.parse('$_baseUrl/bienes');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'data': data,
        'success': response.statusCode == 200 && data['ok'] == true,
        'bienes': data['bienes'],
        'total': data['total'],
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'data': {'ok': false, 'message': 'Error al listar bienes: $e'},
        'success': false,
        'bienes': <dynamic>[],
        'total': 0,
      };
    }
  }


    // ========== NUEVOS MÉTODOS PARA MOVIMIENTOS Y COMBOS ==========
  // Listar estados de bien - GET /estados
  static Future<Map<String, dynamic>> getEstados() async {
    try {
      final uri = Uri.parse('$_baseUrl/estados');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'data': data,
        'success': response.statusCode == 200 && data['ok'] == true,
        'estados': data['estados'],
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'data': {'ok': false, 'message': 'Error al listar estados: $e'},
        'success': false,
        'estados': <dynamic>[],
        'message': 'Error al listar estados',
      };
    }
  }

  // Registrar movimiento - POST /movimiento
  static Future<Map<String, dynamic>> registrarMovimiento(Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_baseUrl/movimiento');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'data': data,
        'ok': response.statusCode == 201 && data['ok'] == true,
        'movimiento': data['movimiento'],
        'message': data['message'],
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'ok': false,
        'movimiento': null,
        'data': {'ok': false, 'message': 'Error registrando movimiento: $e'},
        'message': 'Error registrando movimiento',
      };
    }
  }



  // Listar movimientos - GET /movimientos y filtro por código patrimonial
  static Future<Map<String, dynamic>> getMovimientos([String? codigoPatrimonial]) async {
    try {
      final uri = Uri.parse(
        codigoPatrimonial == null || codigoPatrimonial.isEmpty
          ? '$_baseUrl/movimientos'
          : '$_baseUrl/movimientos?codigo=$codigoPatrimonial'
      );
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      return {
        'statusCode': response.statusCode,
        'data': data,
        'success': response.statusCode == 200 && data['ok'] == true,
        'movimientos': data['movimientos'],
        'total': data['total'],
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'data': {'ok': false, 'message': 'Error al listar movimientos: $e'},
        'success': false,
        'movimientos': <dynamic>[],
        'total': 0,
        'message': 'Error al listar movimientos',
      };
    }
  }


}


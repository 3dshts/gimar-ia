// frontend/lib/src/core/network/json_sender.dart

import 'package:dio/dio.dart';
import './dio_client.dart';
import './api_logger.dart';

/// Clase auxiliar para enviar JSON a endpoints externos (Make, webhooks, etc.).
///
/// El token JWT se incluye automáticamente gracias al interceptor de DioClient.
/// Este método es reutilizable en cualquier formulario con botón de envío.
class JsonSender {
  /// Envía un [payload] JSON al [endpoint] especificado.
  /// 
  /// El token JWT se añade automáticamente en el header si existe.
  /// 
  /// Ejemplo de uso:
  /// ```dart
  /// await JsonSender.sendToMake(
  ///   {'nombre': 'Juan', 'edad': 30},
  ///   endpoint: 'url destino',
  /// );
  /// ```
  /// 
  /// Lanza [DioException] si la petición falla.
  static Future<void> sendToMake(
    Map<String, dynamic> payload, {
    required String endpoint,
  }) async {
    try {
      ApiLogger.info('Sending JSON to: $endpoint', 'JSON_SENDER');
      ApiLogger.debug('Payload: $payload', 'JSON_SENDER');

      final dio = DioClient.instance;
      final response = await dio.post(endpoint, data: payload);

      ApiLogger.info(
        'JSON sent successfully (HTTP ${response.statusCode})',
        'JSON_SENDER',
      );
    } on DioException catch (e) {
      ApiLogger.error(
        'Failed to send JSON to $endpoint',
        'JSON_SENDER',
        e,
      );
      rethrow;
    }
  }
}
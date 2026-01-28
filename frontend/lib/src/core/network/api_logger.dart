// frontend/lib/src/core/network/api_logger.dart

import 'api_config.dart';

/// Sistema de logging para la API con diferentes niveles.
/// 
/// Solo muestra logs en modo debug (dev/staging).
/// En producción, los logs se omiten automáticamente.
class ApiLogger {
  /// Prefijo para identificar logs de la API.
  static const String _prefix = '[API]';

  /// Log de nivel DEBUG (detalles técnicos).
  /// 
  /// Usa para información detallada durante el desarrollo.
  /// Solo visible en modo debug.
  static void debug(String message, [String? tag]) {
    if (ApiConfig.isDebug) {
      final tagStr = tag != null ? '[$tag]' : '';
      print('$_prefix [DEBUG] $tagStr $message');
    }
  }

  /// Log de nivel INFO (información general).
  /// 
  /// Usa para eventos importantes pero normales.
  /// Solo visible en modo debug.
  static void info(String message, [String? tag]) {
    if (ApiConfig.isDebug) {
      final tagStr = tag != null ? '[$tag]' : '';
      print('$_prefix [INFO] $tagStr $message');
    }
  }

  /// Log de nivel WARNING (advertencias).
  /// 
  /// Usa para situaciones inesperadas pero recuperables.
  /// Solo visible en modo debug.
  static void warning(String message, [String? tag]) {
    if (ApiConfig.isDebug) {
      final tagStr = tag != null ? '[$tag]' : '';
      print('$_prefix [WARNING] $tagStr $message');
    }
  }

  /// Log de nivel ERROR (errores).
  /// 
  /// Usa para errores que requieren atención.
  /// Visible en TODOS los entornos (incluyendo producción).
  static void error(String message, [String? tag, Object? error]) {
    final tagStr = tag != null ? '[$tag]' : '';
    print('$_prefix [ERROR] $tagStr $message');
    if (error != null) {
      print('$_prefix [ERROR] Details: $error');
    }
  }

  // ============================================
  // Helpers especializados para casos comunes
  // ============================================

  /// Log para inicio de subida de archivo.
  static void uploadStart(String filename, String endpoint) {
    info('Starting upload: $filename → $endpoint', 'UPLOAD');
  }

  /// Log para progreso de subida.
  static void uploadProgress(String filename, int sent, int total) {
    final percentage = ((sent / total) * 100).toStringAsFixed(1);
    debug('Upload progress: $filename → $percentage% ($sent/$total bytes)', 'UPLOAD');
  }

  /// Log para subida exitosa.
  static void uploadSuccess(String filename, int statusCode) {
    info('Upload successful: $filename (HTTP $statusCode)', 'UPLOAD');
  }

  /// Log para error en subida.
  static void uploadError(String filename, Object error, [int? statusCode]) {
    final status = statusCode != null ? ' (HTTP $statusCode)' : '';
    ApiLogger.error('Upload failed: $filename$status', 'UPLOAD', error);
  }

  /// Log para peticiones HTTP generales.
  static void request(String method, String endpoint) {
    debug('$method $endpoint', 'REQUEST');
  }

  /// Log para respuestas HTTP exitosas.
  static void response(String endpoint, int statusCode, [dynamic data]) {
    info('Response: $endpoint → HTTP $statusCode', 'RESPONSE');
    if (data != null) {
      debug('Response data: $data', 'RESPONSE');
    }
  }

  /// Log para errores de peticiones HTTP.
  static void requestError(String endpoint, Object error, [int? statusCode]) {
    final status = statusCode != null ? ' (HTTP $statusCode)' : '';
    ApiLogger.error('Request failed: $endpoint$status', 'REQUEST', error);
  }

  /// Muestra información del entorno al iniciar.
  static void logEnvironmentInfo() {
    info('='.padRight(50, '='));
    info('Environment: ${ApiConfig.environmentName}');
    info('Base URL: ${ApiConfig.baseUrl}');
    info('Debug Mode: ${ApiConfig.isDebug}');
    info('='.padRight(50, '='));
  }
}
// frontend/lib/src/core/network/api_config.dart

/// Configuración de la API según el entorno.
/// 
/// Para cambiar entre entornos, modifica [currentEnvironment].
class ApiConfig {
  /// Entorno actual de la aplicación.
  /// 
  /// Cambia este valor para alternar entre desarrollo y producción.
  static const Environment currentEnvironment = Environment.prod;

  /// URL base según el entorno configurado.
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.dev:
        return _devBaseUrl;
      case Environment.prod:
        return _prodBaseUrl;
    }
  }

  /// URL de desarrollo (localhost).
  static const String _devBaseUrl = 'http://localhost:3000';

  /// URL de producción (AWS Lambda).
  static const String _prodBaseUrl =
      'https://xg7e6zon8f.execute-api.eu-central-1.amazonaws.com';

  /// Indica si estamos en modo debug (desarrollo).
  static bool get isDebug => currentEnvironment == Environment.dev;

  /// Indica si estamos en producción.
  static bool get isProduction => currentEnvironment == Environment.prod;

  /// Nombre del entorno actual (útil para logs).
  static String get environmentName {
    switch (currentEnvironment) {
      case Environment.dev:
        return 'Development';
      case Environment.prod:
        return 'Production';
    }
  }
}

/// Entornos disponibles para la aplicación.
enum Environment {
  /// Entorno de desarrollo local.
  dev,

  /// Entorno de producción.
  prod,
}

/// Timeouts para las peticiones HTTP.
class ApiTimeouts {
  /// Timeout para establecer la conexión.
  static const Duration connect = Duration(seconds: 20);

  /// Timeout para recibir la respuesta.
  static const Duration receive = Duration(seconds: 60);

  /// Timeout para enviar datos.
  static const Duration send = Duration(seconds: 60);
}

/// Endpoints de la API organizados por módulo.
///
/// Nota: Esta clase también se exporta como [ApiEndpoints] para
/// mantener compatibilidad con código existente.
class ApiEndpoints {
  /// ============================================
  // Autenticación
  // ============================================

  /// Valida un token JWT.
  static const String validateToken = '/api/auth/validate-token';

  /// Endpoint de login de usuarios.
  static const String login = '/api/auth/login';

  // ============================================
  // Administración
  // ============================================

  /// Obtiene todos los usuarios.
  static const String getAllUsers = '/api/admin/users';

  /// Obtiene logs del sistema con paginación.
  static const String getAllLogs = '/api/admin/logs';

  // ============================================
  // Google Drive - Uploads
  // ============================================

  /// Sube una imagen de alerta a Google Drive.
  static const String uploadImgAlert = '/api/google/uploadImgAlert';

  /// Sube un archivo Excel de prototipo.
  static const String uploadPrototypeExcel = '/api/google/uploadPrototypeExcel';

  /// Sube un PDF de pedido.
  static const String uploadPedidoPdf = '/api/google/uploadPedidoPDF';

  /// Sube múltiples archivos Excel de nóminas.
  static const String uploadNominasExcels = '/api/google/uploadNominasExcels';

  /// Sube múltiples PDFs de Intrastat.
  static const String uploadIntrastatPdf = '/api/google/uploadIntrastatPDF';

  /// Sube múltiples PDFs de Inventario.
  static const String uploadInventarioPdf= '/api/google/uploadInventarioPDF';

  // Sube multiples archivos de Situacion Pedidos Versace.
  static const String uploadSituacionVersace = '/api/google/uploadSituacionVersace';

  // Sube multiples archivos de Situacion Pedidos SW.
  static const String uploadSituacionSW = '/api/google/uploadSituacionSW';


  // ============================================
  // Endpoints de APIs externas
  // ============================================
  
  // Obtiene las notas de producción del ERP externo.
  static const String getNotasProduccion = '/api/external/notas_produccion';


   // ============================================
  // Google Calendar - Comentarios
  // ============================================

  /// Lista comentarios de calendario en un rango de fechas.
  static const String getCalendarComments = '/api/calendar/comments';

  /// Crea un nuevo comentario en el calendario.
  static const String createCalendarComment = '/api/calendar/comments';

  /// Actualiza un comentario existente.
  /// Requiere el eventId en la URL: /api/calendar/comments/{eventId}
  static String updateCalendarComment(String eventId) => '/api/calendar/comments/$eventId';

  /// Elimina un comentario del calendario.
  /// Requiere el eventId en la URL: /api/calendar/comments/{eventId}
  static String deleteCalendarComment(String eventId) => '/api/calendar/comments/$eventId';
}
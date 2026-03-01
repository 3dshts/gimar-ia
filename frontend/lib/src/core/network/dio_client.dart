// frontend/lib/src/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';

import './api_config.dart';
import './api_logger.dart';
import './file_upload_helper.dart';

/// Tamaño máximo por lote de archivos (8 MB).
const int _maxBatchSizeBytes = 4 * 1024 * 1024;

/// Cliente HTTP centralizado para todas las peticiones de la API.
///
/// Configurado con:
/// - Autenticación JWT automática mediante interceptor
/// - Timeouts configurados según el entorno
/// - Logging inteligente (solo en debug)
/// - Base URL dinámica según entorno (dev/staging/prod)
class DioClient {
  /// Almacenamiento seguro para el token JWT.
  static const _storage = FlutterSecureStorage();

  /// Instancia única de Dio (Singleton).
  static final Dio _dio = _createDioInstance();

  /// Crea y configura la instancia de Dio.
  static Dio _createDioInstance() {
    ApiLogger.logEnvironmentInfo();

    return Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: Duration.zero,
          receiveTimeout: Duration.zero,
          sendTimeout: Duration.zero,
        ),
      )
      ..interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest: _onRequest,
          onResponse: _onResponse,
          onError: _onError,
        ),
      );
  }

  /// Interceptor: Se ejecuta antes de cada petición.
  static Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Añadir token JWT si existe
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    ApiLogger.request(options.method, options.path);
    handler.next(options);
  }

  /// Interceptor: Se ejecuta después de cada respuesta exitosa.
  static void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    ApiLogger.response(
      response.requestOptions.path,
      response.statusCode ?? 0,
      response.data,
    );
    handler.next(response);
  }

  /// Interceptor: Se ejecuta cuando ocurre un error.
  static void _onError(DioException error, ErrorInterceptorHandler handler) {
    ApiLogger.requestError(
      error.requestOptions.path,
      error,
      error.response?.statusCode,
    );
    handler.next(error);
  }

  /// Getter para acceder a la instancia de Dio pre-configurada.
  static Dio get instance => _dio;

  // ============================================
  // Métodos de Autenticación
  // ============================================

  /// Valida un token JWT con el backend.
  static Future<Response> validateTokenWith(String token) async {
    ApiLogger.info('Validating JWT token', 'AUTH');
    return _dio.get(
      ApiEndpoints.validateToken,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // ============================================
  // Métodos de Administración
  // ============================================

  /// Obtiene la lista de todos los usuarios.
  static Future<Response> getAllUsers() async {
    ApiLogger.info('Fetching all users', 'ADMIN');
    return _dio.get(ApiEndpoints.getAllUsers);
  }

  /// Obtiene los logs del sistema con paginación.
  static Future<Response> getAllLogs({int page = 1, int limit = 20}) async {
    ApiLogger.info('Fetching logs: page=$page, limit=$limit', 'ADMIN');
    return _dio.get(
      ApiEndpoints.getAllLogs,
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  // ============================================
  // Métodos de Subida de Archivos
  // ============================================

  /// Sube una imagen de alerta a Google Drive.
  static Future<Response> uploadImgAlert({
    required PlatformFile file,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      ApiLogger.uploadStart(file.name, ApiEndpoints.uploadImgAlert);

      final formData = await FileUploadHelper.createFormDataSingleFile(
        file: file,
        fieldName: 'file',
      );

      final response = await _dio.post(
        ApiEndpoints.uploadImgAlert,
        data: formData,
        onSendProgress: onSendProgress,
      );

      ApiLogger.uploadSuccess(file.name, response.statusCode ?? 0);
      return response;
    } catch (e) {
      ApiLogger.uploadError(file.name, e);
      rethrow;
    }
  }

  /// Sube un archivo Excel de prototipo como binario.
  static Future<Response> uploadPrototypeExcel({
    required PlatformFile file,
    required String marca,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      ApiLogger.uploadStart(file.name, ApiEndpoints.uploadPrototypeExcel);

      // Validar que sea Excel
      FileUploadHelper.validateExtensions([file], ['xlsx', 'xls', 'xlsm']);

      final formData = await FileUploadHelper.createFormDataSingleFile(
        file: file,
        fieldName: 'file',
        additionalFields: {'marca': marca},
      );

      // Hacer POST con los bytes
      final response = await _dio.post(
        ApiEndpoints.uploadPrototypeExcel,
        data: formData,
        onSendProgress: onSendProgress,
      );

      ApiLogger.uploadSuccess(file.name, response.statusCode ?? 0);
      return response;
    } catch (e) {
      ApiLogger.uploadError(file.name, e);
      rethrow;
    }
  }

  /// Sube un archivo PDF de pedido a Google Drive.
  static Future<Response> uploadPedidoPdf({
    required PlatformFile file,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      ApiLogger.uploadStart(file.name, ApiEndpoints.uploadPedidoPdf);

      // Validar que sea PDF
      FileUploadHelper.validateSingleExtension(file, 'pdf');

      final formData = await FileUploadHelper.createFormDataSingleFile(
        file: file,
        fieldName: 'file',
      );

      final response = await _dio.post(
        ApiEndpoints.uploadPedidoPdf,
        data: formData,
        onSendProgress: onSendProgress,
      );

      ApiLogger.uploadSuccess(file.name, response.statusCode ?? 0);
      return response;
    } catch (e) {
      ApiLogger.uploadError(file.name, e);
      rethrow;
    }
  }

  /// Sube múltiples archivos Excel de nóminas a Google Drive.
  static Future<Response> uploadExcelsNomina({
    required PlatformFile archivoResumen,
    required List<PlatformFile> archivosDetalle1,
    required List<PlatformFile> archivosDetalle2,
    required String anio,
    required String mes,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      ApiLogger.uploadStart(
        'Nóminas: ${1 + archivosDetalle1.length + archivosDetalle2.length} archivos',
        ApiEndpoints.uploadNominasExcels,
      );

      // Validar que todos sean Excel
      FileUploadHelper.validateExtensions(
        [archivoResumen, ...archivosDetalle1, ...archivosDetalle2],
        ['xlsx', 'xls', 'xlsm'],
      );

      ApiLogger.debug('Año: $anio, Mes: $mes', 'UPLOAD');
      ApiLogger.debug(
        'Resumen: 1, Detalle1: ${archivosDetalle1.length}, '
            'Detalle2: ${archivosDetalle2.length}',
        'UPLOAD',
      );

      final formData = await FileUploadHelper.createFormDataWithGroups(
        fileGroups: {
          'archivoResumen': archivoResumen,
          'archivosDetalle1': archivosDetalle1,
          'archivosDetalle2': archivosDetalle2,
        },
        additionalFields: {'anio': anio, 'mes': mes},
      );

      final response = await _dio.post(
        ApiEndpoints.uploadNominasExcels,
        data: formData,
        onSendProgress: onSendProgress,
      );

      ApiLogger.uploadSuccess('Nóminas', response.statusCode ?? 0);
      return response;
    } catch (e) {
      ApiLogger.uploadError('Nóminas', e);
      rethrow;
    }
  }

  /// Sube múltiples archivos PDF de Intrastat a Google Drive.
  static Future<Response> uploadMultiplePedidoPdfs({
    required List<PlatformFile> files,
    required String marca,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      ApiLogger.uploadStart(
        'Intrastat: ${files.length} PDFs',
        ApiEndpoints.uploadIntrastatPdf,
      );

      // Validar que todos sean PDF
      FileUploadHelper.validateExtensions(files, ['pdf']);

      final formData = await FileUploadHelper.createFormDataMultipleFiles(
        files: files,
        fieldName: 'files',
        additionalFields: {'marca': marca},
      );

      final response = await _dio.post(
        ApiEndpoints.uploadIntrastatPdf,
        data: formData,
        onSendProgress: onSendProgress,
      );

      ApiLogger.uploadSuccess('Intrastat PDFs', response.statusCode ?? 0);
      return response;
    } catch (e) {
      ApiLogger.uploadError('Intrastat PDFs', e);
      rethrow;
    }
  }

  /// Sube múltiples archivos PDF de Inventario a Google Drive.
  /// Divide automáticamente en lotes de máximo 4 MB.
  static Future<Map<String, dynamic>> uploadInventarioPdfs({
    required List<PlatformFile> files,
    void Function(int sent, int total)? onSendProgress,
    void Function(int completados, int total)? onBatchProgress,
  }) async {
    // Validar que todos sean PDF
    FileUploadHelper.validateExtensions(files, ['pdf']);

    // Validar que ningún archivo individual supere el límite
    final archivosGrandes = files
        .where((f) => (f.size) > _maxBatchSizeBytes)
        .toList();
    if (archivosGrandes.isNotEmpty) {
      final nombres = archivosGrandes.map((f) => f.name).join(', ');
      throw Exception('Archivos superan 8 MB: $nombres');
    }

    // Dividir en lotes
    final lotes = _dividirEnLotes(files);
    ApiLogger.info('Dividido en ${lotes.length} lote(s)', 'UPLOAD');

    // Acumuladores de resultados
    final todosExitosos = <Map<String, dynamic>>[];
    final todosFallidos = <Map<String, dynamic>>[];

    int archivosEnviados = 0;
    final totalArchivos = files.length;

    // Enviar cada lote secuencialmente
    for (int i = 0; i < lotes.length; i++) {
      final lote = lotes[i];
      ApiLogger.info(
        'Enviando lote ${i + 1}/${lotes.length}: ${lote.length} archivo(s)',
        'UPLOAD',
      );

      final formData = await FileUploadHelper.createFormDataMultipleFiles(
        files: lote,
        fieldName: 'files',
      );

      final response = await _dio.post(
        ApiEndpoints.uploadInventarioPdf,
        data: formData,
        onSendProgress: onSendProgress,
      );

      // Acumular resultados
      final data = response.data as Map<String, dynamic>;
      final exitosos = data['exitosos'] as List? ?? [];
      final fallidos = data['fallidos'] as List? ?? [];

      todosExitosos.addAll(exitosos.cast<Map<String, dynamic>>());
      todosFallidos.addAll(fallidos.cast<Map<String, dynamic>>());

      archivosEnviados += lote.length;
      onBatchProgress?.call(archivosEnviados, totalArchivos);
    }

    return {'exitosos': todosExitosos, 'fallidos': todosFallidos};
  }

  /// Divide archivos en lotes que no superen el límite de tamaño.
  static List<List<PlatformFile>> _dividirEnLotes(List<PlatformFile> files) {
    final lotes = <List<PlatformFile>>[];
    var loteActual = <PlatformFile>[];
    var tamanoActual = 0;

    for (final file in files) {
      final tamanoArchivo = file.size;

      if (tamanoActual + tamanoArchivo > _maxBatchSizeBytes &&
          loteActual.isNotEmpty) {
        lotes.add(loteActual);
        loteActual = [];
        tamanoActual = 0;
      }

      loteActual.add(file);
      tamanoActual += tamanoArchivo;
    }

    if (loteActual.isNotEmpty) {
      lotes.add(loteActual);
    }

    return lotes;
  }

  /// Sube 4 archivos para Situación de Pedidos Versace a Google Drive.
  /// - 1 PDF: Informe Fechas
  /// - 3 Excel: DIRMA, Informe Pasado, Informe Nuevo
  static Future<Response> uploadExcelSituacionVersace({
    required PlatformFile informeFechas,
    required PlatformFile dirma,
    required PlatformFile informePasado,
    required PlatformFile informeNuevo,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      ApiLogger.uploadStart(
        'Situación Versace: 4 archivos',
        ApiEndpoints.uploadSituacionVersace,
      );

      // Validar tipos de archivo
      FileUploadHelper.validateSingleExtension(informeFechas, 'pdf');
      FileUploadHelper.validateExtensions(
        [dirma, informePasado, informeNuevo],
        ['xlsx', 'xls', 'xlsm'],
      );

      ApiLogger.debug('Informe Fechas: ${informeFechas.name}', 'UPLOAD');
      ApiLogger.debug('DIRMA: ${dirma.name}', 'UPLOAD');
      ApiLogger.debug('Informe Pasado: ${informePasado.name}', 'UPLOAD');
      ApiLogger.debug('Informe Nuevo: ${informeNuevo.name}', 'UPLOAD');

      // Crear FormData con los 4 archivos
      final formData = FormData();

      // Añadir PDF Informe Fechas
      formData.files.add(
        MapEntry(
          'informeFechas',
          MultipartFile.fromBytes(
            informeFechas.bytes!,
            filename: informeFechas.name,
          ),
        ),
      );

      // Añadir Excel DIRMA
      formData.files.add(
        MapEntry(
          'dirma',
          MultipartFile.fromBytes(dirma.bytes!, filename: dirma.name),
        ),
      );

      // Añadir Excel Informe Pasado
      formData.files.add(
        MapEntry(
          'informePasado',
          MultipartFile.fromBytes(
            informePasado.bytes!,
            filename: informePasado.name,
          ),
        ),
      );

      // Añadir Excel Informe Nuevo
      formData.files.add(
        MapEntry(
          'informeNuevo',
          MultipartFile.fromBytes(
            informeNuevo.bytes!,
            filename: informeNuevo.name,
          ),
        ),
      );

      final response = await _dio.post(
        ApiEndpoints.uploadSituacionVersace,
        data: formData,
        onSendProgress: onSendProgress,
      );

      ApiLogger.uploadSuccess('Situación Versace', response.statusCode ?? 0);
      return response;
    } catch (e) {
      ApiLogger.uploadError('Situación Versace', e);
      rethrow;
    }
  }

  /// Sube archivos para Situación de Pedidos Stuart Weitzman a Google Drive.
  /// - Múltiples PDFs: ERP SUSY
  /// - 1 Excel: Planning Cliente
  static Future<Response> uploadExcelSituacionSW({
    required List<PlatformFile> erpSusy,
    required PlatformFile planningCliente,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      ApiLogger.uploadStart(
        'Situación SW: ${erpSusy.length} PDFs + 1 Excel',
        ApiEndpoints.uploadSituacionSW,
      );

      // Validar tipos de archivo
      FileUploadHelper.validateExtensions(erpSusy, ['pdf']);
      FileUploadHelper.validateExtensions(
        [planningCliente],
        ['xlsx', 'xls', 'xlsm'],
      );

      ApiLogger.debug('ERP SUSY: ${erpSusy.length} archivos', 'UPLOAD');
      ApiLogger.debug('Planning Cliente: ${planningCliente.name}', 'UPLOAD');

      // Crear FormData
      final formData = FormData();

      // Añadir múltiples PDFs de ERP SUSY
      for (final pdf in erpSusy) {
        formData.files.add(
          MapEntry(
            'erpSusy',
            MultipartFile.fromBytes(pdf.bytes!, filename: pdf.name),
          ),
        );
      }

      // Añadir Excel Planning Cliente
      formData.files.add(
        MapEntry(
          'planningCliente',
          MultipartFile.fromBytes(
            planningCliente.bytes!,
            filename: planningCliente.name,
          ),
        ),
      );

      final response = await _dio.post(
        ApiEndpoints.uploadSituacionSW,
        data: formData,
        onSendProgress: onSendProgress,
      );

      ApiLogger.uploadSuccess('Situación SW', response.statusCode ?? 0);
      return response;
    } catch (e) {
      ApiLogger.uploadError('Situación SW', e);
      rethrow;
    }
  }

  // ============================================
  // Métodos de APIs Externas
  // ============================================

  /// Obtiene las notas de producción desde el ERP externo.
  /// Realiza la consulta con los filtros especificados y retorna todos los registros.
  static Future<Response> getNotasProduccion({
    required String fechaDesde,
    required String fechaHasta,
    required String seccion,
    required String temporada,
  }) async {
    ApiLogger.info(
      'Fetching notas producción: $fechaDesde - $fechaHasta, Sección: $seccion, Temporada: $temporada',
      'EXTERNAL_API',
    );

    return _dio.post(
      ApiEndpoints.getNotasProduccion,
      data: {
        'fechaDesde': fechaDesde,
        'fechaHasta': fechaHasta,
        'seccion': seccion,
        'temporada': temporada,
      },
    );
  }

  // ============================================
  // Métodos de Google Calendar
  // ============================================

  /// Obtiene comentarios de calendario en un rango de fechas.
  static Future<Response> getCalendarComments({
    required String startDate,
    required String endDate,
  }) async {
    ApiLogger.info(
      'Fetching calendar comments: $startDate - $endDate',
      'CALENDAR',
    );

    return _dio.get(
      ApiEndpoints.getCalendarComments,
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );
  }

  /// Crea un nuevo comentario en el calendario.
  static Future<Response> createCalendarComment({
    required String fecha,
    required String titulo,
    required String comentario,
    required String autorId,
    required String autorNombre,
  }) async {
    ApiLogger.info('Creating calendar comment: $titulo on $fecha', 'CALENDAR');

    return _dio.post(
      ApiEndpoints.createCalendarComment,
      data: {
        'fecha': fecha,
        'titulo': titulo,
        'comentario': comentario,
        'autorId': autorId,
        'autorNombre': autorNombre,
      },
    );
  }

  /// Actualiza un comentario existente.
  static Future<Response> updateCalendarComment({
    required String eventId,
    required String titulo,
    required String comentario,
  }) async {
    ApiLogger.info('Updating calendar comment: $eventId', 'CALENDAR');

    return _dio.put(
      ApiEndpoints.updateCalendarComment(eventId),
      data: {'titulo': titulo, 'comentario': comentario},
    );
  }

  /// Elimina un comentario del calendario.
  static Future<Response> deleteCalendarComment({
    required String eventId,
  }) async {
    ApiLogger.info('Deleting calendar comment: $eventId', 'CALENDAR');

    return _dio.delete(ApiEndpoints.deleteCalendarComment(eventId));
  }
}

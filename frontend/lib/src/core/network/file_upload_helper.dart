// frontend/lib/src/core/network/file_upload_helper.dart

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'mime_helper.dart';
import 'api_logger.dart';

/// Helper para manejar la subida de archivos de manera consistente.
/// 
/// Centraliza la lógica de validación, conversión a MultipartFile
/// y manejo de errores comunes en la subida de archivos.
class FileUploadHelper {
  /// Crea un MultipartFile desde un PlatformFile.
  /// 
  /// Maneja automáticamente la diferencia entre Web (bytes) y
  /// plataformas nativas (path).
  static Future<MultipartFile> createMultipartFile(
    PlatformFile file,
  ) async {
    final mime = MimeHelper.fromExtension(file.extension);

    ApiLogger.debug(
      'Creating multipart file: ${file.name} (${file.extension}) - '
      'Size: ${file.size} bytes - MIME: $mime',
      'FILE_UPLOAD',
    );

    // En Web, usar bytes (obligatorio)
    if (file.bytes != null) {
      return MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
        contentType: MediaType.parse(mime),
      );
    }

    // En plataformas nativas, usar path
    if (file.path != null) {
      return MultipartFile.fromFile(
        file.path!,
        filename: file.name,
        contentType: MediaType.parse(mime),
      );
    }

    throw FileUploadException(
      'El archivo ${file.name} no tiene bytes ni ruta disponible. '
      'Asegúrate de usar withData: true en FilePicker.',
    );
  }

  /// Crea múltiples MultipartFiles desde una lista de PlatformFiles.
  static Future<List<MultipartFile>> createMultipartFiles(
    List<PlatformFile> files,
  ) async {
    final multipartFiles = <MultipartFile>[];

    for (final file in files) {
      final multipartFile = await createMultipartFile(file);
      multipartFiles.add(multipartFile);
    }

    return multipartFiles;
  }

  /// Valida que todos los archivos tengan las extensiones permitidas.
  /// 
  /// Lanza una excepción si algún archivo no cumple.
  static void validateExtensions(
    List<PlatformFile> files,
    List<String> allowedExtensions,
  ) {
    for (final file in files) {
      final extension = file.extension?.toLowerCase();

      if (extension == null || !allowedExtensions.contains(extension)) {
        throw FileUploadException(
          'Extensión no permitida: ${file.name}. '
          'Extensiones permitidas: ${allowedExtensions.join(", ")}',
        );
      }
    }
  }

  /// Valida que un archivo tenga una extensión específica.
  static void validateSingleExtension(
    PlatformFile file,
    String requiredExtension,
  ) {
    final extension = file.extension?.toLowerCase();

    if (extension != requiredExtension.toLowerCase()) {
      throw FileUploadException(
        'El archivo debe ser $requiredExtension. '
        'Archivo recibido: ${file.name} ($extension)',
      );
    }
  }

  /// Valida que los archivos no excedan un tamaño máximo (en MB).
  static void validateFileSize(
    List<PlatformFile> files,
    double maxSizeMB,
  ) {
    final maxBytes = maxSizeMB * 1024 * 1024;

    for (final file in files) {
      if (file.size > maxBytes) {
        throw FileUploadException(
          'El archivo ${file.name} excede el tamaño máximo permitido '
          '(${maxSizeMB}MB). Tamaño: ${(file.size / 1024 / 1024).toStringAsFixed(2)}MB',
        );
      }
    }
  }

  /// Crea un FormData con un único archivo.
  static Future<FormData> createFormDataSingleFile({
    required PlatformFile file,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
  }) async {
    final formData = FormData();

    // Agregar archivo
    final multipartFile = await createMultipartFile(file);
    formData.files.add(MapEntry(fieldName, multipartFile));

    // Agregar campos adicionales
    if (additionalFields != null) {
      for (final entry in additionalFields.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value.toString()));
      }
    }

    return formData;
  }

  /// Crea un FormData con múltiples archivos.
  static Future<FormData> createFormDataMultipleFiles({
    required List<PlatformFile> files,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
  }) async {
    final formData = FormData();

    // Agregar archivos
    for (final file in files) {
      final multipartFile = await createMultipartFile(file);
      formData.files.add(MapEntry(fieldName, multipartFile));
    }

    // Agregar campos adicionales
    if (additionalFields != null) {
      for (final entry in additionalFields.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value.toString()));
      }
    }

    return formData;
  }

  /// Crea un FormData con grupos de archivos (para casos complejos como nóminas).
  static Future<FormData> createFormDataWithGroups({
    required Map<String, dynamic> fileGroups,
    Map<String, dynamic>? additionalFields,
  }) async {
    final formData = FormData();

    // Agregar grupos de archivos
    for (final entry in fileGroups.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      if (value is PlatformFile) {
        // Archivo único
        final multipartFile = await createMultipartFile(value);
        formData.files.add(MapEntry(fieldName, multipartFile));
      } else if (value is List<PlatformFile>) {
        // Lista de archivos
        for (final file in value) {
          final multipartFile = await createMultipartFile(file);
          formData.files.add(MapEntry(fieldName, multipartFile));
        }
      }
    }

    // Agregar campos adicionales
    if (additionalFields != null) {
      for (final entry in additionalFields.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value.toString()));
      }
    }

    return formData;
  }

  /// Calcula el porcentaje de progreso de subida.
  static double calculateProgress(int sent, int total) {
    if (total == 0) return 0.0;
    return (sent / total) * 100;
  }

  /// Formatea el tamaño de archivo en formato legible (KB, MB, GB).
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
    }
  }
}

/// Excepción personalizada para errores de subida de archivos.
class FileUploadException implements Exception {
  final String message;

  FileUploadException(this.message);

  @override
  String toString() => 'FileUploadException: $message';
}
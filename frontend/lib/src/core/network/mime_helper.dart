// frontend/lib/src/core/network/mime_helper.dart

/// Helper para detectar MIME types basándose en la extensión del archivo.
class MimeHelper {
  /// Mapa de extensiones a MIME types.
  static const Map<String, String> _mimeTypes = {
    // Imágenes
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'heif': 'image/heif',
    'gif': 'image/gif',
    'bmp': 'image/bmp',
    'svg': 'image/svg+xml',

    // Excel
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'xls': 'application/vnd.ms-excel',
    'xlsm': 'application/vnd.ms-excel.sheet.macroEnabled.12',
    'xltx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
    'xltm': 'application/vnd.ms-excel.template.macroEnabled.12',

    // Word
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'doc': 'application/msword',

    // PDF
    'pdf': 'application/pdf',

    // Texto
    'txt': 'text/plain',
    'csv': 'text/csv',
    'json': 'application/json',
    'xml': 'application/xml',

    // Comprimidos
    'zip': 'application/zip',
    'rar': 'application/x-rar-compressed',
    '7z': 'application/x-7z-compressed',
  };

  /// Obtiene el MIME type basándose en la extensión del archivo.
  /// 
  /// Retorna 'application/octet-stream' si la extensión no es reconocida.
  static String fromExtension(String? extension) {
    if (extension == null || extension.isEmpty) {
      return 'application/octet-stream';
    }

    final ext = extension.toLowerCase().replaceAll('.', '');
    return _mimeTypes[ext] ?? 'application/octet-stream';
  }

  /// Verifica si una extensión es de imagen.
  static bool isImage(String? extension) {
    if (extension == null) return false;
    final ext = extension.toLowerCase().replaceAll('.', '');
    return const ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', 'gif', 'bmp']
        .contains(ext);
  }

  /// Verifica si una extensión es de Excel.
  static bool isExcel(String? extension) {
    if (extension == null) return false;
    final ext = extension.toLowerCase().replaceAll('.', '');
    return const ['xlsx', 'xls', 'xlsm', 'xltx', 'xltm'].contains(ext);
  }

  /// Verifica si una extensión es PDF.
  static bool isPdf(String? extension) {
    if (extension == null) return false;
    return extension.toLowerCase().replaceAll('.', '') == 'pdf';
  }

  /// Obtiene extensiones permitidas por categoría.
  static List<String> getAllowedExtensions(FileCategory category) {
    switch (category) {
      case FileCategory.images:
        return ['jpg', 'jpeg', 'png', 'webp', 'heic'];
      case FileCategory.excel:
        return ['xlsx', 'xls', 'xlsm'];
      case FileCategory.pdf:
        return ['pdf'];
      case FileCategory.documents:
        return ['pdf', 'docx', 'doc', 'xlsx', 'xls'];
      case FileCategory.all:
        return _mimeTypes.keys.toList();
    }
  }
}

/// Categorías de archivos predefinidas.
enum FileCategory {
  /// Solo imágenes (jpg, png, webp, etc.)
  images,

  /// Solo archivos Excel
  excel,

  /// Solo archivos PDF
  pdf,

  /// Documentos en general (PDF, Word, Excel)
  documents,

  /// Todos los tipos de archivo
  all,
}
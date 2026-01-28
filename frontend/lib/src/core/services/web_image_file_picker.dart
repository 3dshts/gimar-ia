// frontend/lib/src/core/services/web_image_file_picker.dart

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:js_util' as js_util;

import '../files/picked_file_data.dart';
import '../network/api_logger.dart';

/// Utilidades específicas de Flutter Web para captura de imágenes.
/// 
/// Proporciona dos métodos principales:
/// - [pickImageFromCameraWeb]: Abre la cámara del dispositivo (móvil)
/// - [pickImageFromFilesWeb]: Abre el selector de archivos estándar
/// 
/// Nota: Estos métodos solo funcionan en Flutter Web.
/// El atributo 'capture="environment"' sugiere usar la cámara trasera
/// en móviles, pero no todos los navegadores lo soportan.

/// Abre la cámara del dispositivo para capturar una imagen.
/// 
/// En dispositivos móviles con navegadores compatibles (Chrome, Safari),
/// intenta abrir la cámara trasera directamente. En escritorio o
/// navegadores sin soporte, abrirá el selector de archivos como fallback.
/// 
/// Retorna [PickedFileData] si el usuario captura/selecciona una imagen,
/// o `null` si cancela la operación.
Future<PickedFileData?> pickImageFromCameraWeb() async {
  ApiLogger.debug('Opening camera for image capture', 'WEB_FILE_PICKER');

  final input = html.FileUploadInputElement();
  input.accept = 'image/*';

  // Suggest rear camera on mobile devices
  // Not guaranteed by all browsers, but works on Chrome/Safari mobile
  js_util.setProperty(input, 'capture', 'environment');

  return _waitForSingleFile(input);
}

/// Abre el selector de archivos del sistema para elegir una imagen.
/// 
/// [allowedExtensions] especifica las extensiones permitidas.
/// Si es null o vacío, acepta cualquier tipo de imagen.
/// 
/// Ejemplo:
/// ```dart
/// final file = await pickImageFromFilesWeb(
///   allowedExtensions: ['jpg', 'png', 'webp'],
/// );
/// ```
/// 
/// Retorna [PickedFileData] si el usuario selecciona un archivo,
/// o `null` si cancela la operación.
Future<PickedFileData?> pickImageFromFilesWeb({
  List<String>? allowedExtensions,
}) async {
  ApiLogger.debug(
    'Opening file picker with extensions: ${allowedExtensions ?? "all images"}',
    'WEB_FILE_PICKER',
  );

  final input = html.FileUploadInputElement();
  input.accept = _buildAcceptFromExtensions(allowedExtensions);

  return _waitForSingleFile(input);
}

/// Construye el atributo 'accept' del input desde una lista de extensiones.
/// 
/// Ejemplo: ['jpg', 'png'] → '.jpg,.png'
String _buildAcceptFromExtensions(List<String>? extensions) {
  if (extensions == null || extensions.isEmpty) {
    return 'image/*';
  }

  // Build list like ".jpg,.jpeg,.png"
  final acceptList = extensions
      .map((ext) => ext.trim().toLowerCase())
      .where((ext) => ext.isNotEmpty)
      .map((ext) => ext.startsWith('.') ? ext : '.$ext')
      .toSet()
      .toList();

  return acceptList.join(',');
}

/// Espera a que el usuario seleccione un archivo y lo lee como bytes.
/// 
/// Maneja el ciclo completo:
/// 1. Adjunta el input al DOM (oculto)
/// 2. Dispara el diálogo de selección
/// 3. Lee el archivo seleccionado
/// 4. Limpia el input del DOM
Future<PickedFileData?> _waitForSingleFile(
  html.FileUploadInputElement input,
) {
  final completer = Completer<PickedFileData?>();

  input.multiple = false;

  // Attach to DOM (hidden)
  input.style.display = 'none';
  html.document.body?.append(input);

  void cleanup() {
    ApiLogger.debug('Cleaning up file input element', 'WEB_FILE_PICKER');
    input.remove();
  }

  input.onChange.listen((_) async {
    try {
      // User cancelled or no file selected
      if (input.files == null || input.files!.isEmpty) {
        ApiLogger.debug('User cancelled file selection', 'WEB_FILE_PICKER');
        cleanup();
        completer.complete(null);
        return;
      }

      final file = input.files!.first;
      ApiLogger.debug(
        'File selected: ${file.name} (${file.size} bytes)',
        'WEB_FILE_PICKER',
      );

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoad.first;

      // Handle different result types across browsers
      final result = reader.result;
      late Uint8List bytes;

      if (result is Uint8List) {
        bytes = result;
      } else {
        final buffer = result as ByteBuffer;
        bytes = buffer.asUint8List();
      }

      ApiLogger.debug(
        'File read successfully: ${bytes.length} bytes',
        'WEB_FILE_PICKER',
      );

      cleanup();

      completer.complete(
        PickedFileData(
          name: file.name,
          bytes: bytes,
          mimeType: file.type,
          extension: _extractExtension(file.name),
        ),
      );
    } catch (e) {
      ApiLogger.error(
        'Error reading file',
        'WEB_FILE_PICKER',
        e,
      );
      cleanup();
      completer.completeError(e);
    }
  });

  // Trigger the file dialog
  input.click();

  return completer.future;
}

/// Extrae la extensión de un nombre de archivo.
/// 
/// Ejemplo: 'photo.jpg' → 'jpg'
/// Retorna null si el archivo no tiene extensión.
String? _extractExtension(String filename) {
  final dotIndex = filename.lastIndexOf('.');

  if (dotIndex < 0) {
    return null;
  }

  return filename.substring(dotIndex + 1).toLowerCase();
}
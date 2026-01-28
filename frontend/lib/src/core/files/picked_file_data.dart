// frontend/lib/src/core/files/picked_file_data.dart
//
// Modelo interno para unificar la lectura desde <input type=file> (Web)
// y convertirlo a PlatformFile sin romper tu pipeline.

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class PickedFileData {
  final String name;
  final Uint8List bytes;
  final String? mimeType;

  /// Guardamos la extensión aquí si te resulta útil en tu lógica,
  /// pero OJO: PlatformFile la deduce del 'name', no se pasa en el constructor.
  final String? extension;

  const PickedFileData({
    required this.name,
    required this.bytes,
    this.mimeType,
    this.extension,
  });

  PlatformFile toPlatformFile() => PlatformFile(
        name: name,
        bytes: bytes,
        size: bytes.lengthInBytes,
        // extension: extension, // <- ❌ NO existe como parámetro del constructor
        path: null, // En Web no hay path local
      );
}

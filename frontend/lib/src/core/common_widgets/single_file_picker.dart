// frontend/lib/src/core/common_widgets/single_file_picker.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'helpers/responsive_helper.dart';
import 'file_picker_button.dart';
import '../services/web_image_file_picker.dart';
import '../files/picked_file_data.dart';

/// Selector de un único archivo con soporte de cámara en Flutter Web.
/// 
/// Características:
/// - En móvil (Web): muestra BottomSheet con opciones de cámara o galería
/// - En escritorio: abre directamente el selector de archivos
/// - Soporta validación visual con borde rojo y mensaje de error
/// - Maneja estados habilitado/deshabilitado
class SingleFilePicker extends StatelessWidget {
  const SingleFilePicker({
    super.key,
    required this.label,
    required this.iconAssetPath,
    required this.allowedExtensions,
    required this.selectedFile,
    required this.onFileSelected,
    this.errorText,
    this.enableCameraOnMobile = true,
    this.enabled = true,
  });

  /// Etiqueta/título del campo.
  final String label;

  /// Ruta del asset del icono SVG/PNG opcional.
  final String? iconAssetPath;

  /// Extensiones de archivo permitidas (sin punto). Ejemplo: ['jpg', 'png']
  final List<String> allowedExtensions;

  /// Archivo actualmente seleccionado (puede ser null).
  final PlatformFile? selectedFile;

  /// Callback ejecutado cuando el usuario selecciona un archivo.
  final void Function(PlatformFile) onFileSelected;

  /// Mensaje de error opcional. Si se proporciona, activa el estilo de error.
  final String? errorText;

  /// Habilita la UI de cámara en dispositivos móviles (solo Web).
  final bool enableCameraOnMobile;

  /// Determina si el selector está habilitado para interacción.
  final bool enabled;

  /// Verifica si se deben ofrecer opciones de cámara en la UI.
  /// 
  /// Retorna true solo si:
  /// - Estamos en Web
  /// - El dispositivo es móvil
  /// - Las extensiones permitidas son solo de imágenes
  /// - La funcionalidad de cámara está habilitada
  bool _shouldOfferCameraUI(BuildContext context) {
    if (!kIsWeb) return false;
    
    final isMobile = ResponsiveHelper.isMobile(context);
    final onlyImages = allowedExtensions
        .map((e) => e.toLowerCase())
        .every((e) => ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(e));
    
    return enableCameraOnMobile && isMobile && onlyImages;
  }

  /// Selecciona un archivo desde el sistema de archivos (Web).
  /// 
  /// Usa un picker personalizado con fallback a FilePicker si falla.
  Future<void> _pickFromFilesWeb(BuildContext context) async {
    try {
      final PickedFileData? picked = await pickImageFromFilesWeb(
        allowedExtensions: allowedExtensions,
      );
      
      if (picked == null) return;
      onFileSelected(picked.toPlatformFile());
    } catch (e) {
      // Fallback a FilePicker estándar si falla el picker personalizado
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        onFileSelected(result.files.first);
      } else {
        _showSnackBar(context, 'No se pudo seleccionar el archivo.');
      }
    }
  }

  /// Captura una imagen desde la cámara (Web).
  /// 
  /// Utiliza getUserMedia bajo el capó para acceder a la cámara del navegador.
  Future<void> _pickFromCameraWeb(BuildContext context) async {
    try {
      final PickedFileData? picked = await pickImageFromCameraWeb();
      
      if (picked == null) return;
      onFileSelected(picked.toPlatformFile());
    } catch (_) {
      _showSnackBar(
        context,
        'Cámara no disponible en este navegador/dispositivo.',
      );
    }
  }

  /// Muestra un SnackBar con un mensaje de error o información.
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Maneja la acción principal del botón.
  /// 
  /// Decide entre mostrar opciones de cámara/galería o abrir
  /// directamente el selector de archivos según el contexto.
  Future<void> _onPressed(BuildContext context) async {
    if (!kIsWeb) {
      // Fallback para plataformas nativas (móvil/desktop)
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        onFileSelected(result.files.first);
      }
      return;
    }

    if (_shouldOfferCameraUI(context)) {
      // Móvil (Web): mostrar BottomSheet con opciones
      await _showCameraOptionsBottomSheet(context);
    } else {
      // Escritorio (Web): selector de archivos directo
      await _pickFromFilesWeb(context);
    }
  }

  /// Muestra un BottomSheet con opciones de cámara y galería.
  Future<void> _showCameraOptionsBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Hacer foto (cámara)'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _pickFromCameraWeb(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Subir imagen (archivos/galería)'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _pickFromFilesWeb(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelResponsive(isMobile),
        ),
        const SizedBox(height: AppSpacing.small),
        FilePickerButton(
          onPressed: enabled ? () => _onPressed(context) : null,
          buttonText: _shouldOfferCameraUI(context)
              ? 'Hacer foto o seleccionar imagen'
              : 'Seleccionar archivo',
          iconAssetPath: iconAssetPath,
          hasError: hasError,
          enabled: enabled,
        ),
        const SizedBox(height: AppSpacing.small),
        if (selectedFile != null)
          Text(
            selectedFile!.name,
            style: AppTextStyles.body,
          ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTextStyles.error,
          ),
        ],
      ],
    );
  }
}
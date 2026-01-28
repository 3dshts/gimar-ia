// frontend/lib/src/core/common_widgets/multi_file_group_picker.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'helpers/responsive_helper.dart';
import 'file_picker_button.dart';

/// Widget reutilizable para seleccionar un grupo de archivos relacionados.
///
/// Características:
/// - Permite seleccionar múltiples archivos (PDF, Excel, etc.)
/// - Muestra el nombre del grupo y la cantidad/lista de archivos seleccionados
/// - Devuelve los archivos al padre mediante [onFilesSelected]
/// - Soporta validación visual con borde rojo y mensaje de error
class MultiFileGroupPicker extends StatelessWidget {
  const MultiFileGroupPicker({
    super.key,
    required this.groupTitle,
    required this.iconAssetPath,
    required this.allowedExtensions,
    required this.selectedFiles,
    required this.onFilesSelected,
    this.errorText,
  });

  /// Título del grupo mostrado como etiqueta.
  final String groupTitle;

  /// Ruta del asset del icono SVG/PNG que acompaña al botón.
  final String? iconAssetPath;

  /// Extensiones de archivo permitidas (sin punto). Ejemplo: ['pdf', 'xlsx']
  final List<String> allowedExtensions;

  /// Lista de archivos actualmente seleccionados.
  final List<PlatformFile> selectedFiles;

  /// Callback ejecutado cuando el usuario selecciona archivos.
  /// Recibe la lista completa de archivos seleccionados.
  final void Function(List<PlatformFile>) onFilesSelected;

  /// Mensaje de error opcional. Si se proporciona, activa el estilo de error.
  final String? errorText;

  /// Abre el selector nativo de archivos del sistema operativo.
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true, // Necesario en Web para obtener file.bytes
    );

    if (result != null && result.files.isNotEmpty) {
      onFilesSelected(result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          groupTitle,
          style: AppTextStyles.labelResponsive(isMobile),
        ),
        const SizedBox(height: AppSpacing.small),
        FilePickerButton(
          onPressed: _pickFiles,
          buttonText: 'Seleccionar archivos',
          iconAssetPath: iconAssetPath,
          hasError: hasError,
        ),
        const SizedBox(height: AppSpacing.small),
        if (selectedFiles.isNotEmpty)
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.xs,
            children: selectedFiles
                .map(
                  (file) => Chip(
                    label: Text(
                      file.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    backgroundColor: AppColors.cardBorder.withOpacity(0.3),
                  ),
                )
                .toList(),
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
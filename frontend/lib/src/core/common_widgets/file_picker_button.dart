// frontend/lib/src/core/common_widgets/file_picker_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'helpers/responsive_helper.dart';
import 'helpers/error_border_helper.dart';

/// Botón reutilizable para selección de archivos con estilo consistente.
/// 
/// Diseñado para ser usado en componentes de selección de archivos,
/// proporciona:
/// - Estilos consistentes responsive (mobile/desktop)
/// - Manejo visual de errores con borde rojo
/// - Soporte para iconos SVG opcionales
/// - Estado habilitado/deshabilitado
class FilePickerButton extends StatelessWidget {
  const FilePickerButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.iconAssetPath,
    this.hasError = false,
    this.enabled = true,
  });

  /// Callback ejecutado cuando se presiona el botón.
  final VoidCallback? onPressed;

  /// Texto mostrado en el botón.
  final String buttonText;

  /// Ruta del asset del icono SVG/PNG opcional.
  final String? iconAssetPath;

  /// Indica si el botón debe mostrar estado de error (borde rojo).
  final bool hasError;

  /// Determina si el botón está habilitado para interacción.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      decoration: ErrorBorderHelper.buildErrorBorder(hasError),
      child: SizedBox(
        width: double.infinity,
        height: isMobile 
            ? AppButtonHeights.mobile 
            : AppButtonHeights.desktop,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? AppColors.primary : AppColors.text,
            foregroundColor: AppColors.lightText,
            textStyle: const TextStyle(
              fontWeight: AppFontWeights.semiBold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            elevation: AppElevation.none,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconAssetPath != null) ...[
                SvgPicture.asset(
                  iconAssetPath!,
                  width: AppIconSizes.medium,
                  height: AppIconSizes.medium,
                  colorFilter: const ColorFilter.mode(
                    AppColors.lightText,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
              ],
              Text(buttonText),
            ],
          ),
        ),
      ),
    );
  }
}
// frontend/lib/src/core/common_widgets/primary_button.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'helpers/responsive_helper.dart';

/// Botón principal reutilizable de la aplicación.
///
/// Características:
/// - Aplica automáticamente colores corporativos (primario)
/// - Texto en mayúsculas por defecto
/// - Altura responsive (mobile/desktop)
/// - Estado de carga con spinner integrado
/// - Width completo por defecto
///
/// Ejemplo de uso:
/// ```dart
/// PrimaryButton(
///   text: 'Enviar datos',
///   onPressed: () => print('Enviando...'),
/// )
/// ```
///
/// Con estado de carga:
/// ```dart
/// PrimaryButton(
///   text: 'Enviar datos',
///   onPressed: enviarCallback,
///   isLoading: true,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  /// Texto mostrado dentro del botón (se convierte a mayúsculas).
  final String text;

  /// Callback ejecutado cuando se presiona el botón.
  /// 
  /// Se desactiva automáticamente cuando [isLoading] es true.
  final VoidCallback onPressed;

  /// Indica si el botón está en estado de carga.
  /// 
  /// Cuando es true:
  /// - Desactiva el botón (onPressed no se ejecuta)
  /// - Muestra un CircularProgressIndicator
  /// - Oculta el texto
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return SizedBox(
      width: double.infinity,
      height: isMobile 
          ? AppButtonHeights.mobile 
          : AppButtonHeights.desktop,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.lightText,
          textStyle: AppTextStyles.buttonText(isMobile),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: AppProgressIndicator.size,
                height: AppProgressIndicator.size,
                child: CircularProgressIndicator(
                  strokeWidth: AppProgressIndicator.strokeWidth,
                  color: AppColors.lightText,
                ),
              )
            : Text(text.toUpperCase()),
      ),
    );
  }
}
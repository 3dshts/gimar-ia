// frontend/lib/src/core/common_widgets/confirmation_dialog.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dialog de confirmación reutilizable para acciones destructivas.
///
/// Muestra un mensaje de confirmación con dos botones:
/// - Cancelar (outlined)
/// - Confirmar (filled, color personalizable)
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = 'Cancelar',
    this.confirmColor,
    this.icon,
  });

  /// Título del dialog.
  final String title;

  /// Mensaje descriptivo de la acción.
  final String message;

  /// Texto del botón de confirmación.
  final String confirmText;

  /// Callback ejecutado al confirmar.
  final VoidCallback onConfirm;

  /// Texto del botón de cancelar.
  final String cancelText;

  /// Color del botón de confirmación (por defecto: error).
  final Color? confirmColor;

  /// Icono opcional mostrado en el header.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 400.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) _buildIcon(),
              _buildTitle(),
              const SizedBox(height: AppSpacing.medium),
              _buildMessage(),
              const SizedBox(height: AppSpacing.xl),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Icono del dialog.
  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: (confirmColor ?? AppColors.error).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40.0,
        color: confirmColor ?? AppColors.error,
      ),
    );
  }

  /// Título del dialog.
  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppFontSizes.large,
        fontWeight: AppFontWeights.bold,
        color: AppColors.text,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Mensaje del dialog.
  Widget _buildMessage() {
    return Text(
      message,
      style: TextStyle(
        fontSize: AppFontSizes.medium,
        color: AppColors.text.withOpacity(0.8),
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Botones de acción.
  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: BorderSide(
                color: AppColors.cardBorder,
                width: AppBorderWidth.normal,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.medium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
            ),
            child: Text(cancelText),
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.error,
              foregroundColor: AppColors.lightText,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.medium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
            ),
            child: Text(confirmText),
          ),
        ),
      ],
    );
  }

  /// Método estático para mostrar el dialog fácilmente.
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    String cancelText = 'Cancelar',
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
  }
}
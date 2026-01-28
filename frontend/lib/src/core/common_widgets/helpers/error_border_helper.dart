// frontend/lib/src/core/common_widgets/helpers/error_border_helper.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Helper para crear decoraciones de error consistentes.
/// 
/// Centraliza la lógica de bordes rojos para componentes en estado de error,
/// garantizando estilos uniformes en toda la aplicación.
class ErrorBorderHelper {
  /// Crea una decoración de borde de error si [hasError] es verdadero.
  /// 
  /// Retorna `null` si no hay error, permitiendo usar el operador ??
  /// para aplicar decoraciones alternativas.
  static BoxDecoration? buildErrorBorder(bool hasError) {
    if (!hasError) return null;

    return BoxDecoration(
      border: Border.all(
        color: AppColors.error,
        width: AppBorderWidth.thin,
      ),
      borderRadius: BorderRadius.circular(AppBorderRadius.small),
    );
  }

  /// Crea un borde de error con radio de borde personalizado.
  static BoxDecoration? buildErrorBorderWithRadius({
    required bool hasError,
    required double radius,
  }) {
    if (!hasError) return null;

    return BoxDecoration(
      border: Border.all(
        color: AppColors.error,
        width: AppBorderWidth.thin,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
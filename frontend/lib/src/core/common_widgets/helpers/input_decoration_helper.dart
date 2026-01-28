// frontend/lib/src/core/common_widgets/helpers/input_decoration_helper.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Helper para crear decoraciones de input consistentes en toda la aplicación.
/// 
/// Centraliza la lógica de bordes, colores y estilos para campos de texto
/// y dropdowns, evitando duplicación de código entre diferentes componentes.
class InputDecorationHelper {
  /// Crea un borde para inputs con el color y ancho especificados.
  static OutlineInputBorder createBorder({
    required Color color,
    double width = AppBorderWidth.thin,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.small),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Crea una decoración completa para campos de texto.
  /// 
  /// Incluye todos los estados de borde (normal, focused, error) y
  /// estilos consistentes para hint text, relleno y colores.
  /// 
  /// [hintText] es opcional para soportar dropdowns que no necesitan hint.
  /// [isDense] hace el campo más compacto (útil para dropdowns).
  static InputDecoration buildDecoration({
    String? hintText,
    String? errorText,
    bool isDense = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintText != null ? AppTextStyles.inputHint : null,
      filled: true,
      fillColor: AppColors.inputBackground,
      isDense: isDense,
      contentPadding: AppPadding.inputField,
      border: createBorder(color: AppColors.cardBorder),
      enabledBorder: createBorder(color: AppColors.cardBorder),
      focusedBorder: createBorder(
        color: AppColors.primary,
        width: AppBorderWidth.normal,
      ),
      errorBorder: createBorder(color: AppColors.error),
      focusedErrorBorder: createBorder(
        color: AppColors.error,
        width: AppBorderWidth.normal,
      ),
      errorText: errorText,
    );
  }

  /// Crea una decoración específica para dropdowns.
  /// 
  /// Wrapper conveniente de [buildDecoration] con isDense activado
  /// y sin hintText, que es el caso común para dropdowns.
  static InputDecoration buildDropdownDecoration({
    String? errorText,
  }) {
    return buildDecoration(
      isDense: true,
      errorText: errorText,
    );
  }
}
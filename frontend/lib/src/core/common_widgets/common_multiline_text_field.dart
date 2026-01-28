// frontend/lib/src/core/common_widgets/common_multiline_text_field.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'helpers/input_decoration_helper.dart';

/// Campo de texto multilínea reutilizable.
/// 
/// Diseñado para entradas largas como descripciones u observaciones.
/// Soporta validación visual con borde rojo cuando hay errores.
class CommonMultilineTextField extends StatelessWidget {
  const CommonMultilineTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.minLines = 4,
    this.maxLines = 6,
    this.errorText,
  });

  /// Controlador del campo de texto.
  final TextEditingController controller;

  /// Texto indicativo mostrado cuando el campo está vacío.
  final String hintText;

  /// Determina si el campo está habilitado para edición.
  final bool enabled;

  /// Número mínimo de líneas visibles (altura inicial).
  final int minLines;

  /// Número máximo de líneas antes de hacer scroll.
  final int maxLines;

  /// Mensaje de error opcional. Si se proporciona, activa el estilo de error.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      style: AppTextStyles.inputText,
      decoration: InputDecorationHelper.buildDecoration(
        hintText: hintText,
        errorText: errorText,
      ),
    );
  }
}
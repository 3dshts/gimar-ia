// frontend/lib/src/core/common_widgets/common_text_field.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'helpers/input_decoration_helper.dart';

/// Campo de texto de una sola línea con etiqueta independiente.
/// 
/// La etiqueta se muestra encima del campo y no se marca como error
/// cuando hay validación. Solo el input muestra el estado de error.
class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  /// Controlador del campo de texto.
  final TextEditingController controller;

  /// Etiqueta mostrada encima del campo.
  final String label;

  /// Texto indicativo mostrado dentro del campo cuando está vacío.
  final String hintText;

  /// Determina si el campo está habilitado para edición.
  final bool enabled;

  /// Tipo de teclado sugerido para este campo.
  final TextInputType keyboardType;

  /// Mensaje de error opcional. Si se proporciona, activa el estilo de error.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.small),
          child: Text(
            label,
            style: AppTextStyles.label,
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTextStyles.inputText,
          decoration: InputDecorationHelper.buildDecoration(
            hintText: hintText,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
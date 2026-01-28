// frontend/lib/src/core/common_widgets/custom_dropdown.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'helpers/input_decoration_helper.dart';

/// Dropdown reutilizable con etiqueta independiente.
/// 
/// La etiqueta se muestra encima del dropdown y no se marca como error
/// cuando hay validación. Solo el campo muestra el estado de error.
class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.isEnabled = true,
    this.errorText,
  });

  /// Etiqueta mostrada encima del dropdown.
  final String label;

  /// Lista de opciones disponibles en el dropdown.
  final List<String> items;

  /// Valor actualmente seleccionado (puede ser null).
  final String? selectedValue;

  /// Callback ejecutado cuando el usuario selecciona una opción.
  final ValueChanged<String?> onChanged;

  /// Determina si el dropdown está habilitado para interacción.
  final bool isEnabled;

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
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: isEnabled ? onChanged : null,
          decoration: InputDecorationHelper.buildDropdownDecoration(
            errorText: errorText,
          ),
          icon: const Icon(Icons.arrow_drop_down),
          style: AppTextStyles.inputText,
        ),
      ],
    );
  }
}
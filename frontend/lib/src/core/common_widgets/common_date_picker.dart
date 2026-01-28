import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'helpers/input_decoration_helper.dart';
import 'helpers/error_border_helper.dart';

/// Campo de selección de fecha con estilo consistente.
/// 
/// Muestra un TextField que abre un DatePicker al tocar.
class CommonDatePicker extends StatelessWidget {
  const CommonDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.errorText,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });

  /// Etiqueta del campo.
  final String label;

  /// Fecha seleccionada actualmente (puede ser null).
  final DateTime? selectedDate;

  /// Callback cuando se selecciona una fecha.
  final ValueChanged<DateTime?> onDateSelected;

  /// Mensaje de error (null si no hay error).
  final String? errorText;

  /// Si el campo está habilitado.
  final bool enabled;

  /// Fecha mínima seleccionable (por defecto: 1900).
  final DateTime? firstDate;

  /// Fecha máxima seleccionable (por defecto: 2100).
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta
        Text(
          label,
          style: AppTextStyles.label,
        ),
        const SizedBox(height: 6.0),

        // Campo de fecha
        Container(
          decoration: ErrorBorderHelper.buildErrorBorder(hasError),
          child: TextFormField(
            readOnly: true,
            enabled: enabled,
            controller: TextEditingController(
              text: selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                  : '',
            ),
            decoration: InputDecorationHelper.buildDecoration(
              hintText: 'Selecciona una fecha',
              errorText: null, // El error se muestra abajo
            ).copyWith(
              suffixIcon: Icon(
                Icons.calendar_today,
                color: enabled ? AppColors.primary : AppColors.text.withOpacity(0.5),
                size: AppIconSizes.medium,
              ),
            ),
            onTap: enabled ? () => _selectDate(context) : null,
          ),
        ),

        // Mensaje de error
        if (hasError) ...[
          const SizedBox(height: 6.0),
          Text(
            errorText!,
            style: AppTextStyles.error,
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = selectedDate ?? DateTime.now();
    final DateTime firstDateValue = firstDate ?? DateTime(1900);
    final DateTime lastDateValue = lastDate ?? DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDateValue,
      lastDate: lastDateValue,
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        // No necesitas Theme aquí - showDatePicker ya hereda el contexto correcto
        // Solo personaliza si realmente necesitas cambios adicionales
        return child!;
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
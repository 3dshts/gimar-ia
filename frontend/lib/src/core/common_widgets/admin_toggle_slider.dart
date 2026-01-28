// Ruta: frontend/lib/src/core/common_widgets/admin_toggle_slider.dart
// -------------------------------------------------------------------
// Widget tipo “toggle deslizante” para alternar entre dos estados
// (p. ej. Usuario ↔ Historial/Admin). Cambia de color y de icono
// según el estado actual y emite el cambio vía onChanged.
// -------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdminToggleSlider extends StatelessWidget {
  /// Indica si está seleccionada la vista de usuario (true) o la alternativa (false).
  final bool isUserSelected;

  /// Callback que se invoca al pulsar el toggle. Recibe el nuevo estado.
  final void Function(bool) onChanged;

  const AdminToggleSlider({
    super.key,
    required this.isUserSelected,
    required this.onChanged,
  });

  /// Construye el contenedor animado con el "puck" que se alinea a izquierda/derecha.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isUserSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 220,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isUserSelected ? AppColors.primary : AppColors.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment:
                  isUserSelected ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(
                  isUserSelected ? Icons.person : Icons.history,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

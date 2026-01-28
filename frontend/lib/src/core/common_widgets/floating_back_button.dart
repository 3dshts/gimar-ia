// Ruta: frontend/lib/src/core/common_widgets/floating_back_button.dart
// -------------------------------------------------------------------
// Botón “VOLVER” flotante con estilo corporativo. Se posiciona en la
// esquina superior izquierda y navega hacia atrás al pulsar.
// -------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingBackButton extends StatelessWidget {
  const FloatingBackButton({super.key});

  /// Construye el botón posicionado con estilos y tamaños según el layout.
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Positioned(
      top: -7,
      left: -20,
      child: Container(
        margin: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: AppColors.accent,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 20,
              vertical: isMobile ? 8 : 12,
            ),
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
            ),
          ),
          icon: Icon(
            Icons.arrow_back,
            size: isMobile ? 12 : 20,
          ),
          label: Text(
            'VOLVER',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 10 : 14,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

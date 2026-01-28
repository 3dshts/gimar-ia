// frontend/lib/src/features/auth/responsive/responsive_login_layout.dart

import 'package:flutter/material.dart';
import '../../../core/common_widgets/helpers/responsive_helper.dart';
import '../../../core/theme/app_theme.dart';

/// Layout responsive para la pantalla de login.
/// 
/// Comportamiento según tamaño de pantalla:
/// - **Desktop/Tablet**: Muestra ambos widgets lado a lado en un Row
/// - **Móvil**: Muestra ambos widgets apilados verticalmente con scroll
/// 
/// [leftChild] - Widget mostrado a la izquierda (desktop) o arriba (móvil)
/// [rightChild] - Widget mostrado a la derecha (desktop) o abajo (móvil)
class ResponsiveLoginLayout extends StatelessWidget {
  const ResponsiveLoginLayout({
    super.key,
    required this.leftChild,
    required this.rightChild,
  });

  /// Widget del formulario de login (lado izquierdo/arriba).
  final Widget leftChild;

  /// Widget de la imagen de branding (lado derecho/abajo).
  final Widget rightChild;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveHelper.isMobile(context);

        // Layout para desktop/tablet (lado a lado)
        if (!isMobile) {
          return Row(
            children: [
              Expanded(child: leftChild),
              Expanded(child: rightChild),
            ],
          );
        }

        // Layout para móvil (apilado con scroll)
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: LoginLayoutHeights.mobileFormHeight,
                child: leftChild,
              ),
              SizedBox(
                height: LoginLayoutHeights.mobileBrandingHeight,
                child: rightChild,
              ),
            ],
          ),
        );
      },
    );
  }
}
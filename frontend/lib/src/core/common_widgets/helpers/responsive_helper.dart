// frontend/lib/src/core/common_widgets/helpers/responsive_helper.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Helper para manejar lógica responsive de manera consistente.
/// 
/// Centraliza la detección de tamaños de pantalla usando los breakpoints
/// definidos en AppTheme, evitando números mágicos y lógica duplicada.
class ResponsiveHelper {
  /// Determina si el dispositivo actual es móvil.
  /// 
  /// Considera móvil cuando el ancho es menor a [AppBreakpoints.mobile].
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppBreakpoints.mobile;
  }

  /// Determina si el dispositivo actual es tablet.
  /// 
  /// Considera tablet cuando el ancho está entre móvil y desktop.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppBreakpoints.mobile && 
           width < AppBreakpoints.tablet;
  }

  /// Determina si el dispositivo actual es desktop.
  /// 
  /// Considera desktop cuando el ancho es mayor o igual a [AppBreakpoints.tablet].
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppBreakpoints.tablet;
  }

  /// Retorna un valor diferente según el tamaño del dispositivo.
  /// 
  /// Útil para ajustar tamaños, espaciados o cualquier valor numérico
  /// basado en el dispositivo actual.
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}
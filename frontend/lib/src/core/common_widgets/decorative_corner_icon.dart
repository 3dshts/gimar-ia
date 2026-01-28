// Ruta: frontend/lib/src/core/common_widgets/viewport_watermark_widget.dart
// ------------------------------------------------------------------------
// Widget decorativo: pinta un SVG como “marca de agua” fija al viewport,
// por encima/detrás del contenido (sin recibir interacción).
// Útil para reforzar identidad visual en pantallas.
// ------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class ViewportWatermarkWidget extends StatelessWidget {
  /// Contenido principal que se renderiza encima de la marca de agua.
  final Widget child;

  /// Ruta del asset SVG a pintar (p.ej. assets/.../buzon.svg).
  final String asset;

  /// Esquina/posición base donde se alineará el SVG.
  final Alignment alignment;

  /// Desplazamiento adicional para “recortar” o mover el icono.
  final Offset offset;

  /// Opacidad del SVG (0..1).
  final double opacity;

  /// Tamaño relativo del SVG respecto al lado corto del viewport.
  final double sizeFactor;

  /// Si debe respetar el SafeArea superior (AppBar).
  final bool respectTopSafeArea;

  /// Tamaño fijo en píxeles (si se indica, ignora sizeFactor).
  final double? sizePx;

  const ViewportWatermarkWidget({
    super.key,
    required this.child,
    required this.asset,
    this.alignment = Alignment.bottomLeft,
    this.offset = const Offset(-70, 32),
    this.opacity = 0.10,
    this.sizeFactor = 0.5,
    this.sizePx,
    this.respectTopSafeArea = false,
  });

  /// Construye el `Stack` a pantalla completa con el SVG de fondo.
  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    final side = sizePx ?? (s.shortestSide * sizeFactor);
    final safeTop = respectTopSafeArea ? MediaQuery.of(context).padding.top : 0.0;

    return Stack(
      fit: StackFit.expand, // Ocupa todo el viewport
      children: [
        IgnorePointer(
          child: Align(
            alignment: alignment,
            child: Transform.translate(
              offset: offset + Offset(0, safeTop),
              child: Opacity(
                opacity: opacity,
                child: SvgPicture.asset(
                  asset,
                  width: side,
                  height: side,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
        child, // Contenido normal
      ],
    );
  }
}

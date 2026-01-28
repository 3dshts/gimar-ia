// frontend/lib/src/features/dashboard/responsive/responsive_dashboard_grid.dart

import 'package:flutter/material.dart';
import '../../../core/common_widgets/helpers/responsive_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/dashboard_card.dart';

/// Grid responsive para mostrar las tarjetas del dashboard.
/// 
/// Características:
/// - Ajusta automáticamente el número de columnas según el tamaño de pantalla
/// - Efecto de hover: la tarjeta seleccionada crece, las demás se encogen
/// - Animaciones suaves con opacidad y escala
/// 
/// Configuración por dispositivo:
/// - Móvil: 1 columna
/// - Tablet: 2 columnas
/// - Desktop: 3 columnas
class ResponsiveDashboardGrid extends StatefulWidget {
  const ResponsiveDashboardGrid({
    super.key,
    required this.children,
  });

  /// Lista de tarjetas del dashboard a mostrar.
  final List<DashboardCard> children;

  @override
  State<ResponsiveDashboardGrid> createState() =>
      _ResponsiveDashboardGridState();
}

class _ResponsiveDashboardGridState extends State<ResponsiveDashboardGrid> {
  /// Índice de la tarjeta actualmente bajo el mouse (null si ninguna).
  int? _hoveredIndex;

  /// Retorna la configuración del grid según el tamaño de pantalla.
  _GridConfig _getGridConfig(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return const _GridConfig(
        crossAxisCount: DashboardGridConfig.mobileCrossAxisCount,
        childAspectRatio: DashboardGridConfig.mobileChildAspectRatio,
      );
    }

    if (ResponsiveHelper.isTablet(context)) {
      return const _GridConfig(
        crossAxisCount: DashboardGridConfig.tabletCrossAxisCount,
        childAspectRatio: DashboardGridConfig.tabletChildAspectRatio,
      );
    }

    return const _GridConfig(
      crossAxisCount: DashboardGridConfig.desktopCrossAxisCount,
      childAspectRatio: DashboardGridConfig.desktopChildAspectRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getGridConfig(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(DashboardGridConfig.gridPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: config.crossAxisCount,
        crossAxisSpacing: DashboardGridConfig.gridSpacing,
        mainAxisSpacing: DashboardGridConfig.gridSpacing,
        childAspectRatio: config.childAspectRatio,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        final card = widget.children[index];
        final anyHover = _hoveredIndex != null;
        final isHovered = _hoveredIndex == index;

        // Calcular escala según estado de hover
        final targetScale = anyHover
            ? (isHovered
                ? DashboardGridAnimation.hoverScale
                : DashboardGridAnimation.restScale)
            : 1.0;

        // Calcular opacidad según estado de hover
        final targetOpacity = anyHover
            ? (isHovered
                ? DashboardGridAnimation.hoverOpacity
                : DashboardGridAnimation.restOpacity)
            : 1.0;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = null),
          cursor: SystemMouseCursors.click,
          child: AnimatedOpacity(
            duration: DashboardGridAnimation.duration,
            curve: DashboardGridAnimation.curve,
            opacity: targetOpacity,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: targetScale),
              duration: DashboardGridAnimation.duration,
              curve: DashboardGridAnimation.curve,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                alignment: Alignment.center,
                child: child,
              ),
              child: card,
            ),
          ),
        );
      },
    );
  }
}

/// Configuración privada del grid (crossAxisCount y childAspectRatio).
class _GridConfig {
  const _GridConfig({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  final int crossAxisCount;
  final double childAspectRatio;
}
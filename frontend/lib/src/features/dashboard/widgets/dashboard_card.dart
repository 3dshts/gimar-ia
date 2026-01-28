// frontend/lib/src/features/dashboard/widgets/dashboard_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:frontend/src/features/buzon/pages/buzon_page.dart';
import 'package:frontend/src/features/gestion_nominas/pages/gestion_nominas_page.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/common_widgets/helpers/responsive_helper.dart';
import '../../../core/network/api_logger.dart';

// Importar páginas
// import '../../buzon/pages/buzon_page.dart';
// import '../../alertas_produccion/pages/alertas_produccion_page.dart';
// import '../../prototipos/pages/prototipos_page.dart';
// import '../../situacion_pedidos/pages/situacion_pedidos_page.dart';
// import '../../gestion_pedidos/pages/gestion_pedidos_page.dart';
// import '../../gestion_nominas/pages/gestion_nominas_page.dart';
// import '../../intrastat/pages/intrastat_page.dart';
// import '../../inventario/pages/inventario_page.dart';


/// Tarjeta interactiva del dashboard con navegación a diferentes módulos.
/// 
/// Características:
/// - Tamaño responsive según dispositivo
/// - Efecto hover con animación suave
/// - Navegación automática al hacer tap
/// - Ícono SVG personalizable
class DashboardCard extends StatefulWidget {
  const DashboardCard({
    super.key,
    required this.id,
    required this.title,
    required this.iconPath,
  });

  /// Identificador único de la tarjeta (usado para navegación).
  final String? id;

  /// Título visible de la tarjeta.
  final String title;

  /// Ruta del asset del icono SVG.
  final String iconPath;

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  /// Mapa de rutas: asocia cada ID con su página correspondiente.
  static final Map<String, Widget Function()> _routes = {
    'buzon': () => const BuzonPage(),
    'gestion_nominas': () => const GestionNominasPage(),
  };

  /// Maneja la navegación según el ID de la tarjeta.
  void _handleTap(BuildContext context) {
    final id = widget.id;

    if (id == null) {
      ApiLogger.warning('Card tapped but id is null', 'DASHBOARD');
      return;
    }

    final pageBuilder = _routes[id];

    if (pageBuilder != null) {
      ApiLogger.info('Navigating to: $id', 'DASHBOARD');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => pageBuilder()),
      );
    } else {
      ApiLogger.warning('Route not found for id: $id', 'DASHBOARD');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Página no implementada')),
      );
    }
  }

  /// Retorna el tamaño de fuente según el tamaño de pantalla.
  double _getFontSize(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return DashboardCardFontSizes.mobile;
    }
    if (ResponsiveHelper.isTablet(context)) {
      return DashboardCardFontSizes.tablet;
    }
    return DashboardCardFontSizes.desktop;
  }

  /// Retorna el tamaño del icono según el tamaño de pantalla.
  double _getIconSize(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) {
      return DashboardCardIconSizes.mobile;
    }
    if (ResponsiveHelper.isTablet(context)) {
      return DashboardCardIconSizes.tablet;
    }
    return DashboardCardIconSizes.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = _getFontSize(context);
    final iconSize = _getIconSize(context);

    final color = _isHovered ? AppColors.lightText : AppColors.primary;
    final backgroundColor =
        _isHovered ? AppColors.primary : AppColors.cardBackground;
    final borderColor = _isHovered ? AppColors.lightText : AppColors.cardBorder;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: AnimatedContainer(
          duration: AnimationDurations.normal,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: AppBorderWidth.thick,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.card),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(AppShadows.hoverOpacity),
                      blurRadius: AppShadows.defaultBlur,
                      offset: AppShadows.defaultOffset,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.card),
            child: Stack(
              children: [
                // Icono en la esquina inferior izquierda
                Positioned(
                  bottom: AppSpacing.small,
                  left: AppSpacing.small,
                  width: iconSize,
                  height: iconSize,
                  child: SvgPicture.asset(
                    widget.iconPath,
                    placeholderBuilder: (context) => const Icon(
                      Icons.error,
                      color: AppColors.accent,
                    ),
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
                // Título centrado
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.large,
                    ),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: fontSize,
                        fontWeight: AppFontWeights.bold,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
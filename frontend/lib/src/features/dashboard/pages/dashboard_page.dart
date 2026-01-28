// frontend/lib/src/features/dashboard/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_logger.dart';
import '../../../core/user/user_state.dart';
import '../../../core/user/user_cubit.dart';
import '../responsive/responsive_dashboard_grid.dart';
import '../widgets/dashboard_card.dart';

/// Página principal del dashboard de la aplicación.
/// 
/// Muestra un grid de tarjetas según los permisos del usuario:
/// - Administradores: Ven todas las tarjetas
/// - Usuarios normales: Solo ven las tarjetas para las que tienen permiso
/// 
/// La distribución del grid se ajusta automáticamente según el tamaño
/// de pantalla (móvil, tablet, desktop).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  /// Datos de todas las tarjetas disponibles en el dashboard.
  static const List<Map<String, String>> _allCardData = [
    {
      'id': 'gestion_nominas',
      'title': 'GESTOR NÓMINAS',
      'icon': 'gestor_nominas.svg',
    },
  ];

  /// Construye la lista de tarjetas según los permisos del usuario.
  List<DashboardCard> _buildCards({
    required bool isAdmin,
    required Map<String, dynamic> permissions,
  }) {
    ApiLogger.info(
      'Building dashboard for ${isAdmin ? 'admin' : 'user'} with ${permissions.length} permissions',
      'DASHBOARD',
    );

    // Filtrar tarjetas según permisos
    final filteredData = isAdmin
        ? _allCardData // Admin ve todas
        : _allCardData.where((card) {
            final id = card['id'];
            return id != null &&
                permissions.containsKey(id) &&
                permissions[id] == true;
          });

    // Mapear datos a widgets
    final cards = filteredData
        .map(
          (card) => DashboardCard(
            id: card['id'],
            title: card['title']!,
            iconPath: '${AppAssets.dashboardIconsPath}${card['icon']!}',
          ),
        )
        .toList();

    ApiLogger.info('Dashboard loaded with ${cards.length} cards', 'DASHBOARD');

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserCubit>().state;

    // Esperar a que el usuario esté cargado
    if (userState is! UserLoaded) {
      ApiLogger.debug('Waiting for user to load', 'DASHBOARD');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final cardWidgets = _buildCards(
      isAdmin: userState.isAdmin,
      permissions: userState.permissions,
    );

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: DashboardConstants.maxContentWidth,
            ),
            child: ResponsiveDashboardGrid(children: cardWidgets),
          ),
        ),
      ),
    );
  }
}
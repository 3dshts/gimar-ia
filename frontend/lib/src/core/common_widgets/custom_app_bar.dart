// frontend/lib/src/core/common_widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../storage/storage_service.dart';
import '../theme/app_theme.dart';
import '../network/api_logger.dart';
import '../common_widgets/helpers/responsive_helper.dart';
import '../user/user_cubit.dart';
import '../user/user_state.dart';
import 'help_overlay_widget.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/datasheet/pages/datasheet_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';

/// AppBar personalizado y responsive de la aplicación.
///
/// Diseño por dispositivo:
/// - **Desktop**: Logo IntegrIA + SUSY-SHOES (centrado) + Usuario + 3 botones
/// - **Tablet/Móvil**: Logo SUSY-SHOES + Usuario + Menú hamburguesa
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(AppBarConstants.defaultHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  OverlayEntry? _helpOverlay;

  void _toggleHelpOverlay() {
    if (_helpOverlay != null) {
      ApiLogger.debug('Closing help overlay', 'APP_BAR');
      _helpOverlay!.remove();
      _helpOverlay = null;
      return;
    }

    ApiLogger.debug('Opening help overlay', 'APP_BAR');

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _helpOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + AppBarConstants.helpOverlayTop,
        right: AppBarConstants.helpOverlayRight,
        child: Material(
          color: AppColors.transparent,
          child: HelpOverlayWidget(
            onClose: _toggleHelpOverlay,
            onNavigateToDatasheet: () {
              _toggleHelpOverlay();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DatasheetPage()));
            },
          ),
        ),
      ),
    );

    overlay.insert(_helpOverlay!);
  }

  @override
  void dispose() {
    _helpOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserCubit>().state;
    final isDesktop = ResponsiveHelper.isDesktop(context);

    String username = 'USUARIO';
    String fullName = 'CARGANDO';

    if (userState is UserLoaded) {
      username = userState.username;
      fullName = userState.fullName;
    }

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: AppBarConstants.defaultHeight,
      backgroundColor: AppColors.primary,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: isDesktop
              ? AppBarConstants.desktopPadding
              : AppBarConstants.mobilePadding,
          child: isDesktop
              ? _buildDesktopLayout(username, fullName)
              : _buildMobileLayout(username, fullName),
        ),
      ),
    );
  }

  /// Layout para Desktop: Logo IntegrIA + SUSY-SHOES (centrado) + Usuario + 3 botones
  Widget _buildDesktopLayout(String username, String fullName) {
    return Stack(
      children: [
        // Título centrado (SUSY-SHOES SL)
        Center(child: _buildCompanyNameDesktop()),

        // Contenido principal
        Row(
          children: [
            _buildBrandSectionDesktop(),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUserInfoDesktop(username, fullName),
                const SizedBox(width: AppBarConstants.userInfoSpacing),
                _buildIconButton(
                  icon: Icons.person,
                  tooltip: 'Perfil',
                  onPressed: _navigateToProfile,
                  isDesktop: true,
                ),
                const SizedBox(width: AppSpacing.small),
                _buildIconButton(
                  icon: Icons.help_outline,
                  tooltip: 'Ayuda',
                  onPressed: _toggleHelpOverlay,
                  isDesktop: true,
                ),
                const SizedBox(width: AppSpacing.small),
                _buildLogoutButton(isDesktop: true),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Layout para Móvil/Tablet: Logo + Hamburguesa (fila 1) + Usuario (fila 2)
  Widget _buildMobileLayout(String username, String fullName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Fila 1: Logo SUSY-SHOES + Hamburguesa
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCompanyNameMobile(),
            _buildHamburgerButton(),
          ],
        ),
        
        const SizedBox(height: AppSpacing.small),
        
        // Fila 2: Información del usuario
        _buildUserInfoMobileFull(username, fullName),
      ],
    );
  }

    /// Información completa del usuario (móvil - segunda fila)
  Widget _buildUserInfoMobileFull(String username, String fullName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          children: [
            Text(
              username.toUpperCase(),
              style: const TextStyle(
                color: AppColors.lightText,
                fontWeight: AppFontWeights.bold,
                fontSize: AppBarConstants.mobileUsernameFontSize,
              ),
            ),
            Text(
              fullName.toUpperCase(),
              style: const TextStyle(
                color: AppColors.lightText,
                fontSize: AppBarConstants.mobileFullNameFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Marca IntegrIA FOR BUSINESS (solo desktop)
  Widget _buildBrandSectionDesktop() {
    return GestureDetector(
      onTap: () {
        ApiLogger.info('Navigating to Dashboard from logo', 'APP_BAR');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DashboardPage()));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.logoAppBar,
            width: AppBarConstants.logoSize,
            height: AppBarConstants.logoSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSpacing.small),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Integr',
                  style: const TextStyle(
                    fontSize: AppBarConstants.desktopBrandTitleSize,
                    fontWeight: AppFontWeights.extraBold,
                    color: AppColors.lightText,
                  ),
                  children: const [
                    TextSpan(
                      text: 'IA',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppBarConstants.brandLinesSpacing),
              const Text(
                'FOR BUSINESS',
                style: TextStyle(
                  fontSize: AppBarConstants.desktopBrandSubtitleSize,
                  fontWeight: AppFontWeights.medium,
                  color: AppColors.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Nombre de empresa centrado (solo desktop)
  Widget _buildCompanyNameDesktop() {
    return GestureDetector(
      onTap: () {
        ApiLogger.info('Navigating to Dashboard from company name', 'APP_BAR');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DashboardPage()));
      },
      child: const Text(
        'SUSY-SHOES SL',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.lightText,
          fontSize: AppBarConstants.desktopCompanyFontSize,
          fontWeight: AppFontWeights.semiBold,
          letterSpacing: AppBarConstants.desktopCompanyLetterSpacing,
        ),
      ),
    );
  }

  /// Nombre de empresa (móvil/tablet - reemplaza IntegrIA)
  Widget _buildCompanyNameMobile() {
    final isMobile = ResponsiveHelper.isMobile(context);

    return GestureDetector(
      onTap: () {
        ApiLogger.info('Navigating to Dashboard from company name', 'APP_BAR');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DashboardPage()));
      },
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.logoAppBar,
            width: AppBarConstants.logoSizeMobile,
            height: AppBarConstants.logoSizeMobile,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSpacing.small),
          Text(
            'SUSY-SHOES SL',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: isMobile
                  ? AppBarConstants.mobileCompanyFontSize
                  : AppBarConstants.tabletCompanyFontSize,
              fontWeight: AppFontWeights.bold,
              letterSpacing: AppBarConstants.mobileCompanyLetterSpacing,
            ),
          ),
        ],
      ),
    );
  }

  /// Información del usuario
  Widget _buildUserInfoDesktop(
    String username,
    String fullName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          username.toUpperCase(),
          style: TextStyle(
            color: AppColors.lightText,
            fontWeight: AppFontWeights.bold,
            fontSize: AppBarConstants.desktopUsernameFontSize
          ),
        ),
        Text(
          fullName.toUpperCase(),
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: AppBarConstants.desktopFullNameFontSize
          ),
        ),
      ],
    );
  }
  /// Botón de icono cuadrado
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isDesktop,
  }) {
    final size = isDesktop
        ? AppBarConstants.desktopIconButtonSize
        : AppBarConstants.mobileIconButtonSize;
    final iconSize = isDesktop
        ? AppBarConstants.desktopIconSize
        : AppBarConstants.mobileIconSize;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          side: const BorderSide(
            color: AppColors.lightText,
            width: AppBorderWidth.normal,
          ),
        ),
        child: IconButton(
          icon: Icon(icon, size: iconSize, color: AppColors.lightText),
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// Botón de logout
  Widget _buildLogoutButton({required bool isDesktop}) {
    final size = isDesktop
        ? AppBarConstants.desktopIconButtonSize
        : AppBarConstants.mobileIconButtonSize;
    final iconSize = isDesktop
        ? AppBarConstants.desktopIconSize
        : AppBarConstants.mobileIconSize;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent,
        border: Border.all(
          color: AppColors.lightText,
          width: AppBorderWidth.normal,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          onTap: _handleLogout,
          child: Center(
            child: Icon(
              Icons.logout,
              size: iconSize,
              color: AppColors.lightText,
            ),
          ),
        ),
      ),
    );
  }

  /// Botón hamburguesa (móvil/tablet)
  Widget _buildHamburgerButton() {
    return IconButton(
      icon: const Icon(
        Icons.menu,
        color: AppColors.lightText,
        size: AppBarConstants.hamburgerIconSize,
      ),
      onPressed: () {
        ApiLogger.debug('Opening hamburger menu', 'APP_BAR');
        _showHamburgerMenu();
      },
    );
  }

  /// Muestra el menú hamburguesa
  void _showHamburgerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.large,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Perfil
              ListTile(
                leading: const Icon(
                  Icons.person,
                  color: AppColors.lightText,
                  size: AppIconSizes.large,
                ),
                title: const Text(
                  'Perfil',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: AppFontSizes.medium,
                    fontWeight: AppFontWeights.semiBold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToProfile();
                },
              ),

              const Divider(color: AppColors.lightText),

              // Ayuda
              ListTile(
                leading: const Icon(
                  Icons.help_outline,
                  color: AppColors.lightText,
                  size: AppIconSizes.large,
                ),
                title: const Text(
                  'Ayuda',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: AppFontSizes.medium,
                    fontWeight: AppFontWeights.semiBold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToDatasheet();
                },
              ),

              const Divider(color: AppColors.lightText),

              // Cerrar sesión
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: AppIconSizes.large,
                ),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: AppFontSizes.medium,
                    fontWeight: AppFontWeights.semiBold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navega a la página de perfil
  void _navigateToProfile() {
    ApiLogger.info('Navigating to Profile', 'APP_BAR');
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
  }

  void _navigateToDatasheet() {
    ApiLogger.info('Navigating to Datasheet', 'APP_BAR');
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DatasheetPage()));
  }

  /// Maneja el logout
  Future<void> _handleLogout() async {
    ApiLogger.info('User logging out', 'APP_BAR');

    await StorageService.instance.deleteToken();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }
}

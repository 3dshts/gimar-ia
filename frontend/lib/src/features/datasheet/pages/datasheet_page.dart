// frontend/lib/src/features/datasheet/pages/datasheet_page.dart

import 'package:flutter/material.dart';
import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/theme/app_theme.dart';

// ============================================
// CONSTANTES
// ============================================

/// Dimensiones responsive.
class _ResponsiveDimensions {
  static const double maxFormWidth = 800.0;
  static const double mobileLogoWidth = 220.0;
  static const double desktopLogoWidth = 340.0;
}

/// Textos de la interfaz.
class _UITexts {
  static const String companyName = 'SUSY-SHOES SL';
  static const String title = 'DATASHEET';
  static const String logoSemanticLabel = 'IntegrIA for Business';
}

/// Assets de la aplicación.
class _DatasheetAssets {
  static const String logo = 'assets/images/logo_datasheet.png';
}

/// Configuración visual de secciones.
class _SectionConfig {
  static const double cardElevationBlur = 8.0;
  static const double cardElevationOpacity = 0.05;
  static const double iconSize = 6.0;
  static const double integrationIconSize = 36.0;
  static const double integrationTextSize = 12.0;
  static const double lineHeight = 1.4;
}

/// Tamaños de fuente personalizados.
class _CustomFontSizes {
  static const double companyName = 26.0;
}

/// Información de la versión actual.
class _VersionInfo {
  static const String version = 'Versión 1.0.0 - Agosto 2025';
  static final List<String> features = [
    'Actualización del panel de administración',
    'Mejoras visuales en componentes responsivos',
    'Optimizado el rendimiento de carga',
  ];
}

/// Características principales del sistema.
class _SystemFeatures {
  static final List<String> list = [
    'Aplicación web responsive con autenticación segura JWT',
    'Interfaz moderna, clara y adaptada a dispositivos móviles',
    'Subida de archivos, selector de fechas y formularios dinámicos',
    'Conexión directa con servicios de terceros para automatización de procesos',
  ];
}

/// Información sobre actualizaciones.
class _UpdateInfo {
  static final List<String> features = [
    'El sistema se actualizará periódicamente para garantizar su correcto funcionamiento',
    'Se aplicarán mejoras de rendimiento y corrección de errores de forma transparente para el usuario',
  ];
}

/// Información sobre escalabilidad.
class _ScalabilityInfo {
  static final List<String> features = [
    'Permite la incorporación de nuevos módulos y funcionalidades',
    'Arquitectura pensada para crecer sin afectar la estabilidad del sistema',
  ];
}

/// Información de seguridad.
class _SecurityInfo {
  static final List<String> features = [
    'Acceso protegido con tokens JWT cifrados',
    'Subida segura de archivos a Google Drive desde la aplicación',
    'Desencadenamiento de flujos automáticos sin intervención manual',
  ];
}

/// Información de IA y automatización.
class _AIInfo {
  static final List<String> features = [
    'La IA analiza los datos recibidos desde la app para preprocesarlos',
    'Make y OpenAI procesan y completan el trabajo final en hojas de Excel',
    'Esto reduce tiempo, errores y mejora la eficiencia operativa',
  ];
}

/// Información de licencia.
class _LicenseInfo {
  static const String number = 'integria-susyshoes-08-2025';
  static const int maxUsers = 30;

  static List<String> get details => [
        'Número de licencia: $number',
        'El número máximo de usuarios de esta licencia: $maxUsers',
      ];
}

/// Configuración de integraciones.
class _IntegrationData {
  static const String google = 'Google';
  static const String make = 'Make';
  static const String openai = 'OpenAI';

  static final List<_Integration> all = [
    _Integration(name: google, assetPath: AppAssets.googleLogo),
    _Integration(name: make, assetPath: AppAssets.makeLogo),
    _Integration(name: openai, assetPath: AppAssets.openaiLogo),
  ];
}

/// Modelo para representar una integración.
class _Integration {
  const _Integration({
    required this.name,
    required this.assetPath,
  });

  final String name;
  final String assetPath;
}

/// Títulos de las secciones.
class _SectionTitles {
  static const String version = _VersionInfo.version;
  static const String features = 'Características';
  static const String updatable = 'Actualizable';
  static const String scalable = 'Escalable';
  static const String integrations = 'Integraciones';
  static const String security = 'Seguridad y conectividad';
  static const String ai = 'IA y automatización';
  static const String license = 'LICENCIA';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class DatasheetPage extends StatelessWidget {
  const DatasheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.large : AppSpacing.xxl,
              vertical: isMobile ? AppSpacing.xl : 40.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _ResponsiveDimensions.maxFormWidth,
                ),
                child: _DatasheetContent(isMobile: isMobile),
              ),
            ),
          ),
          const FloatingBackButton(),
        ],
      ),
    );
  }
}

// ============================================
// CONTENIDO DEL DATASHEET
// ============================================

class _DatasheetContent extends StatelessWidget {
  const _DatasheetContent({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: AppSpacing.xl),
        _buildCompanyName(context),
        const SizedBox(height: AppSpacing.large),
        _buildDivider(),
        const SizedBox(height: AppSpacing.large),
        _buildTitle(context),
        const SizedBox(height: AppSpacing.xxl),
        _buildVersionSection(context),
        _buildFeaturesSection(context),
        _buildUpdatableSection(context),
        _buildScalableSection(context),
        _buildIntegrationsSection(context),
        _buildSecuritySection(context),
        _buildAISection(context),
        _buildLicenseSection(context),
        const SizedBox(height: 40.0),
      ],
    );
  }

  Widget _buildLogo() {
    return Semantics(
      label: _UITexts.logoSemanticLabel,
      child: Image.asset(
        _DatasheetAssets.logo,
        width: isMobile
            ? _ResponsiveDimensions.mobileLogoWidth
            : _ResponsiveDimensions.desktopLogoWidth,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildCompanyName(BuildContext context) {
    return Text(
      _UITexts.companyName,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: AppFontWeights.bold,
            fontSize: _CustomFontSizes.companyName,
          ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.accent,
      thickness: AppBorderWidth.normal,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _UITexts.title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: AppFontWeights.bold,
          ),
    );
  }

  Widget _buildVersionSection(BuildContext context) {
    return _DatasheetSection(
      icon: Icons.info,
      title: _SectionTitles.version,
      bullets: _VersionInfo.features,
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return _DatasheetSection(
      icon: Icons.star_border,
      title: _SectionTitles.features,
      bullets: _SystemFeatures.list,
    );
  }

  Widget _buildUpdatableSection(BuildContext context) {
    return _DatasheetSection(
      icon: Icons.system_update_alt,
      title: _SectionTitles.updatable,
      bullets: _UpdateInfo.features,
    );
  }

  Widget _buildScalableSection(BuildContext context) {
    return _DatasheetSection(
      icon: Icons.stacked_bar_chart,
      title: _SectionTitles.scalable,
      bullets: _ScalabilityInfo.features,
    );
  }

  Widget _buildIntegrationsSection(BuildContext context) {
    return const _IntegrationsSection();
  }

  Widget _buildSecuritySection(BuildContext context) {
    return _DatasheetSection(
      icon: Icons.shield,
      title: _SectionTitles.security,
      bullets: _SecurityInfo.features,
    );
  }

  Widget _buildAISection(BuildContext context) {
    return _DatasheetSection(
      icon: Icons.flash_on,
      title: _SectionTitles.ai,
      bullets: _AIInfo.features,
    );
  }

  Widget _buildLicenseSection(BuildContext context) {
    return _DatasheetSection(
      icon: Icons.key,
      title: _SectionTitles.license,
      bullets: _LicenseInfo.details,
    );
  }
}

// ============================================
// COMPONENTE DE SECCIÓN ESTÁNDAR
// ============================================

class _DatasheetSection extends StatelessWidget {
  const _DatasheetSection({
    required this.icon,
    required this.title,
    required this.bullets,
  });

  final IconData icon;
  final String title;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.medium),
          _buildBulletList(context),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(_SectionConfig.cardElevationOpacity),
          blurRadius: _SectionConfig.cardElevationBlur,
          offset: const Offset(0, AppBorderWidth.normal),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent),
        const SizedBox(width: AppSpacing.small),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: AppFontWeights.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildBulletList(BuildContext context) {
    return Column(
      children: bullets
          .map((item) => _BulletPoint(text: item))
          .toList(),
    );
  }
}

// ============================================
// COMPONENTE DE BULLET POINT
// ============================================

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            size: _SectionConfig.iconSize,
            color: AppColors.text,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: _SectionConfig.lineHeight,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// SECCIÓN DE INTEGRACIONES
// ============================================

class _IntegrationsSection extends StatelessWidget {
  const _IntegrationsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.medium),
          _buildIntegrationsList(),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(_SectionConfig.cardElevationOpacity),
          blurRadius: _SectionConfig.cardElevationBlur,
          offset: const Offset(0, AppBorderWidth.normal),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.integration_instructions,
          color: AppColors.accent,
        ),
        const SizedBox(width: AppSpacing.small),
        Text(
          _SectionTitles.integrations,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: AppFontWeights.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildIntegrationsList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _IntegrationData.all
          .map((integration) => _buildIntegrationItem(integration))
          .toList()
          ..insert(1, const SizedBox(width: AppSpacing.xl))
          ..insert(3, const SizedBox(width: AppSpacing.xl)),
    );
  }

  Widget _buildIntegrationItem(_Integration integration) {
    return _IntegrationIcon(
      assetPath: integration.assetPath,
      name: integration.name,
    );
  }
}

// ============================================
// COMPONENTE DE ICONO DE INTEGRACIÓN
// ============================================

class _IntegrationIcon extends StatelessWidget {
  const _IntegrationIcon({
    required this.assetPath,
    required this.name,
  });

  final String assetPath;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          assetPath,
          width: _SectionConfig.integrationIconSize,
          height: _SectionConfig.integrationIconSize,
        ),
        const SizedBox(height: 6.0),
        Text(
          name,
          style: const TextStyle(
            fontSize: _SectionConfig.integrationTextSize,
          ),
        ),
      ],
    );
  }
}
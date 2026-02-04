// frontend/lib/src/core/theme/app_theme.dart

import 'package:flutter/material.dart';

// ============================================
// ESPACIADO Y DIMENSIONES
// ============================================

/// Espaciado estándar usado en toda la aplicación.
class AppSpacing {
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Radio de bordes para componentes de la UI.
class AppBorderRadius {
  static const double small = 6.0;
  static const double medium = 8.0;
  static const double card = 10.0;
  static const double large = 12.0;
  static const double xl = 16.0;
}

/// Anchos de borde para inputs y componentes.
class AppBorderWidth {
  static const double thin = 1.5;
  static const double normal = 2.0;
  static const double thick = 3.0;
}

/// Elevaciones para sombras de componentes.
class AppElevation {
  static const double none = 0.0;
  static const double small = 2.0;
  static const double medium = 4.0;
  static const double large = 8.0;
  static const double overlay = 10.0;
}

/// Padding predefinido para componentes comunes.
class AppPadding {
  static const EdgeInsets inputField = EdgeInsets.symmetric(
    horizontal: AppSpacing.large,
    vertical: AppSpacing.medium,
  );

  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.large,
  );

  static const EdgeInsets card = EdgeInsets.all(AppSpacing.large);
  static const EdgeInsets screen = EdgeInsets.all(AppSpacing.large);
  static const EdgeInsets overlay = EdgeInsets.all(AppSpacing.large);
}

// ============================================
// TIPOGRAFÍA
// ============================================

/// Tamaños de fuente usados en la aplicación.
class AppFontSizes {
  static const double small = 14.0;
  static const double medium = 16.0;
  static const double large = 18.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

/// Espaciado entre letras para tipografía.
class AppLetterSpacing {
  static const double tight = -1.0;
  static const double normal = 0.5;
  static const double wide = 1.0;
  static const double wider = 3.0;
}

/// Pesos de fuente estándar.
class AppFontWeights {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}

// ============================================
// COLORES
// ============================================

/// Paleta de colores principal del diseño.
class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFF2c3e50);
  static const Color accent = Color(0xFFff6b47);

  // Colores de fondo
  static const Color background = Color(0xFFf0f0f0);
  static const Color cardBackground = Color(0xFFf8f9fa);
  static const Color inputBackground = Colors.white;
  static const Color overlayBackground = Colors.white;
  static const Color transparent = Colors.transparent;

  // Colores de texto
  static const Color text = Color(0xFF495057);
  static const Color lightText = Color(0xFFf0f0f0);

  // Colores de borde
  static const Color border = Color(0xFFe9ecef);
  static const Color cardBorder = Color(0xFF2c3e50);

  // Colores de estado
  static const Color success = Color(0xFF27ae60);
  static const Color error = Color(0xFFdc3545);
  static const Color warning = Color(0xFFffc107);
  static const Color info = Color(0xFF17a2b8);

  // Colores de sombra
  static const Color shadow = Colors.black26;

  /// Color de sombra con opacidad personalizable.
  static Color shadowWithOpacity(double opacity) =>
      Colors.black.withOpacity(opacity);
}

/// Colores específicos de branding.
class BrandingColors {
  static const Color overlayLight = Color.fromRGBO(108, 117, 125, 0.1);
  static const Color overlayDark = Color.fromRGBO(52, 58, 64, 0.2);
}

// ============================================
// RESPONSIVE
// ============================================

/// Breakpoints para diseño responsive.
class AppBreakpoints {
  static const double mobile = 768.0;
  static const double tablet = 1024.0;
  static const double desktop = 1440.0;
}

// ============================================
// COMPONENTES - BOTONES
// ============================================

/// Alturas de botones según dispositivo.
class AppButtonHeights {
  static const double mobile = 48.0;
  static const double desktop = 52.0;
}

// ============================================
// COMPONENTES - ICONOS
// ============================================

/// Tamaños de iconos estándar.
class AppIconSizes {
  static const double small = 16.0;
  static const double medium = 20.0;
  static const double large = 24.0;
  static const double xl = 32.0;
}

// ============================================
// COMPONENTES - LOADING
// ============================================

/// Configuración para indicadores de progreso (loading).
class AppProgressIndicator {
  static const double strokeWidth = 3.0;
  static const double size = 24.0;
}

// ============================================
// COMPONENTES - SOMBRAS
// ============================================

/// Constantes de sombras.
class AppShadows {
  static const double defaultBlur = 25.0;
  static const Offset defaultOffset = Offset(0, 8);
  static const double hoverOpacity = 0.3;
  static const Offset overlayOffset = Offset(0, 4);
}

// ============================================
// ANIMACIONES
// ============================================

/// Constantes de animación.
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration appBar = Duration(milliseconds: 380);
  static const Duration slow = Duration(milliseconds: 500);
}

// ============================================
// ASSETS - IMÁGENES Y SVG
// ============================================

/// Rutas de assets de imágenes y SVG.
class AppAssets {
  // Imágenes generales
  static const String brandingBanner = 'assets/images/gimar-banner.jpg';
  static const String logoAppBar = 'assets/images/logo_app_bar.svg';

  // Iconos del dashboard
  static const String dashboardIconsPath = 'assets/dashboard_icons/';

  // Integraciones
  static const String googleLogo = 'assets/images/google.png';
  static const String makeLogo = 'assets/images/make.png';
  static const String openaiLogo = 'assets/images/openai.png';
}

// ============================================
// ESTILOS DE TEXTO
// ============================================

/// Estilos de texto predefinidos para la aplicación.
class AppTextStyles {
  // Estilos base
  static const TextStyle inputText = TextStyle(
    fontSize: AppFontSizes.medium,
    color: AppColors.text,
    fontFamily: 'Inter',
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: AppFontSizes.medium,
    color: AppColors.text,
    fontFamily: 'Inter',
  );

  static const TextStyle body = TextStyle(
    fontSize: AppFontSizes.medium,
    color: AppColors.text,
    fontFamily: 'Inter',
  );

  static const TextStyle title = TextStyle(
    fontSize: AppFontSizes.large,
    fontWeight: AppFontWeights.semiBold,
    color: AppColors.text,
    fontFamily: 'Inter',
  );

  static const TextStyle heading = TextStyle(
    fontSize: AppFontSizes.xl,
    fontWeight: AppFontWeights.bold,
    color: AppColors.text,
    fontFamily: 'Inter',
  );

  static const TextStyle label = TextStyle(
    fontSize: AppFontSizes.medium,
    fontWeight: AppFontWeights.semiBold,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );

  static const TextStyle error = TextStyle(
    fontSize: AppFontSizes.small,
    color: AppColors.error,
    fontFamily: 'Inter',
  );

  // Estilos responsive
  static TextStyle labelResponsive(bool isMobile) => TextStyle(
    fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
    fontWeight: AppFontWeights.semiBold,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );

  static TextStyle buttonText(bool isMobile) => TextStyle(
    fontSize: isMobile ? AppFontSizes.small : AppFontSizes.medium,
    fontWeight: AppFontWeights.semiBold,
    letterSpacing: AppLetterSpacing.wide,
    fontFamily: 'Inter',
  );

  // Estilos de branding
  static TextStyle brandTitle(bool isMobile) => TextStyle(
    fontSize: isMobile ? 28.0 : 48.0,
    fontWeight: AppFontWeights.bold,
    color: AppColors.primary,
    letterSpacing: AppLetterSpacing.tight,
    fontFamily: 'Inter',
  );

  static TextStyle brandSubtitle(bool isMobile) => TextStyle(
    fontSize: isMobile ? 12.0 : 18.0,
    fontWeight: AppFontWeights.regular,
    color: AppColors.text,
    letterSpacing: AppLetterSpacing.wider,
    fontFamily: 'Inter',
  );

  static TextStyle sectionTitle(bool isMobile) => TextStyle(
    fontSize: isMobile ? 18.0 : 24.0,
    fontWeight: AppFontWeights.semiBold,
    color: AppColors.primary,
    fontFamily: 'Inter',
  );
}

// ============================================
// CONFIGURACIÓN DEL TEMA PRINCIPAL
// ============================================

/// Configuración del tema de la aplicación.
class AppTheme {
  static const double _borderWidth = AppBorderWidth.normal;

  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: AppElevation.medium,
        shadowColor: AppColors.shadow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.large,
            horizontal: AppSpacing.xl,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: AppFontWeights.semiBold,
            fontSize: AppFontSizes.medium,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: _borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: _borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: _borderWidth,
          ),
        ),
      ),
    );
  }
}

// ============================================
// PÁGINAS - LOGIN
// ============================================

class LoginConstants {
  static const double maxFormWidth = 380.0;
}

class LoginLayoutHeights {
  static const double mobileFormHeight = 450.0;
  static const double mobileBrandingHeight = 200.0;
}

// ============================================
// PÁGINAS - SPLASH
// ============================================

class SplashConstants {
  static const Duration initialDelay = Duration(milliseconds: 50);
}

// ============================================
// PÁGINAS - DASHBOARD
// ============================================

class DashboardConstants {
  static const double maxContentWidth = 1400.0;
}

class DashboardCardFontSizes {
  static const double mobile = 16.0;
  static const double tablet = 20.0;
  static const double desktop = 24.0;
}

class DashboardCardIconSizes {
  static const double mobile = 50.0;
  static const double tablet = 60.0;
  static const double desktop = 75.0;
}

class DashboardGridAnimation {
  static const double hoverScale = 1.10;
  static const double restScale = 0.94;
  static const double hoverOpacity = 1.0;
  static const double restOpacity = 0.80;
  static const Duration duration = Duration(milliseconds: 380);
  static const Curve curve = Curves.easeOutCubic;
}

class DashboardGridConfig {
  static const int mobileCrossAxisCount = 1;
  static const double mobileChildAspectRatio = 1.5;
  static const int tabletCrossAxisCount = 2;
  static const double tabletChildAspectRatio = 2.0;
  static const int desktopCrossAxisCount = 3;
  static const double desktopChildAspectRatio = 2.5;
  static const double gridPadding = 24.0;
  static const double gridSpacing = 24.0;
}

// ============================================
// COMPONENTES - APP BAR
// ============================================

class AppBarConstants {
  // Alturas generales
  static const double defaultHeight = 90.0;

  // Help overlay
  static const double helpOverlayTop = 75.0;
  static const double helpOverlayRight = 20.0;
  static const double helpOverlayWidth = 280.0;

  // Icon buttons
  static const double mobileIconButtonSize = 36.0;
  static const double desktopIconButtonSize = 44.0;
  static const double mobileIconSize = 18.0;
  static const double desktopIconSize = 22.0;

  // Hamburger menu
  static const double hamburgerIconSize = 28.0;
  static const double menuWidth = 280.0;

  // Brand section - Desktop
  static const double desktopBrandTitleSize = 24.0;
  static const double desktopBrandSubtitleSize = 14.0;
  static const double brandLinesSpacing = 2.0;
  static const double logoSize = 40.0;
  static const double logoSizeMobile = 32.0;

  // Company name - Mobile/Tablet (reemplaza la marca)
  static const double mobileCompanyFontSize = 18.0;
  static const double tabletCompanyFontSize = 20.0;
  static const double desktopCompanyFontSize = 22.0;
  static const double mobileCompanyLetterSpacing = 1.0;
  static const double desktopCompanyLetterSpacing = 2.0;

  // User info
  static const double mobileUsernameFontSize = 11.0;
  static const double desktopUsernameFontSize = 16.0;
  static const double mobileFullNameFontSize = 11.0;
  static const double desktopFullNameFontSize = 14.0;
  static const double userInfoSpacing = 24.0;

  // Help overlay content
  static const double integrationIconSize = 24.0;
  static const double helpContentFontSize = 13.0;

  static const double mobileHeight = 80.0; // Nueva constante
  static const double mobileUserIconSize = 20.0; // Nueva constante

  // Padding responsive
  static EdgeInsets mobilePadding = const EdgeInsets.symmetric(
    horizontal: AppSpacing.large,
    vertical: AppSpacing.small,
  );

  static EdgeInsets desktopPadding = const EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.small,
  );
}

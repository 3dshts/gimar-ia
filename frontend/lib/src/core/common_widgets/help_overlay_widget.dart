// frontend/lib/src/core/common_widgets/help_overlay_widget.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget de overlay de ayuda que muestra información sobre novedades e integraciones.
/// 
/// Características:
/// - Carrusel de contenido con navegación entre pasos
/// - Botón de cierre
/// - Botón "Leer más" en la sección de Data Sheet
/// - Sección especial de integraciones con logos
class HelpOverlayWidget extends StatefulWidget {
  const HelpOverlayWidget({
    super.key,
    required this.onClose,
    required this.onNavigateToDatasheet,
  });

  /// Callback para cerrar el overlay.
  final VoidCallback onClose;

  /// Callback para navegar a la página de Datasheet.
  final VoidCallback onNavigateToDatasheet;

  @override
  State<HelpOverlayWidget> createState() => _HelpOverlayWidgetState();
}

class _HelpOverlayWidgetState extends State<HelpOverlayWidget> {
  int _currentStep = 0;

  /// Contenido del carrusel de ayuda.
  final List<_HelpContent> _helpContent = const [
    _HelpContent(
      title: 'Versión 1.0.0',
      text: 'Nueva interfaz, envío de formularios y login seguro con JWT.',
      showReadMoreButton: false,
      isIntegrations: false,
    ),
    _HelpContent(
      title: 'Data Sheet',
      text: 'Sube documentos, selecciona opciones, graba audio y envía todo vía JSON.',
      showReadMoreButton: true,
      isIntegrations: false,
    ),
    _HelpContent(
      title: 'Integraciones',
      text: '',
      showReadMoreButton: false,
      isIntegrations: true,
    ),
  ];

  void _goToPrevious() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _goToNext() {
    if (_currentStep < _helpContent.length - 1) {
      setState(() => _currentStep++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentContent = _helpContent[_currentStep];

    return Container(
      width: AppBarConstants.helpOverlayWidth,
      padding: AppPadding.overlay,
      decoration: BoxDecoration(
        color: AppColors.overlayBackground,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowWithOpacity(0.1),
            blurRadius: AppElevation.overlay,
            offset: AppShadows.overlayOffset,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (título + botón cerrar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentContent.title,
                style: const TextStyle(
                  fontWeight: AppFontWeights.bold,
                  fontSize: AppBarConstants.helpContentFontSize,
                ),
              ),
              GestureDetector(
                onTap: widget.onClose,
                child: const Icon(
                  Icons.close,
                  size: AppIconSizes.small,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),

          // Contenido
          if (currentContent.isIntegrations)
            _buildIntegrationsSection()
          else
            _buildTextContent(currentContent),

          const SizedBox(height: AppSpacing.medium),

          // Navegación (flechas anterior/siguiente)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _currentStep > 0 ? _goToPrevious : null,
                iconSize: AppIconSizes.small,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _currentStep < _helpContent.length - 1
                    ? _goToNext
                    : null,
                iconSize: AppIconSizes.small,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye el contenido de texto con botón "Leer más" opcional.
  Widget _buildTextContent(_HelpContent content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.text,
          style: const TextStyle(
            fontSize: AppBarConstants.helpContentFontSize,
          ),
        ),
        if (content.showReadMoreButton) ...[
          const SizedBox(height: AppSpacing.small),
          TextButton(
            onPressed: widget.onNavigateToDatasheet,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.lightText,
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
            ),
            child: const Text('Leer más'),
          ),
        ],
      ],
    );
  }

  /// Construye la sección de integraciones con logos.
  Widget _buildIntegrationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntegrationRow(AppAssets.googleLogo, 'Google'),
        const SizedBox(height: AppSpacing.small),
        _buildIntegrationRow(AppAssets.makeLogo, 'Make'),
        const SizedBox(height: AppSpacing.small),
        _buildIntegrationRow(AppAssets.openaiLogo, 'OpenAI'),
      ],
    );
  }

  /// Construye una fila de integración (logo + nombre).
  Widget _buildIntegrationRow(String assetPath, String name) {
    return Row(
      children: [
        Image.asset(
          assetPath,
          width: AppBarConstants.integrationIconSize,
          height: AppBarConstants.integrationIconSize,
        ),
        const SizedBox(width: AppSpacing.small),
        Text(
          name,
          style: const TextStyle(
            fontSize: AppBarConstants.helpContentFontSize,
          ),
        ),
      ],
    );
  }
}

/// Modelo de datos para el contenido del overlay de ayuda.
class _HelpContent {
  const _HelpContent({
    required this.title,
    required this.text,
    required this.showReadMoreButton,
    required this.isIntegrations,
  });

  final String title;
  final String text;
  final bool showReadMoreButton;
  final bool isIntegrations;
}
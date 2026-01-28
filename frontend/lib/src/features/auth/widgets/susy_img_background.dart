// frontend/lib/src/features/auth/widgets/branding_image.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget que muestra la imagen de branding con un overlay de gradiente.
/// 
/// Utilizado en la pantalla de login para mostrar la imagen corporativa
/// con un efecto visual de gradiente superpuesto que mejora la legibilidad
/// del contenido que pueda aparecer encima.
class BrandingImage extends StatelessWidget {
  const BrandingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Image(
          image: AssetImage(AppAssets.brandingBanner),
          fit: BoxFit.cover,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BrandingColors.overlayLight,
                BrandingColors.overlayDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }
}
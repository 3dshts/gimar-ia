// frontend/lib/src/features/auth/pages/login_page.dart

import 'package:flutter/material.dart';
import '../widgets/susy_img_background.dart';
import '../widgets/login_form.dart';
import '../responsive/responsive_login_layout.dart';

/// Página principal de inicio de sesión.
/// 
/// Utiliza un layout responsive que muestra:
/// - Desktop/Tablet: Formulario a la izquierda, imagen de branding a la derecha
/// - Móvil: Formulario arriba, imagen de branding abajo (con scroll)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveLoginLayout(
        leftChild: LoginForm(),
        rightChild: BrandingImage(),
      ),
    );
  }
}
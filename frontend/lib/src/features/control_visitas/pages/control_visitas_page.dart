// frontend/lib/src/features/prueba_web/pages/prueba_web_page.dart

import 'dart:math';
import 'dart:ui_web' as ui;
import 'package:frontend/src/core/network/api_logger.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/user/user_cubit.dart';
import '../../../core/user/user_state.dart';

// ============================================
// CONSTANTES
// ============================================

/// Configuración del módulo ControlVisitas.
class _ControlVisitasConfig {
  /// URL base que se cargará dentro del iframe.
  /// Los parámetros de usuario se añaden dinámicamente en runtime.
  static const String baseUrl = 'https://meet-register.lovable.app/';

  /// Nombre del parámetro de query para el nombre del usuario.
  static const String paramName = 'name';

  /// Nombre del parámetro de query para el rol de administrador.
  /// Solo se incluye en la URL si el usuario es administrador.
  static const String paramAdmin = 'admin';

  /// Identificador único para el registro del HtmlElementView.
  static const String viewType = 'prueba-web-iframe';
}

/// Estilos CSS aplicados directamente al IFrameElement.
class _IFrameStyles {
  static const String width = '100%';
  static const String height = '100%';
  static const String border = 'none';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

/// Página del módulo PruebaWeb.
///
/// Lee el estado del usuario desde [UserCubit] para construir la URL
/// del iframe con los parámetros correspondientes:
/// - `name`: nombre completo del usuario autenticado.
/// - `admin`: solo se incluye si el usuario tiene rol de administrador.
///
/// Ejemplo de URL generada para admin:
///   https://www.test.com/?name=Aurelio Gimenez&admin=true
///
/// Ejemplo de URL generada para usuario normal:
///   https://www.test.com/?name=Aurelio Gimenez
class ControlVisitasPage extends StatefulWidget {
  const ControlVisitasPage({super.key});

  @override
  State<ControlVisitasPage> createState() => _ControlVisitasPageState();
}

class _ControlVisitasPageState extends State<ControlVisitasPage> {
  @override
  void initState() {
    super.initState();
    _registerIFrameView();
  }

  /// Construye la URL final con los parámetros del usuario.
  ///
  /// Usa [Uri] para construir la URL de forma segura, evitando
  /// problemas con caracteres especiales en el nombre (espacios,
  /// acentos, etc.) que se encodean automáticamente.
  ///
  /// Si el estado del usuario no está cargado aún, devuelve
  /// la URL base sin parámetros como fallback.
  String _buildUrl() {
    final userState = context.read<UserCubit>().state;

    // Si el usuario no está cargado, usamos la URL base sin parámetros
    if (userState is! UserLoaded) {
      return _ControlVisitasConfig.baseUrl;
    }

    // Construir mapa de parámetros de query
    final queryParams = <String, String>{
      _ControlVisitasConfig.paramName: userState.fullName,
    };

    // El parámetro admin solo se añade si el usuario es administrador
    if (userState.isAdmin) {
      queryParams[_ControlVisitasConfig.paramAdmin] = 'true';
    }

    ApiLogger.info('Building URL for ControlVisitas with params: $queryParams', 'CONTROL_VISITAS');
    // Uri.https construye y encodea la URL correctamente
    return Uri.https(
      'meet-register.lovable.app',
      '/',
      queryParams,
    ).toString();
  }

  /// Registra el IFrameElement en el sistema de vistas nativas de Flutter Web.
  ///
  /// La URL se construye en este momento, cuando el árbol de widgets
  /// ya está montado y el UserCubit está disponible en el contexto.
  void _registerIFrameView() {
    ui.platformViewRegistry.registerViewFactory(
      _ControlVisitasConfig.viewType,
      (int viewId) => _buildIFrameElement(),
    );
  }

  /// Construye y configura el IFrameElement con la URL dinámica y estilos.
  web.HTMLIFrameElement _buildIFrameElement() {
    return (web.document.createElement('iframe') as web.HTMLIFrameElement)
      ..src = _buildUrl()
      ..style.width = _IFrameStyles.width
      ..style.height = _IFrameStyles.height
      ..style.border = _IFrameStyles.border;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // El iframe ocupa todo el espacio del body bajo el AppBar.
          const _IFrameContainer(),
          // El botón de retroceso flota sobre el iframe.
          const FloatingBackButton(),
        ],
      ),
    );
  }
}

// ============================================
// CONTENEDOR DEL IFRAME
// ============================================

/// Widget que renderiza el iframe registrado como vista nativa de Flutter Web.
class _IFrameContainer extends StatelessWidget {
  const _IFrameContainer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: HtmlElementView(
        viewType: _ControlVisitasConfig.viewType,
      ),
    );
  }
}
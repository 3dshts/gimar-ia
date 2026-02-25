// frontend/lib/src/features/prueba_web/pages/prueba_web_page.dart

import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/floating_back_button.dart';

// ============================================
// CONSTANTES
// ============================================

/// Configuración del módulo PruebaWeb.
///
/// Centraliza los valores configurables del iframe para facilitar
/// futuros cambios sin tener que buscar valores dispersos en el código.
class _PruebaWebConfig {
  /// URL que se cargará dentro del iframe.
  /// Sustituir por la URL definitiva cuando esté disponible.
  static const String url = 'https://barca-beat-madrid-page.lovable.app/';

  /// Identificador único para el registro del HtmlElementView.
  ///
  /// Flutter Web necesita un string único por cada tipo de vista nativa
  /// que se registre. Si hubiera varios iframes distintos en la app,
  /// cada uno necesitaría su propio viewType diferente.
  static const String viewType = 'prueba-web-iframe';
}

/// Estilos CSS aplicados directamente al IFrameElement.
///
/// Se aplican inline porque el IFrameElement vive fuera del árbol
/// de widgets de Flutter, por lo que no podemos usar AppTheme aquí.
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
/// Muestra un iframe que carga una URL externa manteniendo el
/// CustomAppBar y el FloatingBackButton de la aplicación.
///
/// IMPORTANTE: Este widget solo funciona en Flutter Web. Si en el
/// futuro se necesita soporte móvil nativo, habría que usar el
/// paquete `webview_flutter` con condicionales de plataforma (kIsWeb).
class PruebaWebPage extends StatefulWidget {
  const PruebaWebPage({super.key});

  @override
  State<PruebaWebPage> createState() => _PruebaWebPageState();
}

class _PruebaWebPageState extends State<PruebaWebPage> {
  @override
  void initState() {
    super.initState();
    _registerIFrameView();
  }

  /// Registra el IFrameElement en el sistema de vistas nativas de Flutter Web.
  ///
  /// Flutter Web permite embeber elementos HTML nativos mediante
  /// `ui.platformViewRegistry.registerViewFactory`. Esta función debe
  /// llamarse una sola vez por viewType. Si se llama más de una vez con
  /// el mismo viewType, Flutter lo ignora silenciosamente.
  ///
  /// El factory recibe un `viewId` (int) que Flutter asigna internamente
  /// y devuelve el elemento HTML que se quiere renderizar.
  void _registerIFrameView() {
    ui.platformViewRegistry.registerViewFactory(
      _PruebaWebConfig.viewType,
      (int viewId) => _buildIFrameElement(),
    );
  }

  /// Construye y configura el IFrameElement con la URL y estilos necesarios.
  ///
  /// - `src`: la URL que cargará el iframe.
  /// - `style`: estilos CSS inline para que ocupe todo el espacio disponible
  ///   y no muestre el borde nativo del navegador.
  web.HTMLIFrameElement _buildIFrameElement() {
  return (web.document.createElement('iframe') as web.HTMLIFrameElement)
    ..src = _PruebaWebConfig.url
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
///
/// `HtmlElementView` es el puente entre el árbol de widgets de Flutter
/// y los elementos HTML nativos del navegador. Necesita el mismo
/// `viewType` que se usó al registrar el factory en `platformViewRegistry`.
///
/// Se extrae como widget separado para mantener la responsabilidad única:
/// este widget solo sabe cómo mostrar el iframe, no sabe nada de la
/// página que lo contiene.
class _IFrameContainer extends StatelessWidget {
  const _IFrameContainer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      // SizedBox.expand fuerza al HtmlElementView a ocupar todo el
      // espacio disponible que le deja el Scaffold (bajo el AppBar).
      child: HtmlElementView(
        viewType: _PruebaWebConfig.viewType,
      ),
    );
  }
}
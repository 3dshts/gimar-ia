// frontend/lib/src/features/prueba_web/pages/prueba_web_page.dart

import 'dart:ui_web' as ui;
import 'package:frontend/src/core/network/api_logger.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import '../../../core/common_widgets/custom_app_bar.dart';

// ============================================
// CONSTANTES
// ============================================

/// Configuración del módulo CAE.
class _CAEConfig {
  static const String baseUrl = 'https://genesis-emp.lovable.app';
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

/// Página del módulo CAE.
class CAEPage extends StatefulWidget {
  const CAEPage({super.key});

  @override
  State<CAEPage> createState() => _CAEPageState();
}

class _CAEPageState extends State<CAEPage> {
  @override
  void initState() {
    super.initState();
    // Registrar el iframe una sola vez al iniciar
    _registerIFrameView();
  }

  /// Registro de la vista sin parámetros de query
  void _registerIFrameView() {
    ui.platformViewRegistry.registerViewFactory(
      _CAEConfig.viewType,
      (int viewId) {
        final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
        
        iframe.src = _CAEConfig.baseUrl; // Carga la URL limpia
        iframe.style.width = _IFrameStyles.width;
        iframe.style.height = _IFrameStyles.height;
        iframe.style.border = _IFrameStyles.border;
        
        ApiLogger.info('Cargando iframe sin parámetros: ${_CAEConfig.baseUrl}', 'CAEPage');
        
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          const _IFrameContainer(),
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
        viewType: _CAEConfig.viewType,
      ),
    );
  }
}
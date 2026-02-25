// frontend/lib/src/features/buzon/pages/buzon_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/common_multiline_text_field.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/json_sender.dart';
import '../../../core/user/user_cubit.dart';
import '../../../core/user/user_state.dart';

// ============================================
// CONSTANTES
// ============================================

/// Endpoints externos de la aplicación.
class _BuzonEndpoints {
  static const String makeWebhook =
      'https://hook.eu2.make.com/esibxbllkdy4bitfpz6c3yhg42ogcn8e';
}

/// Claves de campos del formulario.
class _FormFields {
  static const String mensaje = 'mensaje';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.mensaje: 'Mensaje',
  };
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String mensajeRequired = 'El mensaje es obligatorio.';

  static String buildAggregateError(List<String> missingFields) {
    return 'Faltan los campos: ${missingFields.join(', ')}.';
  }
}

/// Mensajes de estado.
class _StatusMessages {
  static const String messageSent = 'Mensaje enviado correctamente';
  static const String messageError = 'Error al enviar mensaje';
}

/// Valores por defecto para usuario.
class _UserDefaults {
  static const String username = 'USUARIO';
  static const String fullName = 'CARGANDO';
  static const String email = 'PRUEBA';
}

/// Dimensiones responsive.
class _ResponsiveDimensions {
  static const double maxFormWidth = 800.0;
  static const double mobileWatermarkSizeFactor = 0.4;
  static const double desktopWatermarkSizeFactor = 0.5;
  static const double mobileWatermarkSizePx = 240.0;
  static const double desktopWatermarkSizePx = 360.0;
  static const double mobilePaddingVertical = 24.0;
  static const double desktopPaddingVertical = 40.0;
}

/// Textos de la interfaz.
class _UITexts {
  static const String title = 'BUZÓN';
  static const String placeholder =
      'Tu perspectiva nos ayuda a crecer, compártenos tu opinión...';
  static const String submitButton = 'Enviar';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class BuzonPage extends StatelessWidget {
  const BuzonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: ViewportWatermarkWidget(
        asset: 'assets/dashboard_icons/buzon.svg',
        sizeFactor: isMobile
            ? _ResponsiveDimensions.mobileWatermarkSizeFactor
            : _ResponsiveDimensions.desktopWatermarkSizeFactor,
        sizePx: isMobile
            ? _ResponsiveDimensions.mobileWatermarkSizePx
            : _ResponsiveDimensions.desktopWatermarkSizePx,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppSpacing.large : AppSpacing.xxl,
                vertical: isMobile
                    ? _ResponsiveDimensions.mobilePaddingVertical
                    : _ResponsiveDimensions.desktopPaddingVertical,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _ResponsiveDimensions.maxFormWidth,
                  ),
                  child: const _BuzonForm(),
                ),
              ),
            ),
            const FloatingBackButton(),
          ],
        ),
      ),
    );
  }
}

// ============================================
// FORMULARIO DEL BUZÓN
// ============================================

class _BuzonForm extends StatefulWidget {
  const _BuzonForm();

  @override
  State<_BuzonForm> createState() => _BuzonFormState();
}

class _BuzonFormState extends State<_BuzonForm> {
  // Controlador
  final _mensajeController = TextEditingController();

  // Estado del formulario
  bool _isSending = false;

  // Errores de validación por campo
  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_mensajeController.text.trim().isEmpty) {
      errors[_FormFields.mensaje] = _ValidationMessages.mensajeRequired;
    }

    setState(() => _fieldErrors = errors);
    return errors.isEmpty;
  }

  String _buildValidationErrorMessage() {
    if (_fieldErrors.isEmpty) return '';

    final missingFields = _fieldErrors.keys
        .map((key) => _FieldLabels.map[key] ?? key)
        .toList();

    return _ValidationMessages.buildAggregateError(missingFields);
  }

  // ============================================
  // CONSTRUCCIÓN DEL PAYLOAD
  // ============================================

  Map<String, dynamic> _buildPayload(
    String username,
    String fullName,
    String email,
  ) {
    return {
      'data': {
        'user': username,
        'fullName': fullName,
        'email': email,
        'message': _mensajeController.text.trim(),
        'date': DateTime.now().toIso8601String(),
      },
    };
  }

  // ============================================
  // OBTENCIÓN DE DATOS DE USUARIO
  // ============================================

  (String username, String fullName, String email) _getUserData() {
    final userState = context.read<UserCubit>().state;

    if (userState is UserLoaded) {
      return (userState.username, userState.fullName, userState.email);
    }

    return (
      _UserDefaults.username,
      _UserDefaults.fullName,
      _UserDefaults.email,
    );
  }

  // ============================================
  // ENVÍO DEL MENSAJE
  // ============================================

  Future<void> _handleEnviar() async {
    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    setState(() => _isSending = true);

    try {
      await _sendMessage();
      _handleSuccessfulSubmission();
    } catch (e) {
      _handleSubmissionError();
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showValidationError() {
    final errorMessage = _buildValidationErrorMessage();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final (username, fullName, email) = _getUserData();
    final payload = _buildPayload(username, fullName, email);

    await JsonSender.sendToMake(
      payload,
      endpoint: _BuzonEndpoints.makeWebhook,
    );
  }

  void _handleSuccessfulSubmission() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_StatusMessages.messageSent),
        backgroundColor: AppColors.success,
      ),
    );

    _clearForm();
    Navigator.of(context).pop();
  }

  void _handleSubmissionError() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_StatusMessages.messageError),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _clearForm() {
    _mensajeController.clear();
    setState(() => _fieldErrors = {});
  }

  // ============================================
  // BUILD UI
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitle(context),
        const SizedBox(height: AppSpacing.xl),
        _buildMessageField(),
        const SizedBox(height: AppSpacing.xxl),
        _buildDivider(),
        const SizedBox(height: AppSpacing.xl),
        _buildSubmitButton(),
      ],
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

  Widget _buildMessageField() {
    return CommonMultilineTextField(
      controller: _mensajeController,
      hintText: _UITexts.placeholder,
      errorText: _fieldErrors[_FormFields.mensaje],
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.accent,
      thickness: AppBorderWidth.normal,
    );
  }

  Widget _buildSubmitButton() {
    return PrimaryButton(
      text: _UITexts.submitButton,
      onPressed: _handleEnviar,
      isLoading: _isSending,
    );
  }
}
// frontend/lib/src/features/intrastat/pages/intrastat_page.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/custom_dropdown.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/common_widgets/multi_file_group_picker.dart';
import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/json_sender.dart';

// ============================================
// CONSTANTES
// ============================================

/// Endpoints externos de la aplicación.
class _IntrastatEndpoints {
  static const String makeWebhook =
      'https://hook.eu2.make.com/xbr3mq37kymiry4vl1e9xh16k5z2ooly';
}

/// Tipos de documento disponibles.
class _DocumentTypes {
  static const String compra = 'COMPRA';
  static const String venta = 'VENTA';

  static const List<String> all = [compra, venta];
}

/// Tipos de operación financiera disponibles.
class _OperationTypes {
  static const String cobro = 'COBRO';
  static const String abono = 'ABONO';

  static const List<String> all = [cobro, abono];
}

/// Extensiones permitidas para archivos PDF.
class _PdfExtensions {
  static const List<String> allowed = ['pdf'];
}

/// Assets de iconos.
class _IconAssets {
  static const String pdf = 'assets/component_icons/pdf_icon.svg';
  static const String watermark = 'assets/dashboard_icons/intrastat.svg';
}

/// Configuración del watermark.
class _WatermarkConfig {
  static const Offset offset = Offset(-50, -10);
}

/// Claves de campos del formulario.
class _FormFields {
  static const String tipoDocumento = 'tipo_documento';
  static const String tipoOperacion = 'tipo_operacion';
  static const String archivos = 'archivos';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.tipoDocumento: 'Tipo de Documento',
    _FormFields.tipoOperacion: 'Tipo',
    _FormFields.archivos: 'Facturas PDF',
  };
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String tipoDocumentoRequired =
      'Selecciona un tipo de operación.';
  static const String tipoOperacionRequired =
      'Selecciona un tipo de operación (ABONO/COBRO).';
  static const String archivosRequired =
      'Debes seleccionar al menos un archivo PDF.';

  static String buildAggregateError(List<String> missingFields) {
    return 'Faltan los campos: ${missingFields.join(', ')}.';
  }
}

/// Mensajes de estado.
class _StatusMessages {
  static const String preparing = 'Preparando envío...';
  static const String allPdfsUploaded = 'Todos los PDFs subidos correctamente';
  static const String uploadError = 'Error subiendo PDFs';
  static const String sendingNotification = 'Enviando notificación...';
  static const String intrastatProcessed = 'Intrastat procesado correctamente';
  static const String processError = 'Error en el proceso';
  static const String ready = 'Listo';

  static String uploadingMultiplePdfs(int count) {
    return 'Subiendo $count PDF(s)...';
  }

  static String uploadingProgress(double progress) {
    return 'Subiendo PDFs: ${(progress * 100).toStringAsFixed(0)}%';
  }

  static String partialUploadSuccess(int successful, int total) {
    return 'Subidos $successful de $total PDF(s). Algunos fallaron.';
  }

  static String partialUploadResult(int successful, int failed) {
    return '$successful PDF(s) subidos correctamente. $failed fallaron.';
  }
}

/// Claves para acceder a datos del response.
class _ResponseKeys {
  static const String exitosos = 'exitosos';
  static const String fallidos = 'fallidos';
  static const String id = 'id';
  static const String tipo = 'tipo';
  static const String tipoOperacion = 'tipo_operacion';
  static const String idsPdfs = 'ids_pdfs';
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

/// Tamaños de fuente personalizados.
class _CustomFontSizes {
  static const double errorText = 12.0;
  static const double progressText = 12.0;
  static const double statusText = 13.0;
}

/// Textos de la interfaz.
class _UITexts {
  static const String title = 'INTRASTAT';
  static const String tipoDocumentoLabel = 'Tipo de Documento';
  static const String tipoOperacionLabel = 'Tipo';
  static const String facturasLabel = 'Facturas (PDF)';
  static const String submitButton = 'Enviar';
  static const String submitButtonLoading = 'Enviando...';
}

/// Colores de snackbar según resultado.
class _SnackbarColors {
  static const Color partialSuccess = Colors.orange;
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class IntrastatPage extends StatelessWidget {
  const IntrastatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: ViewportWatermarkWidget(
        asset: _IconAssets.watermark,
        sizeFactor: isMobile
            ? _ResponsiveDimensions.mobileWatermarkSizeFactor
            : _ResponsiveDimensions.desktopWatermarkSizeFactor,
        offset: _WatermarkConfig.offset,
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
                  child: const _IntrastatForm(),
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
// FORMULARIO DE INTRASTAT
// ============================================

class _IntrastatForm extends StatefulWidget {
  const _IntrastatForm();

  @override
  State<_IntrastatForm> createState() => _IntrastatFormState();
}

class _IntrastatFormState extends State<_IntrastatForm> {
  // Estado del formulario
  String? _tipoDocumentoSeleccionado;
  String? _tipoOperacionSeleccionado;
  List<PlatformFile> _archivosPDF = [];

  // Estado de la subida
  bool _isSending = false;
  bool _isUploadingPdfs = false;
  double _uploadProgress = 0.0;
  String _statusMsg = '';
  List<String> _idsPdfs = [];

  // Errores de validación por campo
  Map<String, String?> _fieldErrors = {};

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_tipoDocumentoSeleccionado == null ||
        _tipoDocumentoSeleccionado!.trim().isEmpty) {
      errors[_FormFields.tipoDocumento] =
          _ValidationMessages.tipoDocumentoRequired;
    }

    if (_tipoOperacionSeleccionado == null ||
        _tipoOperacionSeleccionado!.trim().isEmpty) {
      errors[_FormFields.tipoOperacion] =
          _ValidationMessages.tipoOperacionRequired;
    }

    if (_archivosPDF.isEmpty) {
      errors[_FormFields.archivos] = _ValidationMessages.archivosRequired;
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
  // SUBIDA DE PDFs
  // ============================================

  Future<Map<String, dynamic>> _uploadPdfs() async {
    setState(() {
      _isUploadingPdfs = true;
      _uploadProgress = 0.0;
      _statusMsg = _StatusMessages.uploadingMultiplePdfs(_archivosPDF.length);
    });

    try {
      final response = await DioClient.uploadMultiplePedidoPdfs(
        files: _archivosPDF,
        marca: _tipoDocumentoSeleccionado!,
        onSendProgress: _updateUploadProgress,
      );

      final uploadResult = Map<String, dynamic>.from(response.data as Map);
      _processUploadResult(uploadResult);

      return uploadResult;
    } catch (e) {
      _handleUploadError(e);
      rethrow;
    } finally {
      setState(() {
        _isUploadingPdfs = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _updateUploadProgress(int sent, int total) {
    if (total > 0) {
      setState(() => _uploadProgress = sent / total);
    }
  }

  void _processUploadResult(Map<String, dynamic> uploadResult) {
    final exitosos = uploadResult[_ResponseKeys.exitosos] as List? ?? [];
    final fallidos = uploadResult[_ResponseKeys.fallidos] as List? ?? [];

    _idsPdfs = exitosos.map((e) => e[_ResponseKeys.id] as String).toList();

    if (fallidos.isNotEmpty) {
      setState(() {
        _statusMsg = _StatusMessages.partialUploadSuccess(
          exitosos.length,
          _archivosPDF.length,
        );
      });
    } else {
      setState(() => _statusMsg = _StatusMessages.allPdfsUploaded);
    }
  }

  void _handleUploadError(Object error) {
    setState(() => _statusMsg = _StatusMessages.uploadError);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_StatusMessages.uploadError}: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ============================================
  // CONSTRUCCIÓN DEL PAYLOAD
  // ============================================

  Map<String, dynamic> _buildPayload() {
    return {
      'data': {
        _ResponseKeys.tipo: _tipoDocumentoSeleccionado,
        _ResponseKeys.tipoOperacion: _tipoOperacionSeleccionado,
        _ResponseKeys.idsPdfs: _idsPdfs,
      },
    };
  }

  // ============================================
  // ENVÍO A MAKE
  // ============================================

  Future<void> _sendToMake() async {
    setState(() => _statusMsg = _StatusMessages.sendingNotification);

    final payload = _buildPayload();

    await JsonSender.sendToMake(
      payload,
      endpoint: _IntrastatEndpoints.makeWebhook,
    );
  }

  // ============================================
  // MANEJO DEL ENVÍO COMPLETO
  // ============================================

  Future<void> _handleEnviar() async {
    if (!_validateFields()) {
      _showValidationError();
      return;
    }

    setState(() {
      _isSending = true;
      _statusMsg = _StatusMessages.preparing;
    });

    try {
      final uploadResult = await _uploadPdfs();
      await _sendToMake();
      _handleSuccessfulSubmission(uploadResult);
    } catch (e) {
      _handleSubmissionError(e);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showValidationError() {
    final errorMessage = _buildValidationErrorMessage();
    setState(() => _statusMsg = errorMessage);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
    }
  }

  void _handleSuccessfulSubmission(Map<String, dynamic> uploadResult) {
    if (!mounted) return;

    final (message, color) = _buildSuccessMessage(uploadResult);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));

    _clearForm();
    Navigator.of(context).pop();
  }

  (String message, Color color) _buildSuccessMessage(
    Map<String, dynamic> uploadResult,
  ) {
    final exitosos = uploadResult[_ResponseKeys.exitosos] as List? ?? [];
    final fallidos = uploadResult[_ResponseKeys.fallidos] as List? ?? [];

    if (fallidos.isEmpty) {
      return (_StatusMessages.intrastatProcessed, AppColors.success);
    }

    final message = _StatusMessages.partialUploadResult(
      exitosos.length,
      fallidos.length,
    );
    return (message, _SnackbarColors.partialSuccess);
  }

  void _handleSubmissionError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_StatusMessages.processError}: $error'),
        backgroundColor: AppColors.error,
      ),
    );

    setState(() => _statusMsg = _StatusMessages.processError);
  }

  void _clearForm() {
    setState(() {
      _tipoDocumentoSeleccionado = null;
      _tipoOperacionSeleccionado = null;
      _archivosPDF = [];
      _statusMsg = _StatusMessages.ready;
      _fieldErrors = {};
    });
  }

  // ============================================
  // BUILD UI
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        const SizedBox(height: AppSpacing.xl),
        _buildTipoDocumentoField(),
        const SizedBox(height: AppSpacing.xl),
        _buildTipoOperacionField(),
        const SizedBox(height: AppSpacing.xl),
        _buildArchivosField(),
        _buildFieldError(_FormFields.archivos),
        const SizedBox(height: AppSpacing.large),
        if (_isUploadingPdfs) _buildUploadProgress(),
        const SizedBox(height: AppSpacing.large),
        _buildDivider(),
        const SizedBox(height: AppSpacing.medium),
        if (_statusMsg.isNotEmpty) _buildStatusMessage(),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Center(
      child: Text(
        _UITexts.title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: AppFontWeights.bold),
      ),
    );
  }

  Widget _buildTipoDocumentoField() {
    return CustomDropdown(
      label: _UITexts.tipoDocumentoLabel,
      items: _DocumentTypes.all,
      selectedValue: _tipoDocumentoSeleccionado,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _tipoDocumentoSeleccionado = value),
      errorText: _fieldErrors[_FormFields.tipoDocumento],
    );
  }

  Widget _buildTipoOperacionField() {
    return CustomDropdown(
      label: _UITexts.tipoOperacionLabel,
      items: _OperationTypes.all,
      selectedValue: _tipoOperacionSeleccionado,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _tipoOperacionSeleccionado = value),
      errorText: _fieldErrors[_FormFields.tipoOperacion],
    );
  }

  Widget _buildArchivosField() {
    return MultiFileGroupPicker(
      groupTitle: _UITexts.facturasLabel,
      iconAssetPath: _IconAssets.pdf,
      allowedExtensions: _PdfExtensions.allowed,
      selectedFiles: _archivosPDF,
      onFilesSelected: (files) => setState(() => _archivosPDF = files),
    );
  }

  Widget _buildFieldError(String fieldKey) {
    final error = _fieldErrors[fieldKey];
    if (error == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small),
      child: Text(
        error,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: _CustomFontSizes.errorText,
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      children: [
        LinearProgressIndicator(value: _uploadProgress),
        const SizedBox(height: AppSpacing.small),
        Text(
          _StatusMessages.uploadingProgress(_uploadProgress),
          style: const TextStyle(
            fontSize: _CustomFontSizes.progressText,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.accent,
      thickness: AppBorderWidth.normal,
    );
  }

  Widget _buildStatusMessage() {
    final isError = _statusMsg.toLowerCase().contains('error');

    return Column(
      children: [
        Text(
          _statusMsg,
          style: TextStyle(
            fontSize: _CustomFontSizes.statusText,
            color: isError ? AppColors.error : AppColors.text,
            fontWeight: AppFontWeights.medium,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return PrimaryButton(
      text: _isSending ? _UITexts.submitButtonLoading : _UITexts.submitButton,
      onPressed: _handleEnviar,
      isLoading: _isSending,
    );
  }
}

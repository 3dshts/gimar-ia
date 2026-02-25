// frontend/lib/src/features/inventario/pages/inventario_page.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/user/user_cubit.dart';
import '../../../core/user/user_state.dart';
import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/custom_dropdown.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/common_widgets/multi_file_group_picker.dart';
import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/json_sender.dart';
import '../../../core/network/dio_client.dart';

// ============================================
// VARIABLES GLOBALES
// ============================================

int _archivosSubidos = 0;
int _totalArchivos = 0;

/// Endpoints externos de la aplicación.
class _InventarioEndpoints {
  static const String makeWebhook =
      'https://hook.eu2.make.com/cprvv4so3nj10uq4egxg98asslq60rfz';
}

/// Extensiones permitidas para archivos PDF.
class _PdfExtensions {
  static const List<String> allowed = ['pdf'];
}

/// Assets de iconos.
class _IconAssets {
  static const String pdf = 'assets/component_icons/pdf_icon.svg';
  static const String watermark = 'assets/dashboard_icons/inventario.svg';
}

/// Opciones de Sección.
class _SeccionOptions {
  static const String aparado = 'APARADO';
  static const String mecanica = 'MECÁNICA';
  static const String almacen = 'ALMACÉN';
  static const String pieles = 'PIELES';
  static const String preparado = 'PREPARADO';
  static const String oficina = 'OFICINA';

  static const List<String> all = [
    aparado,
    mecanica,
    almacen,
    pieles,
    preparado,
    oficina,
  ];
}

/// Opciones de Cliente.
class _ProveedorOptions {
  static const String ninguno = 'NINGUNO';
  static const String intracuer = 'INTRACUER';
  static const String eldaplant = 'ELDAPLANT';
  static const String plantillasHernandez = 'PLANTILLAS HERNÁNDEZ';
  static const String prefabricadosContinental = 'PREFABRICADOS CONTINENTAL';
  static const String reecor = 'REECOR PLANTAS MOLDEADAS';
  static const String revecurt = 'REVECURT';
  static const String suelasLaura = 'SUELAS LAURA';
  static const String tecnotac = 'TECNOTAC';

  static const List<String> all = [
    ninguno,
    intracuer,
    eldaplant,
    plantillasHernandez,
    prefabricadosContinental,
    reecor,
    revecurt,
    suelasLaura,
    tecnotac,
  ];
}

/// Claves de campos del formulario.
class _FormFields {
  static const String seccion = 'seccion';
  static const String proveedor = 'proveedor';
  static const String archivos = 'archivos';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.seccion: 'Sección',
    _FormFields.proveedor: 'Proveedor',
    _FormFields.archivos: 'Facturas PDF',
  };
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String seccionRequired = 'Selecciona una sección.';
  static const String proveedorRequired = 'Selecciona un proveedor.';
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
  static const String inventarioSent = 'Inventario enviado correctamente';
  static const String sendError = 'Error al enviar el inventario';
  static const String ready = 'Listo';

  static String partialUploadSuccess(int successful, int total) {
    return 'Subidos $successful de $total PDF(s). Algunos fallaron.';
  }

  static String uploadingBatchProgress(int completados, int total) {
    return 'Subiendo $completados de $total PDF(s)...';
  }
}

/// Claves para acceder a datos del response.
class _ResponseKeys {
  static const String exitosos = 'exitosos';
  static const String fallidos = 'fallidos';
  static const String id = 'id';
  static const String seccion = 'seccion';
  static const String proveedor = 'proveedor';
  static const String idsPdfs = 'ids_pdfs';
  static const String email = 'email';
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
  static const String title = 'INVENTARIO';
  static const String seccionLabel = 'Sección';
  static const String proveedorLabel = 'Proveedor';
  static const String facturasLabel = 'Facturas (PDF)';
  static const String submitButton = 'Enviar';
  static const String submitButtonLoading = 'Enviando...';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class InventarioPage extends StatelessWidget {
  const InventarioPage({super.key});

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
                  child: const _InventarioForm(),
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
// FORMULARIO DE INVENTARIO
// ============================================

class _InventarioForm extends StatefulWidget {
  const _InventarioForm();

  @override
  State<_InventarioForm> createState() => _InventarioFormState();
}

class _InventarioFormState extends State<_InventarioForm> {
  // Estado del formulario
  String? _seccionSeleccionada;
  String? _proveedorSeleccionado;
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
  // CARGAR EMAIL DEL USUARIO
  // ============================================

  String _getUserEmail() {
    final userState = context.read<UserCubit>().state;

    if (userState is UserLoaded) {
      return userState.email;
    }

    return '';
  }

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_seccionSeleccionada == null || _seccionSeleccionada!.trim().isEmpty) {
      errors[_FormFields.seccion] = _ValidationMessages.seccionRequired;
    }

    if (_proveedorSeleccionado == null ||
        _proveedorSeleccionado!.trim().isEmpty) {
      errors[_FormFields.proveedor] = _ValidationMessages.proveedorRequired;
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
      _totalArchivos = _archivosPDF.length;
      _archivosSubidos = 0;
      _statusMsg = _StatusMessages.uploadingBatchProgress(
        0,
        _archivosPDF.length,
      );
    });

    try {
      final result = await DioClient.uploadInventarioPdfs(
        files: _archivosPDF,
        onSendProgress: _updateUploadProgress,
        onBatchProgress: (completados, total) {
          setState(() {
            _archivosSubidos = completados;
            _statusMsg = _StatusMessages.uploadingBatchProgress(
              completados,
              total,
            );
          });
        },
      );

      _processUploadResult(result);
      return result;
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

    _idsPdfs = exitosos
        .map((item) => item[_ResponseKeys.id] as String)
        .toList();

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
        _ResponseKeys.seccion: _seccionSeleccionada,
        _ResponseKeys.proveedor: _proveedorSeleccionado,
        _ResponseKeys.idsPdfs: _idsPdfs,
        _ResponseKeys.email: _getUserEmail(),
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
      endpoint: _InventarioEndpoints.makeWebhook,
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
      await _uploadPdfs();
      await _sendToMake();
      _handleSuccessfulSubmission();
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

  void _handleSuccessfulSubmission() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_StatusMessages.inventarioSent),
        backgroundColor: AppColors.success,
      ),
    );

    _clearForm();
    Navigator.of(context).pop();
  }

  void _handleSubmissionError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_StatusMessages.sendError}: $error'),
        backgroundColor: AppColors.error,
      ),
    );

    setState(() => _statusMsg = _StatusMessages.sendError);
  }

  void _clearForm() {
    setState(() {
      _seccionSeleccionada = null;
      _proveedorSeleccionado = null;
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
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        const SizedBox(height: AppSpacing.xl),
        _buildSeccionClienteFields(isMobile),
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

  Widget _buildSeccionClienteFields(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildSeccionField(),
          const SizedBox(height: AppSpacing.large),
          _buildProveedorField(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildSeccionField()),
        const SizedBox(width: AppSpacing.large),
        Expanded(child: _buildProveedorField()),
      ],
    );
  }

  Widget _buildSeccionField() {
    return CustomDropdown(
      label: _UITexts.seccionLabel,
      items: _SeccionOptions.all,
      selectedValue: _seccionSeleccionada,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _seccionSeleccionada = value),
      errorText: _fieldErrors[_FormFields.seccion],
    );
  }

  Widget _buildProveedorField() {
    return CustomDropdown(
      label: _UITexts.proveedorLabel,
      items: _ProveedorOptions.all,
      selectedValue: _proveedorSeleccionado,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _proveedorSeleccionado = value),
      errorText: _fieldErrors[_FormFields.proveedor],
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
          _StatusMessages.uploadingBatchProgress(
            _archivosSubidos,
            _totalArchivos,
          ),
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

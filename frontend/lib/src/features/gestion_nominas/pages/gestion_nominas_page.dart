// frontend/lib/src/features/gestion_nominas/pages/gestion_nominas_page.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/custom_dropdown.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/common_widgets/single_file_picker.dart';
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
class _NominasEndpoints {
  static const String makeWebhook =
      'https://hook.eu2.make.com/a12clkvpeji58xeivfxit86i3og123pp';
}

/// Extensiones permitidas para archivos Excel.
class _ExcelExtensions {
  static const List<String> allowed = ['xls', 'xlsx', 'xlsm'];
}

/// Assets de iconos.
class _IconAssets {
  static const String excel = 'assets/component_icons/excel_icon.svg';
  static const String watermark = 'assets/dashboard_icons/gestor_nominas.svg';
}

/// Claves de campos del formulario.
class _FormFields {
  static const String year = 'year';
  static const String month = 'month';
  static const String resumen = 'resumen';
  static const String detalle1 = 'detalle1';
  static const String detalle2 = 'detalle2';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.year: 'Año',
    _FormFields.month: 'Mes',
    _FormFields.resumen: 'Nóminas (Excel)',
    _FormFields.detalle1: 'Resúmenes (Excel)',
    _FormFields.detalle2: 'Retenciones (Excel)',
  };
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String yearRequired = 'Selecciona un año.';
  static const String monthRequired = 'Selecciona un mes.';
  static const String resumenRequired =
      'Debes seleccionar el archivo de nóminas.';
  static const String detalle1Required =
      'Debes seleccionar al menos un archivo de resúmenes.';
  static const String detalle2Required =
      'Debes seleccionar al menos un archivo de retenciones.';

  static String buildAggregateError(List<String> missingFields) {
    return 'Faltan los campos: ${missingFields.join(', ')}.';
  }
}

/// Mensajes de estado.
class _StatusMessages {
  static const String preparing = 'Preparando envío...';
  static const String uploadingFiles = 'Subiendo archivo(s) Excel...';
  static const String uploadError = 'Error subiendo archivos';
  static const String sendingNotification = 'Enviando notificación a Make...';
  static const String automationStarted =
      'Automatización iniciada en Make correctamente.';
  static const String processError = 'Error en el proceso';
  static const String ready = 'Listo';

  static String uploadingMultipleFiles(int count) {
    return 'Subiendo $count archivo(s) Excel...';
  }

  static String uploadingProgress(double progress) {
    return 'Subiendo archivos: ${(progress * 100).toStringAsFixed(0)}%';
  }
}

/// Configuración de años disponibles.
class _YearConfig {
  static const int minYear = 2020;

  static List<String> generateYears() {
    final currentYear = DateTime.now().year;
    return [
      for (int i = currentYear; i >= minYear; i--) i.toString(),
    ];
  }
}

/// Lista de meses del año.
class _MonthsList {
  static const List<String> all = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
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
  static const double statusText = 13.0;
}

/// Textos de la interfaz.
class _UITexts {
  static const String title = 'GESTOR NÓMINAS';
  static const String yearLabel = 'Año';
  static const String monthLabel = 'Mes';
  static const String resumenLabel = 'Nóminas (Excel)';
  static const String detalle1Label = 'Resúmenes (Excel)';
  static const String detalle2Label = 'Retenciones (Excel)';
  static const String submitButton = 'Enviar';
  static const String submitButtonLoading = 'Enviando...';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class GestionNominasPage extends StatelessWidget {
  const GestionNominasPage({super.key});

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
                  child: const _NominasForm(),
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
// FORMULARIO DE NÓMINAS
// ============================================

class _NominasForm extends StatefulWidget {
  const _NominasForm();

  @override
  State<_NominasForm> createState() => _NominasFormState();
}

class _NominasFormState extends State<_NominasForm> {
  // Estado del formulario
  String? _selectedYear;
  String? _selectedMonth;
  PlatformFile? _archivoResumen;
  List<PlatformFile> _archivoDetalle1 = [];
  List<PlatformFile> _archivoDetalle2 = [];

  // Estado de la subida
  Map<String, dynamic>? _uploadResult;
  bool _isSending = false;
  bool _isUploadingFiles = false;
  double _uploadProgress = 0.0;
  String _statusMsg = '';

  // Errores de validación por campo
  Map<String, String?> _fieldErrors = {};

  // Listas precalculadas
  late final List<String> _years = _YearConfig.generateYears();

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_selectedYear == null || _selectedYear!.trim().isEmpty) {
      errors[_FormFields.year] = _ValidationMessages.yearRequired;
    }

    if (_selectedMonth == null || _selectedMonth!.trim().isEmpty) {
      errors[_FormFields.month] = _ValidationMessages.monthRequired;
    }

    if (_archivoResumen == null) {
      errors[_FormFields.resumen] = _ValidationMessages.resumenRequired;
    }

    if (_archivoDetalle1.isEmpty) {
      errors[_FormFields.detalle1] = _ValidationMessages.detalle1Required;
    }

    if (_archivoDetalle2.isEmpty) {
      errors[_FormFields.detalle2] = _ValidationMessages.detalle2Required;
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
  // SUBIDA DE ARCHIVOS
  // ============================================

  Future<Map<String, dynamic>> _uploadFiles() async {
    setState(() {
      _isUploadingFiles = true;
      _uploadProgress = 0.0;
      final totalFiles = 1 + _archivoDetalle1.length + _archivoDetalle2.length;
      _statusMsg = _StatusMessages.uploadingMultipleFiles(totalFiles);
    });

    try {
      final response = await DioClient.uploadExcelsNomina(
        archivoResumen: _archivoResumen!,
        archivosDetalle1: _archivoDetalle1,
        archivosDetalle2: _archivoDetalle2,
        anio: _selectedYear!,
        mes: _selectedMonth!,
        onSendProgress: _updateUploadProgress,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      _handleUploadError(e);
      rethrow;
    } finally {
      setState(() {
        _isUploadingFiles = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _updateUploadProgress(int sent, int total) {
    if (total > 0) {
      setState(() => _uploadProgress = sent / total);
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

  Map<String, dynamic> _buildPayload(Map<String, dynamic> uploadResult) {
    return {
      'data': {
        'id_excel_resumen': uploadResult['id_excel_resumen'],
        'ids_retenciones': uploadResult['ids_retenciones'] ?? [],
        'ids_nominas': uploadResult['ids_nominas'] ?? [],
      },
    };
  }

  // ============================================
  // ENVÍO A MAKE
  // ============================================

  Future<void> _sendToMake(Map<String, dynamic> uploadResult) async {
    setState(() => _statusMsg = _StatusMessages.sendingNotification);

    final payload = _buildPayload(uploadResult);

    await JsonSender.sendToMake(
      payload,
      endpoint: _NominasEndpoints.makeWebhook,
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
      final uploadResult = await _uploadFiles();
      setState(() => _uploadResult = uploadResult);

      await _sendToMake(uploadResult);
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
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleSuccessfulSubmission() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_StatusMessages.automationStarted),
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
        content: Text('${_StatusMessages.processError}: $error'),
        backgroundColor: AppColors.error,
      ),
    );

    setState(() => _statusMsg = _StatusMessages.processError);
  }

  void _clearForm() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _archivoResumen = null;
      _archivoDetalle1 = [];
      _archivoDetalle2 = [];
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
        _buildYearMonthFields(isMobile),
        const SizedBox(height: AppSpacing.xl),
        _buildResumenField(),
        _buildFieldError(_FormFields.resumen),
        const SizedBox(height: AppSpacing.xl),
        _buildDetalle1Field(),
        _buildFieldError(_FormFields.detalle1),
        const SizedBox(height: AppSpacing.xl),
        _buildDetalle2Field(),
        _buildFieldError(_FormFields.detalle2),
        const SizedBox(height: AppSpacing.large),
        if (_isUploadingFiles) _buildUploadProgress(),
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
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: AppFontWeights.bold,
            ),
      ),
    );
  }

  Widget _buildYearMonthFields(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildYearField(),
          const SizedBox(height: AppSpacing.large),
          _buildMonthField(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildYearField()),
        const SizedBox(width: AppSpacing.large),
        Expanded(child: _buildMonthField()),
      ],
    );
  }

  Widget _buildYearField() {
    return CustomDropdown(
      label: _UITexts.yearLabel,
      items: _years,
      selectedValue: _selectedYear,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _selectedYear = value),
      errorText: _fieldErrors[_FormFields.year],
    );
  }

  Widget _buildMonthField() {
    return CustomDropdown(
      label: _UITexts.monthLabel,
      items: _MonthsList.all,
      selectedValue: _selectedMonth,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _selectedMonth = value),
      errorText: _fieldErrors[_FormFields.month],
    );
  }

  Widget _buildResumenField() {
    return SingleFilePicker(
      label: _UITexts.resumenLabel,
      iconAssetPath: _IconAssets.excel,
      allowedExtensions: _ExcelExtensions.allowed,
      selectedFile: _archivoResumen,
      onFileSelected: (file) => setState(() => _archivoResumen = file),
    );
  }

  Widget _buildDetalle1Field() {
    return MultiFileGroupPicker(
      groupTitle: _UITexts.detalle1Label,
      iconAssetPath: _IconAssets.excel,
      allowedExtensions: _ExcelExtensions.allowed,
      selectedFiles: _archivoDetalle1,
      onFilesSelected: (files) => setState(() => _archivoDetalle1 = files),
    );
  }

  Widget _buildDetalle2Field() {
    return MultiFileGroupPicker(
      groupTitle: _UITexts.detalle2Label,
      iconAssetPath: _IconAssets.excel,
      allowedExtensions: _ExcelExtensions.allowed,
      selectedFiles: _archivoDetalle2,
      onFilesSelected: (files) => setState(() => _archivoDetalle2 = files),
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
            fontSize: _CustomFontSizes.errorText,
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
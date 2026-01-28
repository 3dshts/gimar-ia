// frontend/lib/src/features/alertas_produccion/pages/alertas_produccion_page.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/common_multiline_text_field.dart';
import '../../../core/common_widgets/custom_dropdown.dart';
import '../../../core/common_widgets/decorative_corner_icon.dart';
import '../../../core/common_widgets/single_file_picker.dart';
import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/common_text_field.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/json_sender.dart';
import '../../../core/user/user_cubit.dart';
import '../../../core/user/user_state.dart';
import '../../../core/network/dio_client.dart';

// ============================================
// CONSTANTES
// ============================================

/// Configuración para compresión de imágenes.
class _ImageCompressionConfig {
  static const int defaultQuality = 80;
  static const int maxWidth = 1920;
  static const int kilobyteDivisor = 1024;
}

/// Endpoints externos de la aplicación.
class _AlertasEndpoints {
  static const String makeWebhook =
      'https://hook.eu2.make.com/mg7de7k98iyju6xvwanuwik8eurusrs6';
}

/// Secciones disponibles para alertas de producción.
class _Secciones {
  static const List<String> all = [
    'Aparado',
    'Cortado',
    'Montado',
    'Envasa',
    'Almacén',
  ];
}

/// Extensiones permitidas para imágenes.
class _ImageExtensions {
  static const List<String> allowed = ['jpg', 'jpeg', 'png'];
}

/// Claves de campos del formulario.
class _FormFields {
  static const String seccion = 'seccion';
  static const String descripcion = 'descripcion';
  static const String pedido = 'pedido';
  static const String modelo = 'modelo';
  static const String operario = 'operario';
  static const String imagen = 'imagen';
}

/// Labels legibles de los campos.
class _FieldLabels {
  static const Map<String, String> map = {
    _FormFields.seccion: 'Sección',
    _FormFields.descripcion: 'Descripción',
    _FormFields.pedido: 'Pedido',
    _FormFields.modelo: 'Modelo',
    _FormFields.operario: 'Operario',
    _FormFields.imagen: 'Fotografía',
  };
}

/// Mensajes de estado de la aplicación.
class _StatusMessages {
  static const String preparing = 'Preparando envío...';
  static const String uploadingImage = 'Subiendo imagen...';
  static const String imageUploaded = 'Imagen subida correctamente';
  static const String imageUploadError =
      'Error subiendo imagen (continuamos sin imagen)';
  static const String sendingAlert = 'Enviando alerta...';
  static const String alertSent = 'Alerta enviada correctamente';
  static const String alertError = 'Error al enviar alerta';
  static const String ready = 'Listo';
  static const String optimizingImage = 'Optimizando imagen...';
  static const String imageOptimized = 'Imagen optimizada';
  static const String imageOptimizationFailed =
      'No se pudo optimizar la imagen (se usará el original).';
}

/// Mensajes de validación.
class _ValidationMessages {
  static const String seccionRequired = 'Selecciona una sección.';
  static const String descripcionRequired = 'La descripción es obligatoria.';
  static const String pedidoRequired = 'El número de pedido es obligatorio.';
  static const String modeloRequired = 'El modelo es obligatorio.';
  static const String operarioRequired =
      'El nombre del operario es obligatorio.';

  static String buildAggregateError(List<String> missingFields) {
    return 'Faltan los campos: ${missingFields.join(', ')}.';
  }
}

/// Valores por defecto para usuario.
class _UserDefaults {
  static const String username = 'USUARIO';
  static const String fullName = 'CARGANDO';
  static const String email = 'EMAIL';
}

/// Dimensiones responsive.
class _ResponsiveDimensions {
  static const double maxFormWidth = 800.0;
  static const double mobileWatermarkSizeFactor = 0.4;
  static const double desktopWatermarkSizeFactor = 0.5;
  static const double mobileWatermarkSizePx = 240.0;
  static const double desktopWatermarkSizePx = 360.0;
}

/// Formato de imagen de salida.
class _ImageFormat {
  static const String jpgExtension = '.jpg';
}

// ============================================
// PÁGINA PRINCIPAL
// ============================================

class AlertasProduccionPage extends StatelessWidget {
  const AlertasProduccionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < AppBreakpoints.mobile;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: ViewportWatermarkWidget(
        asset: 'assets/dashboard_icons/alertas_produccion.svg',
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
                vertical: isMobile ? AppSpacing.xl : 40.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _ResponsiveDimensions.maxFormWidth,
                  ),
                  child: const _AlertasForm(),
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
// FORMULARIO DE ALERTAS
// ============================================

class _AlertasForm extends StatefulWidget {
  const _AlertasForm();

  @override
  State<_AlertasForm> createState() => _AlertasFormState();
}

class _AlertasFormState extends State<_AlertasForm> {
  // Controladores
  final _descripcionController = TextEditingController();
  final _pedidoController = TextEditingController();
  final _modeloController = TextEditingController();
  final _operarioController = TextEditingController();

  // Estado del formulario
  String? _seccion;
  PlatformFile? _imagen;
  bool _isSending = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  String _statusMsg = '';

  // Errores de validación por campo
  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _descripcionController.dispose();
    _pedidoController.dispose();
    _modeloController.dispose();
    _operarioController.dispose();
    super.dispose();
  }

  // ============================================
  // VALIDACIÓN
  // ============================================

  bool _validateFields() {
    final errors = <String, String?>{};

    if (_seccion == null || _seccion!.trim().isEmpty) {
      errors[_FormFields.seccion] = _ValidationMessages.seccionRequired;
    }
    if (_descripcionController.text.trim().isEmpty) {
      errors[_FormFields.descripcion] =
          _ValidationMessages.descripcionRequired;
    }
    if (_pedidoController.text.trim().isEmpty) {
      errors[_FormFields.pedido] = _ValidationMessages.pedidoRequired;
    }
    if (_modeloController.text.trim().isEmpty) {
      errors[_FormFields.modelo] = _ValidationMessages.modeloRequired;
    }
    if (_operarioController.text.trim().isEmpty) {
      errors[_FormFields.operario] = _ValidationMessages.operarioRequired;
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
  // COMPRESIÓN DE IMÁGENES
  // ============================================

  Future<PlatformFile> _compressImageToJpg(PlatformFile original) async {
    try {
      final bytes = await _getFileBytes(original);
      if (bytes == null) return original;

      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return original;

      final processedImage = _resizeIfNeeded(decodedImage);
      final jpgData = _encodeToJpg(processedImage);
      
      return _createCompressedFile(original.name, jpgData);
    } catch (e) {
      return original;
    }
  }

  Future<Uint8List?> _getFileBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes;
    } else if (file.path != null) {
      return await File(file.path!).readAsBytes();
    }
    return null;
  }

  img.Image _resizeIfNeeded(img.Image image) {
    if (image.width > _ImageCompressionConfig.maxWidth) {
      return img.copyResize(
        image,
        width: _ImageCompressionConfig.maxWidth,
      );
    }
    return image;
  }

  Uint8List _encodeToJpg(img.Image image) {
    return Uint8List.fromList(
      img.encodeJpg(image, quality: _ImageCompressionConfig.defaultQuality),
    );
  }

  PlatformFile _createCompressedFile(String originalName, Uint8List data) {
    final newName = _convertToJpgName(originalName);
    return PlatformFile(
      name: newName,
      size: data.lengthInBytes,
      bytes: data,
    );
  }

  String _convertToJpgName(String name) {
    final dotIndex = name.lastIndexOf('.');
    final baseName = dotIndex > 0 ? name.substring(0, dotIndex) : name;
    return '$baseName${_ImageFormat.jpgExtension}';
  }

  // ============================================
  // SUBIDA DE IMAGEN
  // ============================================

  Future<Map<String, dynamic>?> _uploadImage() async {
    if (_imagen == null) return null;

    setState(() {
      _isUploadingImage = true;
      _uploadProgress = 0.0;
      _statusMsg = _StatusMessages.uploadingImage;
    });

    try {
      final response = await DioClient.uploadImgAlert(
        file: _imagen!,
        onSendProgress: _updateUploadProgress,
      );

      setState(() => _statusMsg = _StatusMessages.imageUploaded);
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      _handleImageUploadError(e);
      return null;
    } finally {
      setState(() {
        _isUploadingImage = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _updateUploadProgress(int sent, int total) {
    if (total > 0) {
      setState(() => _uploadProgress = sent / total);
    }
  }

  void _handleImageUploadError(Object error) {
    setState(() => _statusMsg = _StatusMessages.imageUploadError);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_StatusMessages.imageUploadError}: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ============================================
  // CONSTRUCCIÓN DEL PAYLOAD
  // ============================================

  Map<String, dynamic> _buildPayload(
    String username,
    String fullName,
    String email,
    Map<String, dynamic>? driveMeta,
  ) {
    return {
      'data': {
        'user': username,
        'fullName': fullName,
        'email': email,
        'date': DateTime.now().toIso8601String(),
        'section': _seccion,
        'alert_description': _descripcionController.text.trim(),
        'pedido': _pedidoController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'operario': _operarioController.text.trim(),
        'driveImage': _buildDriveImageData(driveMeta),
      },
    };
  }

  Map<String, dynamic>? _buildDriveImageData(Map<String, dynamic>? driveMeta) {
    if (driveMeta == null) return null;

    return {
      'id': driveMeta['id'],
      'name': driveMeta['name'],
      'mimeType': driveMeta['mimeType'],
      'webViewLink': driveMeta['webViewLink'],
      'webContentLink': driveMeta['webContentLink'],
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
  // ENVÍO DE ALERTA
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
      final driveMeta = await _uploadImage();
      await _sendAlert(driveMeta);
      _handleSuccessfulSubmission();
    } catch (e) {
      _handleSubmissionError();
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

  Future<void> _sendAlert(Map<String, dynamic>? driveMeta) async {
    setState(() => _statusMsg = _StatusMessages.sendingAlert);

    final (username, fullName, email) = _getUserData();
    final payload = _buildPayload(username, fullName, email, driveMeta);

    await JsonSender.sendToMake(
      payload,
      endpoint: _AlertasEndpoints.makeWebhook,
    );
  }

  void _handleSuccessfulSubmission() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_StatusMessages.alertSent),
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
        content: Text(_StatusMessages.alertError),
        backgroundColor: AppColors.error,
      ),
    );

    setState(() => _statusMsg = _StatusMessages.alertError);
  }

  void _clearForm() {
    _descripcionController.clear();
    _pedidoController.clear();
    _modeloController.clear();
    _operarioController.clear();

    setState(() {
      _seccion = null;
      _imagen = null;
      _statusMsg = _StatusMessages.ready;
      _fieldErrors = {};
    });
  }

  // ============================================
  // MANEJO DE SELECCIÓN DE IMAGEN
  // ============================================

  Future<void> _handleImageSelection(PlatformFile file) async {
    setState(() => _statusMsg = _StatusMessages.optimizingImage);

    try {
      final compressed = await _compressImageToJpg(file);
      final sizeInKb = compressed.size / _ImageCompressionConfig.kilobyteDivisor;
      
      setState(() {
        _imagen = compressed;
        _statusMsg =
            '${_StatusMessages.imageOptimized} (${sizeInKb.toStringAsFixed(0)} KB).';
      });
    } catch (e) {
      setState(() {
        _imagen = file;
        _statusMsg = _StatusMessages.imageOptimizationFailed;
      });
    }
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
        _buildSeccionField(),
        const SizedBox(height: AppSpacing.xl),
        _buildDescripcionField(),
        const SizedBox(height: AppSpacing.xl),
        _buildPedidoModeloFields(isMobile),
        const SizedBox(height: AppSpacing.large),
        _buildOperarioField(),
        const SizedBox(height: AppSpacing.xl),
        _buildImageField(),
        const SizedBox(height: AppSpacing.large),
        if (_isUploadingImage) _buildUploadProgress(),
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
        'ALERTAS PRODUCCIÓN',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: AppFontWeights.bold,
            ),
      ),
    );
  }

  Widget _buildSeccionField() {
    return CustomDropdown(
      label: 'Sección de la Empresa',
      items: _Secciones.all,
      selectedValue: _seccion,
      isEnabled: !_isSending,
      onChanged: (value) => setState(() => _seccion = value),
      errorText: _fieldErrors[_FormFields.seccion],
    );
  }

  Widget _buildDescripcionField() {
    return CommonMultilineTextField(
      controller: _descripcionController,
      hintText: 'Describe el problema ocurrido...',
      enabled: !_isSending,
      errorText: _fieldErrors[_FormFields.descripcion],
    );
  }

  Widget _buildPedidoModeloFields(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildPedidoField(),
          const SizedBox(height: AppSpacing.large),
          _buildModeloField(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPedidoField()),
        const SizedBox(width: AppSpacing.large),
        Expanded(child: _buildModeloField()),
      ],
    );
  }

  Widget _buildPedidoField() {
    return CommonTextField(
      controller: _pedidoController,
      label: 'Pedido',
      hintText: 'Número de pedido afectado',
      enabled: !_isSending,
      errorText: _fieldErrors[_FormFields.pedido],
    );
  }

  Widget _buildModeloField() {
    return CommonTextField(
      controller: _modeloController,
      label: 'Modelo',
      hintText: 'Modelo afectado',
      enabled: !_isSending,
      errorText: _fieldErrors[_FormFields.modelo],
    );
  }

  Widget _buildOperarioField() {
    return CommonTextField(
      controller: _operarioController,
      label: 'Operario',
      hintText: 'Nombre del operario responsable',
      enabled: !_isSending,
      errorText: _fieldErrors[_FormFields.operario],
    );
  }

  Widget _buildImageField() {
    return SingleFilePicker(
      label: 'Fotografía del Problema (opcional)',
      iconAssetPath: 'assets/component_icons/image_icon.svg',
      allowedExtensions: _ImageExtensions.allowed,
      selectedFile: _imagen,
      onFileSelected: _handleImageSelection,
      enabled: !_isSending,
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      children: [
        LinearProgressIndicator(value: _uploadProgress),
        const SizedBox(height: AppSpacing.small),
        Text(
          'Subiendo imagen: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: AppFontSizes.small,
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
            fontSize: 13.0,
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
      text: _isSending ? 'Enviando...' : 'Enviar',
      onPressed: _handleEnviar,
      isLoading: _isSending,
    );
  }
}
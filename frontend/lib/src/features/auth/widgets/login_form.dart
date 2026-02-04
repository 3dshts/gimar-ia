// frontend/lib/src/features/auth/widgets/login_form.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widgets/primary_button.dart';
import '../../../core/common_widgets/helpers/responsive_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_logger.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/user/user_cubit.dart';
import '../../dashboard/pages/dashboard_page.dart';

/// Formulario de inicio de sesión de la aplicación.
/// 
/// Maneja:
/// - Autenticación de usuarios
/// - Almacenamiento seguro del token JWT
/// - Carga del estado del usuario en BLoC
/// - Navegación al dashboard tras login exitoso
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final Dio _dio = DioClient.instance;

  /// Realiza la petición de login y gestiona la sesión si es exitosa.
  Future<void> _login() async {
    try {
      ApiLogger.info('Attempting login', 'AUTH');

      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'username': _usernameController.text.trim().toLowerCase(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = response.data['user'];

        ApiLogger.info(
          'Login successful for user: ${user['username']}',
          'AUTH',
        );

        // Guardar token de forma segura
        await StorageService.instance.writeToken(token);

        // Cargar datos del usuario en el estado global
        if (mounted) {
          context.read<UserCubit>().setUser(
                username: user['username'],
                fullName: user['fullName'],
                email: user['email'],
                permissions: user['permissions'] != null
                    ? Map<String, dynamic>.from(user['permissions'])
                    : {},
                isAdmin: user['isAdmin'],
              );

          // Navegar al dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      }
    } on DioException catch (e) {
      ApiLogger.error('Login failed', 'AUTH', e);

      final errorMessage = e.response?.data['message'] ??
          'Error de conexión. Inténtalo de nuevo.';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      color: AppColors.inputBackground,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.large : AppSpacing.xxl,
        vertical: isMobile ? AppSpacing.xxl : 60.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LoginConstants.maxFormWidth,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'IntegrIA',
                style: AppTextStyles.brandTitle(isMobile),
              ),
              Text(
                'GIMAR',
                style: AppTextStyles.brandSubtitle(isMobile),
              ),
              const SizedBox(height: AppSpacing.large),
              const Divider(
                color: AppColors.accent,
                thickness: 3.0,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Inicio de Sesión',
                style: AppTextStyles.sectionTitle(isMobile),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Introduce tu usuario',
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Introduce tu contraseña',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: "INICIAR SESIÓN",
                onPressed: _login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
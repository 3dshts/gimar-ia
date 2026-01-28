// frontend/lib/src/features/auth/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../dashboard/pages/dashboard_page.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_logger.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/user/user_cubit.dart';
import '../../../core/theme/app_theme.dart';
import 'login_page.dart';

/// Página de splash/carga inicial de la aplicación.
/// 
/// Responsabilidades:
/// - Verificar si existe un token JWT almacenado
/// - Validar el token con el backend
/// - Cargar datos del usuario si el token es válido
/// - Navegar al Dashboard o Login según corresponda
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Verifica el estado de autenticación del usuario.
  Future<void> _checkAuthStatus() async {
    ApiLogger.info('Checking authentication status', 'SPLASH');

    final token = await StorageService.instance.readToken();

    // Pequeño delay para mostrar el splash
    await Future.delayed(SplashConstants.initialDelay);

    // Sin token o token expirado
    if (token == null || JwtDecoder.isExpired(token)) {
      ApiLogger.info('No valid token found, redirecting to login', 'SPLASH');
      _navigateToLogin();
      return;
    }

    // Token existe y no está expirado, validar con backend
    try {
      ApiLogger.info('Validating token with backend', 'SPLASH');

      final response = await DioClient.validateTokenWith(token);
      final user = response.data['user'];

      ApiLogger.info(
        'Token validated successfully for user: ${user['username']}',
        'SPLASH',
      );

      if (mounted) {
        // Cargar datos del usuario en el estado global
        context.read<UserCubit>().setUser(
              username: user['username'],
              fullName: user['fullName'],
              email: user['email'],
              permissions: user['permissions'] != null
                  ? Map<String, dynamic>.from(user['permissions'])
                  : {},
              isAdmin: user['isAdmin'],
            );

        // Navegar al Dashboard
        _navigateToDashboard();
      }
    } catch (e) {
      ApiLogger.error('Token validation failed', 'SPLASH', e);

      // Token inválido, eliminar y redirigir a login
      await StorageService.instance.deleteToken();
      _navigateToLogin();
    }
  }

  /// Navega a la pantalla de login.
  void _navigateToLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  /// Navega al dashboard principal.
  void _navigateToDashboard() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
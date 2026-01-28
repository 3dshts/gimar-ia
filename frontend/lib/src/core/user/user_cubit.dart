// lib/src/core/bloc/user_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_state.dart';

/// Cubit que gestiona el estado del usuario autenticado.
///
/// Este cubit es responsable de:
/// - Almacenar y exponer el username, fullName y permisos.
/// - Notificar a la UI cuando cambie la sesión.
/// - Limpiar el estado al cerrar sesión.
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  /// Establece el usuario actual después de validar el token.
  void setUser({
    required String username,
    required String fullName,
    required String email,
    required Map<String, dynamic> permissions,
    required bool isAdmin,
  }) {
    emit(UserLoaded(
      username: username,
      fullName: fullName,
      email: email,
      permissions: permissions,
      isAdmin: isAdmin,
    ));
  }

  /// Limpia el estado del usuario (al cerrar sesión).
  void clearUser() {
    emit(UserInitial());
  }
}

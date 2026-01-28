// lib/src/core/bloc/user_state.dart

/// Clase base para representar los posibles estados del usuario.
abstract class UserState {}

/// Estado inicial: sin sesión activa.
class UserInitial extends UserState {}

/// Estado cuando el usuario ha sido autenticado exitosamente.
class UserLoaded extends UserState {
  final String username;
  final String fullName;
  final String email;
  final Map<String, dynamic> permissions;
  final bool isAdmin;

  UserLoaded({
    required this.username,
    required this.fullName,
    required this.email,
    required this.permissions,
    required this.isAdmin,
  });
}

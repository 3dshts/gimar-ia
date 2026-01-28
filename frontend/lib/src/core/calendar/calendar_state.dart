// lib/src/features/fabricacion/cubit/calendar_state.dart

import '../../core/models/calendar_comment_model.dart';

/// Clase base para representar los posibles estados del calendario.
abstract class CalendarState {}

/// Estado inicial: no se han cargado comentarios aún.
class CalendarInitial extends CalendarState {}

/// Estado de carga: se están obteniendo comentarios del servidor.
class CalendarLoading extends CalendarState {}

/// Estado exitoso: comentarios cargados correctamente.
class CalendarLoaded extends CalendarState {
  final List<CalendarCommentModel> comments;
  final String startDate; // Fecha inicio del rango cargado
  final String endDate;   // Fecha fin del rango cargado

  CalendarLoaded({
    required this.comments,
    required this.startDate,
    required this.endDate,
  });

  /// Copia el estado con algunos campos modificados.
  CalendarLoaded copyWith({
    List<CalendarCommentModel>? comments,
    String? startDate,
    String? endDate,
  }) {
    return CalendarLoaded(
      comments: comments ?? this.comments,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Estado de error: falló la operación.
class CalendarError extends CalendarState {
  final String message;

  CalendarError(this.message);
}
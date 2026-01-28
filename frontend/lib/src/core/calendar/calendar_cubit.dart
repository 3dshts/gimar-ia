// lib/src/features/fabricacion/cubit/calendar_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/calendar_comment_model.dart';
import '../../core/network/dio_client.dart';
import 'calendar_state.dart';

/// Cubit que gestiona el estado del calendario de comentarios.
///
/// Este cubit es responsable de:
/// - Cargar comentarios de un rango de fechas.
/// - Crear nuevos comentarios.
/// - Actualizar comentarios existentes.
/// - Eliminar comentarios.
/// - Mantener caché de los comentarios cargados.
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit() : super(CalendarInitial());

  /// Carga comentarios de un rango de fechas.
  Future<void> loadComments({
    required String startDate,
    required String endDate,
  }) async {
    try {
      emit(CalendarLoading());

      final response = await DioClient.getCalendarComments(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> commentsJson = response.data['data'] ?? [];
        
        final comments = commentsJson
            .map((json) => CalendarCommentModel.fromJson(json))
            .toList();

        emit(CalendarLoaded(
          comments: comments,
          startDate: startDate,
          endDate: endDate,
        ));
      } else {
        emit(CalendarError('Error al cargar comentarios'));
      }
    } catch (e) {
      emit(CalendarError('Error de conexión: ${e.toString()}'));
    }
  }

  /// Crea un nuevo comentario.
  Future<void> createComment({
    required String fecha,
    required String titulo,
    required String comentario,
    required String autorId,
    required String autorNombre,
  }) async {
    try {
      final currentState = state;
      
      emit(CalendarLoading());

      final response = await DioClient.createCalendarComment(
        fecha: fecha,
        titulo: titulo,
        comentario: comentario,
        autorId: autorId,
        autorNombre: autorNombre,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final newComment = CalendarCommentModel.fromJson(response.data['data']);

        // Actualizar la lista de comentarios en el estado
        if (currentState is CalendarLoaded) {
          final updatedComments = [...currentState.comments, newComment];
          
          emit(currentState.copyWith(comments: updatedComments));
        } else {
          // Si no había estado cargado, recargar
          await loadComments(
            startDate: _getMonthStart(fecha),
            endDate: _getMonthEnd(fecha),
          );
        }
      } else {
        emit(CalendarError('Error al crear comentario'));
      }
    } catch (e) {
      emit(CalendarError('Error de conexión: ${e.toString()}'));
    }
  }

  /// Actualiza un comentario existente.
  Future<void> updateComment({
    required String eventId,
    required String titulo,
    required String comentario,
  }) async {
    try {
      final currentState = state;
      
      emit(CalendarLoading());

      final response = await DioClient.updateCalendarComment(
        eventId: eventId,
        titulo: titulo,
        comentario: comentario,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedComment = CalendarCommentModel.fromJson(response.data['data']);

        // Actualizar el comentario en la lista
        if (currentState is CalendarLoaded) {
          final updatedComments = currentState.comments.map((comment) {
            return comment.id == eventId ? updatedComment : comment;
          }).toList();
          
          emit(currentState.copyWith(comments: updatedComments));
        }
      } else {
        emit(CalendarError('Error al actualizar comentario'));
      }
    } catch (e) {
      emit(CalendarError('Error de conexión: ${e.toString()}'));
    }
  }

  /// Elimina un comentario.
  Future<void> deleteComment(String eventId) async {
    try {
      final currentState = state;
      
      emit(CalendarLoading());

      final response = await DioClient.deleteCalendarComment(
        eventId: eventId,
      );

      if (response.statusCode == 200) {
        // Eliminar el comentario de la lista
        if (currentState is CalendarLoaded) {
          final updatedComments = currentState.comments
              .where((comment) => comment.id != eventId)
              .toList();
          
          emit(currentState.copyWith(comments: updatedComments));
        }
      } else {
        emit(CalendarError('Error al eliminar comentario'));
      }
    } catch (e) {
      emit(CalendarError('Error de conexión: ${e.toString()}'));
    }
  }

  /// Limpia el estado del calendario.
  void clearCalendar() {
    emit(CalendarInitial());
  }

  // ============================================
  // MÉTODOS PRIVADOS AUXILIARES
  // ============================================

  /// Obtiene el primer día del mes de una fecha dada.
  String _getMonthStart(String date) {
    final parts = date.split('-');
    return '${parts[0]}-${parts[1]}-01';
  }

  /// Obtiene el último día del mes de una fecha dada.
  String _getMonthEnd(String date) {
    final parts = date.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    
    final lastDay = DateTime(year, month + 1, 0).day;
    return '${parts[0]}-${parts[1]}-${lastDay.toString().padLeft(2, '0')}';
  }
}
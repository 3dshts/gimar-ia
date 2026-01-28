// frontend/lib/src/core/models/calendar_comment_model.dart

/// Modelo que representa un comentario del calendario de producción.
class CalendarCommentModel {
  const CalendarCommentModel({
    required this.id,
    required this.fecha,
    required this.titulo,
    required this.comentario,
    required this.autorId,
    required this.autorNombre,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  final String id;                    // ID del evento en Google Calendar
  final String fecha;                 // Fecha del comentario (YYYY-MM-DD)
  final String titulo;                // Título del comentario
  final String comentario;            // Texto del comentario
  final String autorId;               // ID del autor
  final String autorNombre;           // Nombre completo del autor
  final String fechaCreacion;         // Fecha de creación (ISO 8601)
  final String? fechaModificacion;    // Fecha de última modificación (ISO 8601)

  /// Crea una instancia desde JSON.
  factory CalendarCommentModel.fromJson(Map<String, dynamic> json) {
    return CalendarCommentModel(
      id: (json['id'] as String? ?? '').trim(),
      fecha: (json['fecha'] as String? ?? '').trim(),
      titulo: (json['titulo'] as String? ?? '').trim(),
      comentario: (json['comentario'] as String? ?? '').trim(),
      autorId: (json['autorId'] as String? ?? '').trim(),
      autorNombre: (json['autorNombre'] as String? ?? '').trim(),
      fechaCreacion: (json['fechaCreacion'] as String? ?? '').trim(),
      fechaModificacion: json['fechaModificacion'] as String?,
    );
  }

  /// Convierte a JSON para enviar al backend.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'titulo': titulo,
      'comentario': comentario,
      'autorId': autorId,
      'autorNombre': autorNombre,
      'fechaCreacion': fechaCreacion,
      if (fechaModificacion != null) 'fechaModificacion': fechaModificacion,
    };
  }

  /// Copia el modelo con algunos campos modificados.
  CalendarCommentModel copyWith({
    String? id,
    String? fecha,
    String? titulo,
    String? comentario,
    String? autorId,
    String? autorNombre,
    String? fechaCreacion,
    String? fechaModificacion,
  }) {
    return CalendarCommentModel(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      titulo: titulo ?? this.titulo,
      comentario: comentario ?? this.comentario,
      autorId: autorId ?? this.autorId,
      autorNombre: autorNombre ?? this.autorNombre,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }
}
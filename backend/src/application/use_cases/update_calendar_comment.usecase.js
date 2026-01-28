// backend/src/application/use_cases/update_calendar_comment.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: Actualizar un comentario existente en el calendario.
// -----------------------------------------------------------------------------

export class UpdateCalendarCommentUseCase {
  /**
   * @param {CalendarRepository} calendarRepository Repositorio de Calendar
   */
  constructor(calendarRepository) {
    this.calendarRepository = calendarRepository;
  }

  /**
   * Ejecuta la actualización de un comentario.
   * @param {Object} params
   * @param {string} params.eventId ID del evento en Google Calendar
   * @param {string} params.titulo Nuevo título
   * @param {string} params.comentario Nuevo comentario
   * @returns {Promise<Object>} Comentario actualizado
   */
  async execute({ eventId, titulo, comentario }) {
    // Validaciones
    this._validateUpdateData({ eventId, titulo, comentario });

    const updateData = {
      titulo: titulo.trim(),
      comentario: comentario.trim(),
    };

    const updatedComment = await this.calendarRepository.updateComment(eventId, updateData);

    return updatedComment;
  }

  /**
   * Valida los datos de actualización
   * @private
   */
  _validateUpdateData({ eventId, titulo, comentario }) {
    const errors = [];

    // Validar eventId
    if (!eventId || eventId.trim().length === 0) {
      errors.push('El ID del evento es obligatorio');
    }

    // Validar título
    if (!titulo || titulo.trim().length === 0) {
      errors.push('El título es obligatorio');
    } else if (titulo.trim().length > 200) {
      errors.push('El título no puede superar 200 caracteres');
    }

    // Validar comentario
    if (!comentario || comentario.trim().length === 0) {
      errors.push('El comentario es obligatorio');
    }

    if (errors.length > 0) {
      throw new Error(errors.join(', '));
    }
  }
}
// backend/src/application/use_cases/delete_calendar_comment.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: Eliminar un comentario del calendario.
// -----------------------------------------------------------------------------

export class DeleteCalendarCommentUseCase {
  /**
   * @param {CalendarRepository} calendarRepository Repositorio de Calendar
   */
  constructor(calendarRepository) {
    this.calendarRepository = calendarRepository;
  }

  /**
   * Ejecuta la eliminación de un comentario.
   * @param {Object} params
   * @param {string} params.eventId ID del evento en Google Calendar
   * @returns {Promise<void>}
   */
  async execute({ eventId }) {
    // Validaciones
    if (!eventId || eventId.trim().length === 0) {
      throw new Error('El ID del evento es obligatorio');
    }

    await this.calendarRepository.deleteComment(eventId);
  }
}
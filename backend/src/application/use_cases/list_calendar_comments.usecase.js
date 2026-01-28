// backend/src/application/use_cases/list_calendar_comments.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: Listar comentarios de calendario en un rango de fechas.
// -----------------------------------------------------------------------------

export class ListCalendarCommentsUseCase {
  /**
   * @param {CalendarRepository} calendarRepository Repositorio de Calendar
   */
  constructor(calendarRepository) {
    this.calendarRepository = calendarRepository;
  }

  /**
   * Ejecuta la obtención de comentarios en un rango de fechas.
   * @param {Object} params
   * @param {string} params.startDate Fecha inicio (YYYY-MM-DD)
   * @param {string} params.endDate Fecha fin (YYYY-MM-DD)
   * @returns {Promise<Array>} Array de comentarios
   */
  async execute({ startDate, endDate }) {
    // Validar formato de fechas
    if (!this._isValidDateFormat(startDate) || !this._isValidDateFormat(endDate)) {
      throw new Error('Formato de fecha inválido. Use YYYY-MM-DD');
    }

    // Validar que startDate <= endDate
    if (new Date(startDate) > new Date(endDate)) {
      throw new Error('La fecha de inicio debe ser anterior o igual a la fecha de fin');
    }

    const comments = await this.calendarRepository.listComments(startDate, endDate);

    return comments;
  }

  /**
   * Valida que una fecha tenga formato YYYY-MM-DD
   * @private
   */
  _isValidDateFormat(dateString) {
    const regex = /^\d{4}-\d{2}-\d{2}$/;
    if (!regex.test(dateString)) return false;

    const date = new Date(dateString);
    return date instanceof Date && !isNaN(date);
  }
}
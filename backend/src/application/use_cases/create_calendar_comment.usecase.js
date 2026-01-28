// backend/src/application/use_cases/create_calendar_comment.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: Crear un nuevo comentario en el calendario.
// -----------------------------------------------------------------------------

export class CreateCalendarCommentUseCase {
  /**
   * @param {CalendarRepository} calendarRepository Repositorio de Calendar
   */
  constructor(calendarRepository) {
    this.calendarRepository = calendarRepository;
  }

  /**
   * Ejecuta la creación de un comentario.
   * @param {Object} params
   * @param {string} params.fecha Fecha del comentario (YYYY-MM-DD)
   * @param {string} params.titulo Título del comentario
   * @param {string} params.comentario Texto del comentario
   * @param {string} params.autorId ID del autor
   * @param {string} params.autorNombre Nombre completo del autor
   * @returns {Promise<Object>} Comentario creado
   */
  async execute({ fecha, titulo, comentario, autorId, autorNombre }) {
    // Validaciones
    this._validateCommentData({ fecha, titulo, comentario, autorId, autorNombre });

    const commentData = {
      fecha,
      titulo: titulo.trim(),
      comentario: comentario.trim(),
      autorId,
      autorNombre,
    };

    const createdComment = await this.calendarRepository.createComment(commentData);

    return createdComment;
  }

  /**
   * Valida los datos del comentario
   * @private
   */
  _validateCommentData({ fecha, titulo, comentario, autorId, autorNombre }) {
    const errors = [];

    // Validar fecha
    if (!fecha) {
      errors.push('La fecha es obligatoria');
    } else if (!this._isValidDateFormat(fecha)) {
      errors.push('Formato de fecha inválido. Use YYYY-MM-DD');
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

    // Validar autor
    if (!autorId || !autorNombre) {
      errors.push('Los datos del autor son obligatorios');
    }

    if (errors.length > 0) {
      throw new Error(errors.join(', '));
    }
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
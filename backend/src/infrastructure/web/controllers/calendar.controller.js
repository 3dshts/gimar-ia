// src/infrastructure/web/controllers/calendar.controller.js
// -----------------------------------------------------------------------------
// Controlador de endpoints de Google Calendar.
// Responsabilidad: traducir HTTP ↔ caso de uso. No contiene lógica de negocio.
// Recibe sus dependencias por inyección en el constructor.
// -----------------------------------------------------------------------------

export class CalendarController {
  /**
   * @param {Object} deps - Dependencias inyectadas desde el contenedor.
   * @param {Object} deps.listCalendarCommentsUseCase - Caso de uso para listar comentarios.
   * @param {Object} deps.createCalendarCommentUseCase - Caso de uso para crear comentarios.
   * @param {Object} deps.updateCalendarCommentUseCase - Caso de uso para actualizar comentarios.
   * @param {Object} deps.deleteCalendarCommentUseCase - Caso de uso para eliminar comentarios.
   * @param {Object} deps.calendarRepository - Repositorio de Calendar (para endpoints de test).
   */
  constructor({
    listCalendarCommentsUseCase,
    createCalendarCommentUseCase,
    updateCalendarCommentUseCase,
    deleteCalendarCommentUseCase,
    calendarRepository,
  }) {
    this.listCalendarCommentsUseCase = listCalendarCommentsUseCase;
    this.createCalendarCommentUseCase = createCalendarCommentUseCase;
    this.updateCalendarCommentUseCase = updateCalendarCommentUseCase;
    this.deleteCalendarCommentUseCase = deleteCalendarCommentUseCase;
    this.calendarRepository = calendarRepository;
  }

  /**
   * GET /api/calendar/comments?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
   * Lista comentarios en un rango de fechas.
   */
  async getCalendarComments(req, res, next) {
    try {
      const { startDate, endDate } = req.query;

      if (!startDate || !endDate) {
        return res.status(400).json({
          success: false,
          error: 'Los parámetros startDate y endDate son obligatorios',
        });
      }

      const comments = await this.listCalendarCommentsUseCase.execute({ startDate, endDate });

      return res.status(200).json({
        success: true,
        data: comments,
        count: comments.length,
      });
    } catch (error) {
      console.error('[CalendarController] Error al listar comentarios:', error);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * POST /api/calendar/comments
   * Crea un nuevo comentario.
   * Body: { fecha, titulo, comentario, autorId, autorNombre }
   */
  async createCalendarComment(req, res, next) {
    try {
      const { fecha, titulo, comentario, autorId, autorNombre } = req.body;

      const createdComment = await this.createCalendarCommentUseCase.execute({
        fecha,
        titulo,
        comentario,
        autorId,
        autorNombre,
      });

      return res.status(201).json({
        success: true,
        data: createdComment,
        message: 'Comentario creado exitosamente',
      });
    } catch (error) {
      console.error('[CalendarController] Error al crear comentario:', error);
      return res.status(400).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * PUT /api/calendar/comments/:eventId
   * Actualiza un comentario existente.
   * Body: { titulo, comentario }
   */
  async updateCalendarComment(req, res, next) {
    try {
      const { eventId } = req.params;
      const { titulo, comentario } = req.body;

      const updatedComment = await this.updateCalendarCommentUseCase.execute({
        eventId,
        titulo,
        comentario,
      });

      return res.status(200).json({
        success: true,
        data: updatedComment,
        message: 'Comentario actualizado exitosamente',
      });
    } catch (error) {
      console.error('[CalendarController] Error al actualizar comentario:', error);
      return res.status(400).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * DELETE /api/calendar/comments/:eventId
   * Elimina un comentario.
   */
  async deleteCalendarComment(req, res, next) {
    try {
      const { eventId } = req.params;

      await this.deleteCalendarCommentUseCase.execute({ eventId });

      return res.status(200).json({
        success: true,
        message: 'Comentario eliminado exitosamente',
      });
    } catch (error) {
      console.error('[CalendarController] Error al eliminar comentario:', error);
      return res.status(400).json({
        success: false,
        error: error.message,
      });
    }
  }

  // ============================================
  // ENDPOINTS DE TEST
  // ============================================

  /**
   * GET /api/calendar/test
   * Prueba la conexión con Google Calendar listando eventos del mes actual.
   */
  async testCalendarConnection(req, res, next) {
    try {
      console.log('🧪 [TEST] Probando conexión con Google Calendar Repository...');

      const now = new Date();
      const year = now.getFullYear();
      const month = now.getMonth();

      const firstDay = new Intl.DateTimeFormat('en-CA', {
        timeZone: 'Europe/Madrid',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
      }).format(new Date(year, month, 1));

      const lastDayOfMonth = new Date(year, month + 1, 0).getDate();
      const lastDay = new Intl.DateTimeFormat('en-CA', {
        timeZone: 'Europe/Madrid',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
      }).format(new Date(year, month, lastDayOfMonth));

      const comments = await this.calendarRepository.listComments(firstDay, lastDay);

      return res.status(200).json({
        success: true,
        message: 'Repository funcionando correctamente',
        calendarId: this.calendarRepository.getCalendarId(),
        startDate: firstDay,
        endDate: lastDay,
        commentCount: comments.length,
        comments,
      });
    } catch (error) {
      console.error('🧪 [TEST] Error:', error);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * POST /api/calendar/test-create
   * Crea un comentario de prueba en el día actual.
   */
  async testCreateComment(req, res, next) {
    try {
      const today = this.calendarRepository.getCurrentDate();

      const testComment = {
        fecha: today,
        titulo: 'Comentario de Prueba',
        comentario: 'Este es un comentario de prueba creado desde el backend.',
        autorId: 'test-user',
        autorNombre: 'Usuario de Prueba',
      };

      const createdComment = await this.calendarRepository.createComment(testComment);

      return res.status(201).json({
        success: true,
        message: 'Comentario de prueba creado exitosamente',
        comment: createdComment,
      });
    } catch (error) {
      console.error('🧪 [TEST] Error:', error);
      return res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
}
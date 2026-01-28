// backend/src/infrastructure/web/controllers/calendar.controller.js
import { CalendarRepository } from '../../database/google/calendar.repository.js';
import { ListCalendarCommentsUseCase } from '../../../application/use_cases/list_calendar_comments.usecase.js';
import { CreateCalendarCommentUseCase } from '../../../application/use_cases/create_calendar_comment.usecase.js';
import { UpdateCalendarCommentUseCase } from '../../../application/use_cases/update_calendar_comment.usecase.js';
import { DeleteCalendarCommentUseCase } from '../../../application/use_cases/delete_calendar_comment.usecase.js';

/**
 * GET /calendar/comments?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
 * Lista comentarios en un rango de fechas.
 */
export const getCalendarComments = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        error: 'Los parámetros startDate y endDate son obligatorios',
      });
    }

    const calendarRepo = new CalendarRepository();
    const listCommentsUseCase = new ListCalendarCommentsUseCase(calendarRepo);

    const comments = await listCommentsUseCase.execute({ startDate, endDate });

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
};

/**
 * POST /calendar/comments
 * Crea un nuevo comentario.
 * Body: { fecha, titulo, comentario, autorId, autorNombre }
 */
export const createCalendarComment = async (req, res) => {
  try {
    const { fecha, titulo, comentario, autorId, autorNombre } = req.body;

    const calendarRepo = new CalendarRepository();
    const createCommentUseCase = new CreateCalendarCommentUseCase(calendarRepo);

    const createdComment = await createCommentUseCase.execute({
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
};

/**
 * PUT /calendar/comments/:eventId
 * Actualiza un comentario existente.
 * Body: { titulo, comentario }
 */
export const updateCalendarComment = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { titulo, comentario } = req.body;

    const calendarRepo = new CalendarRepository();
    const updateCommentUseCase = new UpdateCalendarCommentUseCase(calendarRepo);

    const updatedComment = await updateCommentUseCase.execute({
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
};

/**
 * DELETE /calendar/comments/:eventId
 * Elimina un comentario.
 */
export const deleteCalendarComment = async (req, res) => {
  try {
    const { eventId } = req.params;

    const calendarRepo = new CalendarRepository();
    const deleteCommentUseCase = new DeleteCalendarCommentUseCase(calendarRepo);

    await deleteCommentUseCase.execute({ eventId });

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
};

// ============================================
// ENDPOINTS DE TEST (mantener por ahora)
// ============================================

export const testCalendarConnection = async (req, res) => {
  try {
    console.log('🧪 [TEST] Probando conexión con Google Calendar Repository...');

    const calendarRepo = new CalendarRepository();
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

    const comments = await calendarRepo.listComments(firstDay, lastDay);

    return res.status(200).json({
      success: true,
      message: 'Repository funcionando correctamente',
      calendarId: calendarRepo.getCalendarId(),
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
};

export const testCreateComment = async (req, res) => {
  try {
    const calendarRepo = new CalendarRepository();
    const today = calendarRepo.getCurrentDate();

    const testComment = {
      fecha: today,
      titulo: 'Comentario de Prueba',
      comentario: 'Este es un comentario de prueba creado desde el backend.',
      autorId: 'test-user',
      autorNombre: 'Usuario de Prueba',
    };

    const createdComment = await calendarRepo.createComment(testComment);

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
};
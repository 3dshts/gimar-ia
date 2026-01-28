// backend/src/infrastructure/web/routes/calendar.routes.js
import { Router } from 'express';
import {
  getCalendarComments,
  createCalendarComment,
  updateCalendarComment,
  deleteCalendarComment,
  testCalendarConnection,
  testCreateComment,
} from '../controllers/calendar.controller.js';

const router = Router();

// ============================================
// ENDPOINTS FINALES
// ============================================

/**
 * GET /calendar/comments?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
 * Lista comentarios en un rango de fechas.
 */
router.get('/comments', getCalendarComments);

/**
 * POST /calendar/comments
 * Crea un nuevo comentario.
 */
router.post('/comments', createCalendarComment);

/**
 * PUT /calendar/comments/:eventId
 * Actualiza un comentario existente.
 */
router.put('/comments/:eventId', updateCalendarComment);

/**
 * DELETE /calendar/comments/:eventId
 * Elimina un comentario.
 */
router.delete('/comments/:eventId', deleteCalendarComment);

// ============================================
// ENDPOINTS DE TEST (temporal)
// ============================================

router.get('/test', testCalendarConnection);
router.post('/test-create', testCreateComment);

export default router;
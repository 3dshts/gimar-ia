// src/infrastructure/web/routes/calendar.routes.js
// -----------------------------------------------------------------------------
// Definición de rutas de Google Calendar.
// Patrón factory: recibe el controlador ya instanciado desde el contenedor.
// -----------------------------------------------------------------------------

import { Router } from 'express';

/**
 * Crea y devuelve el router de calendario.
 * @param {Object} deps - Dependencias inyectadas.
 * @param {Object} deps.calendarController - Instancia del controlador de calendar.
 * @returns {Router} Router de Express configurado.
 */
export function createCalendarRoutes({ calendarController }) {
  const router = Router();

  // --- Endpoints de producción ---

  // GET /comments → Listar comentarios en un rango de fechas
  router.get('/comments', (req, res, next) => calendarController.getCalendarComments(req, res, next));

  // POST /comments → Crear un nuevo comentario
  router.post('/comments', (req, res, next) => calendarController.createCalendarComment(req, res, next));

  // PUT /comments/:eventId → Actualizar un comentario existente
  router.put('/comments/:eventId', (req, res, next) => calendarController.updateCalendarComment(req, res, next));

  // DELETE /comments/:eventId → Eliminar un comentario
  router.delete('/comments/:eventId', (req, res, next) => calendarController.deleteCalendarComment(req, res, next));

  // --- Endpoints de test ---

  // GET /test → Probar conexión con Google Calendar
  router.get('/test', (req, res, next) => calendarController.testCalendarConnection(req, res, next));

  // POST /test-create → Crear un comentario de prueba
  router.post('/test-create', (req, res, next) => calendarController.testCreateComment(req, res, next));

  return router;
}
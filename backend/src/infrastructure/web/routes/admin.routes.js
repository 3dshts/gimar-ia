// src/infrastructure/web/routes/admin.routes.js
// -----------------------------------------------------------------------------
// Definición de rutas administrativas.
// Patrón factory: recibe el controlador ya instanciado desde el contenedor.
// Las rutas solo definen endpoints y conectan middlewares con controladores.
// -----------------------------------------------------------------------------

import { Router } from 'express';

/**
 * Crea y devuelve el router de administración.
 * @param {Object} deps - Dependencias inyectadas.
 * @param {Object} deps.adminController - Instancia del controlador de admin.
 * @returns {Router} Router de Express configurado.
 */
export function createAdminRoutes({ adminController }) {
  const router = Router();

  // GET /users → Listado completo de usuarios
  router.get('/users', (req, res, next) => adminController.getUsers(req, res, next));

  // GET /logs → Logs con paginación y filtros opcionales
  router.get('/logs', (req, res, next) => adminController.getLogs(req, res, next));

  return router;
}
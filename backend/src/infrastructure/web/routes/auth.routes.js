// src/infrastructure/web/routes/auth.routes.js
// -----------------------------------------------------------------------------
// Definición de rutas de autenticación.
// Patrón factory: recibe el controlador ya instanciado desde el contenedor.
// Las rutas solo definen endpoints y conectan middlewares con controladores.
// No importan dependencias directamente ni contienen lógica.
// -----------------------------------------------------------------------------

import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware.js';

/**
 * Crea y devuelve el router de autenticación.
 * @param {Object} deps - Dependencias inyectadas.
 * @param {Object} deps.authController - Instancia del controlador de auth.
 * @returns {Router} Router de Express configurado.
 */
export function createAuthRoutes({ authController }) {
  const router = Router();

  // POST /login → Autenticación con username y password
  router.post('/login', (req, res, next) => authController.login(req, res, next));

  // GET /validate-token → Validar JWT y obtener datos del usuario
  router.get(
    '/validate-token',
    authMiddleware,
    (req, res, next) => authController.validateToken(req, res, next),
  );

  return router;
}
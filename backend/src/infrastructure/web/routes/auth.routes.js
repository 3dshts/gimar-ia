// backend/src/infrastructure/web/routes/auth.routes.js
import { Router } from 'express';
import { login, validateToken } from '../controllers/auth.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js'; 

const router = Router();

/**
 * POST /login
 * Ruta pública para iniciar sesión y obtener un JWT.
 */
router.post('/login', login);

/**
 * GET /validate-token
 * Ruta protegida para validar el JWT y obtener info del usuario.
 * Requiere middleware de autenticación.
 */
router.get('/validate-token', authMiddleware, validateToken);

export default router;

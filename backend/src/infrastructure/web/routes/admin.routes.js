// backend/src/infrastructure/web/routes/admin.routes.js
import express from 'express';
import { getUsers, getLogs } from '../controllers/admin.controller.js';

const router = express.Router();

/**
 * GET /users
 * Devuelve el listado completo de usuarios.
 */
router.get('/users', getUsers);



/**
 * GET /logs
 * Devuelve logs con o sin filtros, con paginación.
 */
router.get('/logs', getLogs);

export default router;

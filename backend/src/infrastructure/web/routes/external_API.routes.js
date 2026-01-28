// backend/src/infrastructure/web/routes/external_API.routes.js
import { Router } from 'express';
import { getNotasProduccion } from '../controllers/external_API.controller.js';

const router = Router();

/**
 * POST /notas_produccion
 * Obtiene las notas de producción desde el ERP externo.
 */
router.post('/notas_produccion', getNotasProduccion);

export default router;

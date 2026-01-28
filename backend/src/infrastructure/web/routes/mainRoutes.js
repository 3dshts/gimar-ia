// backend/src/infrastructure/web/routes/mainRoutes.js
import { Router } from 'express';
import { getHomePage } from '../controllers/mainController.js';
import authRoutes from './auth.routes.js';
import adminRoutes from './admin.routes.js';
import googleRoutes from './google.routes.js';
import googleOauthRoutes from './google.oauth.routes.js';
import externalApiRoutes from './external_API.routes.js';
import calendarRoutes from './calendar.routes.js';


// Creamos una nueva instancia del enrutador de Express.
const router = Router();

/**
 * GET /
 * Ruta raíz que devuelve un mensaje de estado del backend.
 */
router.get('/ping', getHomePage);

/**
 * Subrutas de la API organizadas por dominio.
 */
router.use('/api/auth', authRoutes);
router.use('/api/admin', adminRoutes);
router.use('/api/google', googleRoutes);
router.use('/api/google', googleOauthRoutes);
router.use('/api/external', externalApiRoutes);
router.use('/api/calendar', calendarRoutes);

// Exportamos el enrutador para usarlo en el servidor principal.
export default router;

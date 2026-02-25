// src/infrastructure/web/routes/main.routes.js
// -----------------------------------------------------------------------------
// Router principal de la aplicación.
// Monta todas las subrutas organizadas por dominio.
//
// ESTADO ACTUAL (híbrido temporal):
// - auth, admin, external: ya usan el contenedor de dependencias ✅
// - google, calendar: aún usan imports directos (pendiente)
// -----------------------------------------------------------------------------

import { Router } from 'express';
import { getHomePage } from '../controllers/mainController.js';
import { createContainer } from '../../../container.js';
import googleOauthRoutes from './google.oauth.routes.js';

const router = Router();

// Crear el contenedor con las dependencias ya conectadas
const { authRoutes, adminRoutes, externalApiRoutes, calendarRoutes, googleRoutes } = createContainer();

// Healthcheck
router.get('/ping', getHomePage);

// --- Rutas refactorizadas (desde el contenedor) ---
router.use('/api/auth', authRoutes);
router.use('/api/admin', adminRoutes);
router.use('/api/external', externalApiRoutes);
router.use('/api/calendar', calendarRoutes);
router.use('/api/google', googleRoutes);
router.use('/api/google', googleOauthRoutes);


export default router;
// src/infrastructure/web/routes/external_api.routes.js
// -----------------------------------------------------------------------------
// Definición de rutas para APIs externas.
// Patrón factory: recibe el controlador ya instanciado desde el contenedor.
// -----------------------------------------------------------------------------

import { Router } from 'express';

/**
 * Crea y devuelve el router de APIs externas.
 * @param {Object} deps - Dependencias inyectadas.
 * @param {Object} deps.externalApiController - Instancia del controlador.
 * @returns {Router} Router de Express configurado.
 */
export function createExternalApiRoutes({ externalApiController }) {
  const router = Router();

  // POST /notas_produccion → Obtener notas de producción del ERP externo
  router.post(
    '/notas_produccion',
    (req, res, next) => externalApiController.getNotasProduccion(req, res, next),
  );

  return router;
}
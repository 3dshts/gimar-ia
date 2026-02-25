// src/infrastructure/web/controllers/external_api.controller.js
// -----------------------------------------------------------------------------
// Controlador para peticiones relacionadas con APIs externas.
// Responsabilidad: traducir HTTP ↔ caso de uso. No contiene lógica de negocio.
// Recibe sus dependencias por inyección en el constructor.
// -----------------------------------------------------------------------------

export class ExternalApiController {
  /**
   * @param {Object} deps - Dependencias inyectadas desde el contenedor.
   * @param {Object} deps.getNotasProduccionUseCase - Caso de uso para obtener notas de producción.
   */
  constructor({ getNotasProduccionUseCase }) {
    this.getNotasProduccionUseCase = getNotasProduccionUseCase;
  }

  /**
   * POST /api/external/notas_produccion
   * Obtiene las notas de producción desde el ERP externo.
   * Respuestas HTTP idénticas al controlador original.
   */
  async getNotasProduccion(req, res, next) {
    try {
      // Extraer parámetros del body
      const { fechaDesde, fechaHasta, seccion, temporada } = req.body;

      // Validar que existan los parámetros básicos
      if (!fechaDesde || !fechaHasta || !seccion || !temporada) {
        return res.status(400).json({
          success: false,
          message: 'Faltan parámetros obligatorios: fechaDesde, fechaHasta, seccion, temporada',
        });
      }

      console.log('📥 Petición de notas de producción recibida:', {
        fechaDesde,
        fechaHasta,
        seccion,
        temporada,
      });

      // Ejecutar el caso de uso
      const result = await this.getNotasProduccionUseCase.execute({
        fechaDesde,
        fechaHasta,
        seccion,
        temporada,
      });

      console.log('✅ Notas de producción obtenidas exitosamente');

      // Responder con los datos (formato idéntico al original)
      return res.status(200).json(result);
    } catch (error) {
      console.error('❌ Error al obtener notas de producción:', error.message);

      // Errores de validación del caso de uso → 400
      if (error.message.includes('Errores de validación')) {
        return res.status(400).json({
          success: false,
          message: error.message,
        });
      }

      // Errores inesperados → 500
      return res.status(500).json({
        success: false,
        message: 'Error interno del servidor al consultar las notas de producción',
        error: error.message,
      });
    }
  }
}
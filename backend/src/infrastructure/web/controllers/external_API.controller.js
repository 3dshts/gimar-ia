// backend/src/infrastructure/web/controllers/external_API.controller.js
// -----------------------------------------------------------------------------
// Controlador para manejar peticiones relacionadas con APIs externas.
// Orquesta las peticiones HTTP y delega la lógica a los casos de uso.
// -----------------------------------------------------------------------------

import { GetNotasProduccionUseCase } from '../../../application/use_cases/get_notas_produccion.js';

/**
 * Obtiene las notas de producción del ERP externo.
 * @param {object} req - Objeto de la petición de Express.
 * @param {object} res - Objeto de la respuesta de Express.
 */
export const getNotasProduccion = async (req, res) => {
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
    const useCase = new GetNotasProduccionUseCase();
    const result = await useCase.execute({
      fechaDesde,
      fechaHasta,
      seccion,
      temporada,
    });

    console.log('✅ Notas de producción obtenidas exitosamente');

    // Responder con los datos
    res.status(200).json(result);
  } catch (error) {
    console.error('❌ Error al obtener notas de producción:', error.message);

    // Manejar errores de validación (400)
    if (error.message.includes('Errores de validación')) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    // Manejar otros errores (500)
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor al consultar las notas de producción',
      error: error.message,
    });
  }
};
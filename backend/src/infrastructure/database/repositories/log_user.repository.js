// backend/src/infrastructure/database/repositories/log.repository.js
// -----------------------------------------------------------------------------
// Repositorio de logs: encapsula la lectura/escritura sobre la colección LOG_USER.
// Usa el modelo de Mongoose para consultar y crear documentos de logs.
// -----------------------------------------------------------------------------

import { LogModel } from '../models/log.model.js';

// Implementación concreta para crear y consultar logs en MongoDB.
export class LogRepository {

  /**
   * Lista todos los logs con paginación.
   * - Orden: desc por fecha (más recientes primero).
   * - Devuelve los documentos y metadatos de paginación.
   * @param {Object} params
   * @param {number} [params.page=1]  Página actual (1-based).
   * @param {number} [params.limit=20] Tamaño de página.
   * @returns {Promise<{logs: any[], total: number, page: number, totalPages: number}>}
   */
  async findAllPaginated({ page = 1, limit = 20 }) {
    const skip = (page - 1) * limit; // Calcula cuántos documentos saltar

    // Consulta paginada y ordenada
    const logs = await LogModel
      .find({})
      .sort({ date: -1 }) // Más recientes primero
      .skip(skip)
      .limit(limit)
      .lean(); // Devuelve objetos planos (mejor rendimiento en lectura)

    // Total de documentos para calcular el número de páginas
    const total = await LogModel.countDocuments();

    return {
      logs,
      total,
      page,
      totalPages: Math.ceil(total / limit)
    };
  } 

  /**
   * Lista logs aplicando filtros + paginación.
   * - Filtros soportados:
   *   • user / fullName / email → búsqueda parcial (regex insensible a mayúsculas).
   *   • date → rango [from, to] (incluyentes si se proporcionan).
   * - Orden: desc por fecha (más recientes primero).
   * @param {Object} params
   * @param {number} [params.page=1]   Página actual (1-based).
   * @param {number} [params.limit=20] Tamaño de página.
   * @param {Object} [params.filters={}] Criterios de filtrado.
   * @returns {Promise<{data: any[], total: number, page: number, limit: number, pages: number}>}
   */
  async findAllFilteredPaginated({ page = 1, limit = 20, filters = {} }) {
    const skip = (page - 1) * limit; // Offset para la paginación
    const query = {};                 // Objeto de consulta para Mongo

    // Filtro por campos de texto (búsqueda parcial case-insensitive)
    if (filters.user) {
      query.user = { $regex: filters.user, $options: 'i' };
    }
    if (filters.fullName) {
      query.fullName = { $regex: filters.fullName, $options: 'i' };
    }
    if (filters.email) {
      query.email = { $regex: filters.email, $options: 'i' };
    }

    // Filtro por rango de fechas (si se proporciona 'from' y/o 'to')
    if (filters.from || filters.to) {
      query.date = {};
      if (filters.from) query.date.$gte = filters.from;
      if (filters.to) query.date.$lte = filters.to;
    }

    // Consulta paginada con filtros aplicados
    const results = await LogModel.find(query)
      .sort({ date: -1 })              // Orden descendente por fecha
      .skip(skip)                      // Salta los documentos previos
      .limit(limit)                    // Limita el tamaño de página
      .lean();                         // Optimiza la lectura

    // Total de documentos que cumplen el filtro (para metadatos de paginación)
    const total = await LogModel.countDocuments(query);

    return {
      data: results,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    };
  }
  
  /**
   * Crea un nuevo documento de log en la base de datos.
   * @param {Object} logData Datos del log a crear.
   * @param {number} logData.code
   * @param {string} logData.user
   * @param {string} logData.fullName
   * @param {string} logData.email
   * @param {string} logData.date
   * @returns {Promise<void>}
   */
  async create(logData) {
    // Construye el documento con los campos esperados
    const newLog = new LogModel({
      code: logData.code,
      user: logData.user,
      fullName: logData.fullName,
      email: logData.email,
      date: logData.date
    });

    // Persiste el documento en MongoDB
    await newLog.save();
  }
}

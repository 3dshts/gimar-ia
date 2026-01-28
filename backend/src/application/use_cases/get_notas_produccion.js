// backend/src/application/use-cases/get_notas_produccion.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: Obtener notas de producción desde el ERP externo (Apifox).
// Valida parámetros, construye el payload y obtiene los registros con una sola petición.
// -----------------------------------------------------------------------------

import { ExternalAPIRepository } from '../../infrastructure/database/repositories/external_API.repository.js';

export class GetNotasProduccionUseCase {
  constructor() {
    // Crear instancia del repositorio correctamente
    this.externalAPIRepo = new ExternalAPIRepository();
    this.baseUrl = 'https://susyshoes.infortic.es:8888';
    this.apiPath = '/api/GesticERP_dat_dat/v2/_process/apifox';
    this.bearerToken = 'ZG5NBZG9AKAM8HEUXQSI3W9DQ9N8PV5R';
    this.maxLimit = 10000; // Límite máximo de registros en una sola petición
  }

  /**
   * Ejecuta la consulta de notas de producción.
   * Realiza una única llamada para obtener todos los registros.
   * @param {Object} params Parámetros de consulta
   * @param {string} params.fechaDesde Fecha de inicio (YYYY-MM-DD)
   * @param {string} params.fechaHasta Fecha de fin (YYYY-MM-DD)
   * @param {string} params.seccion Número de sección
   * @param {string} params.temporada Número de temporada
   * @returns {Promise<Object>} Objeto con todos los registros y metadatos
   */
  async execute(params) {
    // 1. Validar parámetros
    this._validateParams(params);

    // 2. Construir el payload para la API externa
    const payload = this._buildPayload(params);

    // 3. Obtener registros con una sola petición
    try {
      const records = await this._fetchRecords(payload);
      
      // 4. Deduplicar registros
      // const uniqueRecords = this._deduplicateRecords(records);
      
      // if (uniqueRecords.length < records.length) {
      //   console.log(`⚠️ Se encontraron ${records.length - uniqueRecords.length} registros duplicados`);
      // }
      
      return {
        success: true,
        data: records,
        total_count: records.length,
        message: `Se obtuvieron ${records.length} registros correctamente`,
      };
    } catch (error) {
      throw new Error(`Error al consultar el ERP externo: ${error.message}`);
    }
  }

  /**
   * Obtiene los registros con una sola petición.
   * @param {Object} payload Payload para la API
   * @returns {Promise<Array>} Array con todos los registros
   * @private
   */
  async _fetchRecords(payload) {
    const queryParams = {
      'param[resource]': 'FABRICACION',
      'param[page]': 1,
      'param[limit]': this.maxLimit,
    };

    console.log(`📊 Consultando registros con límite de ${this.maxLimit}...`);

    const response = await this.externalAPIRepo.post(
      `${this.baseUrl}${this.apiPath}`,
      {
        body: payload,
        headers: {
          'Authorization': `Bearer ${this.bearerToken}`,
        },
        queryParams,
        timeout: 30000,
      }
    );

    // Extraer datos de la respuesta
    const records = response.data && Array.isArray(response.data) ? response.data : [];
    
    console.log(`✅ Se obtuvieron ${records.length} registros de la API externa`);
    console.log(`📊 Total disponible en la API: ${response.total_count || 0}`);
    
    return records;
  }

  /**
   * Elimina registros duplicados basándose en una clave única.
   * @param {Array} records Array de registros
   * @returns {Array} Array sin duplicados
   * @private
   */
  _deduplicateRecords(records) {
    const seen = new Map();
    
    return records.filter(record => {
      // Crear una clave única combinando nota y partida (sin agrupación)
      const key = `${record.nota}-${record.partida}`;
      
      if (seen.has(key)) {
        console.log(`⚠️ Registro duplicado encontrado: ${key}`);
        return false;
      }
      
      seen.set(key, true);
      return true;
    });
  }

  /**
   * Valida que todos los parámetros requeridos sean correctos.
   * @param {Object} params Parámetros a validar
   * @throws {Error} Si algún parámetro es inválido
   * @private
   */
  _validateParams(params) {
    const errors = [];

    // Validar fechaDesde
    if (!params.fechaDesde) {
      errors.push('fechaDesde es obligatorio');
    } else if (!this._isValidDate(params.fechaDesde)) {
      errors.push('fechaDesde debe tener formato YYYY-MM-DD');
    }

    // Validar fechaHasta
    if (!params.fechaHasta) {
      errors.push('fechaHasta es obligatorio');
    } else if (!this._isValidDate(params.fechaHasta)) {
      errors.push('fechaHasta debe tener formato YYYY-MM-DD');
    }

    // Validar que fechaDesde <= fechaHasta
    if (params.fechaDesde && params.fechaHasta) {
      const desde = new Date(params.fechaDesde);
      const hasta = new Date(params.fechaHasta);
      if (desde > hasta) {
        errors.push('fechaDesde no puede ser posterior a fechaHasta');
      }
    }

    // Validar sección
    if (!params.seccion) {
      errors.push('seccion es obligatorio');
    } else if (!this._isPositiveInteger(params.seccion)) {
      errors.push('seccion debe ser un número entero positivo');
    }

    // Validar temporada
    if (!params.temporada) {
      errors.push('temporada es obligatorio');
    } else if (!this._isPositiveInteger(params.temporada)) {
      errors.push('temporada debe ser un número entero positivo');
    }

    // Si hay errores, lanzar excepción
    if (errors.length > 0) {
      throw new Error(`Errores de validación: ${errors.join(', ')}`);
    }
  }

  /**
   * Construye el payload para la API externa.
   * @param {Object} params Parámetros validados
   * @returns {Object} Payload formateado
   * @private
   */
  _buildPayload(params) {
    return {
      realizada_desde: params.fechaDesde,
      realizada_hasta: params.fechaHasta,
      seccion: params.seccion.toString(),
      temporada: params.temporada.toString(),
    };
  }

  /**
   * Valida si una fecha tiene formato YYYY-MM-DD y es válida.
   * @param {string} dateString Fecha a validar
   * @returns {boolean} true si es válida
   * @private
   */
  _isValidDate(dateString) {
    const regex = /^\d{4}-\d{2}-\d{2}$/;
    if (!regex.test(dateString)) {
      return false;
    }

    const date = new Date(dateString);
    const timestamp = date.getTime();
    
    if (typeof timestamp !== 'number' || Number.isNaN(timestamp)) {
      return false;
    }

    return dateString === date.toISOString().split('T')[0];
  }

  /**
   * Valida si un valor es un número entero positivo.
   * @param {any} value Valor a validar
   * @returns {boolean} true si es entero positivo
   * @private
   */
  _isPositiveInteger(value) {
    const num = parseInt(value, 10);
    return !isNaN(num) && num > 0 && num.toString() === value.toString();
  }
}
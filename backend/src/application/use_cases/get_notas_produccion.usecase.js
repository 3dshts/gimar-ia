// src/application/use_cases/get_notas_produccion.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: Obtener notas de producción desde el ERP externo.
// Valida parámetros, construye el payload y obtiene los registros.
// Recibe el repositorio y la configuración por inyección de dependencias.
// -----------------------------------------------------------------------------

export class GetNotasProduccionUseCase {
  /**
   * @param {Object} deps - Dependencias inyectadas desde el contenedor.
   * @param {Object} deps.externalApiRepository - Repositorio para llamadas HTTP externas.
   * @param {Object} deps.erpConfig - Configuración del ERP (baseUrl, apiPath, bearerToken, maxLimit).
   */
  constructor({ externalApiRepository, erpConfig }) {
    this.externalApiRepository = externalApiRepository;
    this.baseUrl = erpConfig.baseUrl;
    this.apiPath = erpConfig.apiPath;
    this.bearerToken = erpConfig.bearerToken;
    this.maxLimit = erpConfig.maxLimit;
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

    const response = await this.externalApiRepository.post(
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

    // Validar que fechaDesde no sea posterior a fechaHasta
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

    // Si hay errores, lanzar excepción con todos los mensajes
    if (errors.length > 0) {
      throw new Error(`Errores de validación: ${errors.join(', ')}`);
    }
  }

  /**
   * Construye el payload para la API externa.
   * @param {Object} params Parámetros validados
   * @returns {Object} Payload formateado para el ERP
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
   * Valida si una fecha tiene formato YYYY-MM-DD y es una fecha real.
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
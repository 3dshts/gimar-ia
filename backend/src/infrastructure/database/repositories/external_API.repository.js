// backend/src/infrastructure/repositories/external_api.repository.js
// -----------------------------------------------------------------------------
// Repositorio para operaciones con APIs externas.
// Encapsula toda la lógica de comunicación HTTP con servicios externos.
// -----------------------------------------------------------------------------

export class ExternalAPIRepository {
  /**
   * Realiza una petición GET a una API externa.
   * @param {string} url URL completa del endpoint
   * @param {Object} options Opciones adicionales
   * @param {Object} options.headers Headers personalizados
   * @param {Object} options.queryParams Parámetros de query string
   * @param {number} options.timeout Timeout en milisegundos (default: 30000)
   * @returns {Promise<Object>} Respuesta JSON de la API
   */
  async get(url, options = {}) {
    const { headers = {}, queryParams = {}, timeout = 30000 } = options;

    // Construir URL con query params si existen
    const urlWithParams = this._buildUrlWithParams(url, queryParams);

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(urlWithParams, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP Error: ${response.status} - ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError') {
        throw new Error(`Request timeout after ${timeout}ms`);
      }
      
      throw error;
    }
  }

  /**
   * Realiza una petición POST a una API externa.
   * @param {string} url URL completa del endpoint
   * @param {Object} options Opciones adicionales
   * @param {Object} options.body Cuerpo de la petición
   * @param {Object} options.headers Headers personalizados
   * @param {Object} options.queryParams Parámetros de query string
   * @param {number} options.timeout Timeout en milisegundos (default: 30000)
   * @returns {Promise<Object>} Respuesta JSON de la API
   */
  async post(url, options = {}) {
    const { body = {}, headers = {}, queryParams = {}, timeout = 30000 } = options;

    // Construir URL con query params si existen
    const urlWithParams = this._buildUrlWithParams(url, queryParams);

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(urlWithParams, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP Error: ${response.status} - ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError') {
        throw new Error(`Request timeout after ${timeout}ms`);
      }
      
      throw error;
    }
  }

  /**
   * Construye una URL con parámetros de query string.
   * @param {string} baseUrl URL base
   * @param {Object} params Objeto con los parámetros
   * @returns {string} URL completa con query params
   * @private
   */
  _buildUrlWithParams(baseUrl, params) {
    if (!params || Object.keys(params).length === 0) {
      return baseUrl;
    }

    const url = new URL(baseUrl);
    Object.entries(params).forEach(([key, value]) => {
      if (value !== null && value !== undefined) {
        url.searchParams.append(key, value);
      }
    });

    return url.toString();
  }
}

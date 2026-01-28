// backend/src/application/use_cases/get_all_logs.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: obtener todos los logs con paginación.
// -----------------------------------------------------------------------------

export class GetAllLogsUseCase {
  /**
   * @param {Object} logRepository Repositorio de logs con el contrato findAllPaginated
   */
  constructor(logRepository) {
    this.logRepository = logRepository;
  }
  
  /**
   * Ejecuta la consulta de logs paginados.
   * @param {Object} params
   * @param {number} [params.page=1]  Página (1-based)
   * @param {number} [params.limit=20] Tamaño de página
   * @returns {Promise<Object>} Resultado del repositorio con datos y metadatos de paginación
   */
  async execute({ page = 1, limit = 20 }) {
    return await this.logRepository.findAllPaginated({ page, limit });
  }
}

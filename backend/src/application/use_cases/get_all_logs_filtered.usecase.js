// backend/src/application/use_cases/get_all_logs_filtered.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: obtener logs filtrados con paginación.
// Orquesta la llamada al repositorio, sin lógica de infraestructura.
// -----------------------------------------------------------------------------

export class GetAllLogsFilteredUseCase {
  /**
   * @param {Object} logRepository Repositorio de logs con el contrato findAllFilteredPaginated
   */
  constructor(logRepository) {
    this.logRepository = logRepository;
  }

  /**
   * Ejecuta la consulta de logs con filtros + paginación.
   * @param {Object} params
   * @param {number} [params.page=1]  Página (1-based)
   * @param {number} [params.limit=20] Tamaño de página
   * @param {Object} [params.filters={}] Filtros (user, fullName, email, from, to)
   * @returns {Promise<Object>} Resultado del repositorio con datos y metadatos de paginación
   */
  async execute({ page = 1, limit = 20, filters = {} }) {
    return await this.logRepository.findAllFilteredPaginated({ page, limit, filters });
  }
}

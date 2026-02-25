// src/infrastructure/web/controllers/admin.controller.js
// -----------------------------------------------------------------------------
// Controlador de endpoints administrativos: usuarios y logs.
// Responsabilidad: traducir HTTP ↔ caso de uso. No contiene lógica de negocio.
// Recibe sus dependencias (casos de uso) por inyección en el constructor.
// -----------------------------------------------------------------------------

export class AdminController {
  /**
   * @param {Object} deps - Dependencias inyectadas desde el contenedor.
   * @param {Object} deps.getAllUsersUseCase - Caso de uso para listar usuarios.
   * @param {Object} deps.getAllLogsUseCase - Caso de uso para listar logs sin filtros.
   * @param {Object} deps.getAllLogsFilteredUseCase - Caso de uso para listar logs con filtros.
   */
  constructor({ getAllUsersUseCase, getAllLogsUseCase, getAllLogsFilteredUseCase }) {
    this.getAllUsersUseCase = getAllUsersUseCase;
    this.getAllLogsUseCase = getAllLogsUseCase;
    this.getAllLogsFilteredUseCase = getAllLogsFilteredUseCase;
  }

  /**
   * GET /api/admin/users
   * Devuelve el listado completo de usuarios.
   */
  async getUsers(req, res, next) {
    try {
      const users = await this.getAllUsersUseCase.execute();

      // Devolver el array directamente como hacía antes
      return res.status(200).json(users);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/admin/logs
   * Devuelve logs con paginación, con o sin filtros.
   * Si la query incluye filtros (user, fullName, email, from, to),
   * ejecuta el caso de uso filtrado. Si no, el general.
   */
  async getLogs(req, res, next) {
    try {
      const { page = 1, limit = 20, user, fullName, email, from, to } = req.query;

      // Convertir page y limit a número una sola vez
      const pageNum = Number(page);
      const limitNum = Number(limit);

      // Determinar si hay filtros activos en la query
      const hasFilters = user || fullName || email || from || to;

      let result;

      if (hasFilters) {
        // Con filtros → caso de uso filtrado
        const filters = { user, fullName, email, from, to };
        result = await this.getAllLogsFilteredUseCase.execute({
          page: pageNum,
          limit: limitNum,
          filters,
        });
      } else {
        // Sin filtros → caso de uso general
        result = await this.getAllLogsUseCase.execute({
          page: pageNum,
          limit: limitNum,
        });
      }

      // Devolver el resultado directamente como hacía antes
      return res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  }
}
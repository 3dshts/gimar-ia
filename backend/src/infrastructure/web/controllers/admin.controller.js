// backend/src/infrastructure/web/controllers/admin.controller.js
// Controlador de endpoints administrativos: usuarios y logs.

import { UserRepository } from '../../database/repositories/user.repository.js';
import { LogRepository } from '../../database/repositories/log_user.repository.js';

import { GetAllUsersUseCase } from '../../../application/use_cases/get_all_users.usecase.js';
import { GetAllLogsUseCase } from '../../../application/use_cases/get_all_logs.usecase.js';
import { GetAllLogsFilteredUseCase } from '../../../application/use_cases/get_all_logs_filtered.usecase.js';

/**
 * GET /admin/users
 * Devuelve el listado completo de usuarios.
 * - Instancia repositorio y caso de uso.
 * - Responde con los usuarios o error 500.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @returns {Promise<void>}
 */
export const getUsers = async (req, res) => {
  try {
    const userRepository = new UserRepository();
    const getAllUsersUseCase = new GetAllUsersUseCase(userRepository);

    const users = await getAllUsersUseCase.execute();

    return res.status(200).json(users);
  } catch (error) {
    console.error('[AdminController] Error al obtener usuarios:', error);
    return res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * GET /admin/logs
 * Devuelve logs con paginación, con o sin filtros.
 * - Lee page y limit del querystring.
 * - Si hay filtros en la query, ejecuta el caso filtrado; si no, el general.
 * - Responde con el resultado o error 500.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @returns {Promise<void>}
 */
export const getLogs = async (req, res) => {
  try {
    const { page = 1, limit = 20, user, fullName, email, from, to } = req.query;

    const logRepository = new LogRepository();

    if (user || fullName || email || from || to) {
      // ✅ Con filtros
      const filters = { user, fullName, email, from, to };
      const getAllLogsFilteredUseCase = new GetAllLogsFilteredUseCase(logRepository);
      const filteredLogs = await getAllLogsFilteredUseCase.execute({
        page: Number(page),
        limit: Number(limit),
        filters,
      });
      return res.status(200).json(filteredLogs);
    } else {
      // ✅ Sin filtros
      const getAllLogsUseCase = new GetAllLogsUseCase(logRepository);
      const allLogs = await getAllLogsUseCase.execute({
        page: Number(page),
        limit: Number(limit),
      });
      return res.status(200).json(allLogs);
    }
  } catch (error) {
    console.error('[AdminController] Error al obtener logs:', error);
    return res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

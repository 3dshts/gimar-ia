// backend/src/application/use_cases/get_all_users.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: obtener todos los usuarios.
// -----------------------------------------------------------------------------

export class GetAllUsersUseCase {
  /**
   * @param {Object} userRepository Repositorio de usuarios con el contrato findAll
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * Ejecuta la consulta de todos los usuarios.
   * @returns {Promise<any[]>} Listado completo de usuarios
   */
  async execute() {
    return await this.userRepository.findAll();
  }
}

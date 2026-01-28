// backend/src/infrastructure/database/repositories/user.repository.js
// -----------------------------------------------------------------------------
// Repositorio de usuarios: centraliza las consultas a la colección USER.
// Provee métodos de lectura usados por casos de uso y controladores.
// -----------------------------------------------------------------------------

import { UserModel } from '../models/user.model.js';

// Implementación concreta para obtener datos de usuarios desde MongoDB.
export class UserRepository {

  /**
   * Devuelve todos los usuarios de la colección.
   * @returns {Promise<any[]>} Listado plano de documentos de usuario.
   */
  async findAll() {
    // Consulta sin filtros; lean() para devolver POJOs (mejor rendimiento)
    return await UserModel.find().lean();
  }  

  /**
   * Busca un usuario por su nombre de usuario (username).
   * Registra en consola el resultado de la búsqueda para depuración.
   * @param {string} username Nombre de usuario a buscar.
   * @returns {Promise<any|null>} Documento encontrado o null si no existe.
   */
  async findByUsername(username) {
    console.log(`[Repository] Buscando usuario en la BD con el username: "${username}"`);
    
    // Búsqueda puntual por el campo 'user'
    const userDocument = await UserModel.findOne({ user: username }).lean();
    
    // Logs de depuración según el resultado
    if (userDocument) {
      console.log('[Repository] ¡Usuario encontrado en la BD!', userDocument);
    } else {
      console.log('[Repository] Usuario NO encontrado en la BD (findOne devolvió null).');
    }
    // --- FIN DEPURACIÓN ---

    return userDocument;
  }

}

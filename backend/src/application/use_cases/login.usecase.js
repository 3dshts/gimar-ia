// backend/src/application/use_cases/login.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: login de usuario.
// - Verifica credenciales (username/password) contra el repositorio de usuarios.
// - Genera un token JWT con expiración.
// - Registra un log de inicio de sesión exitoso.
// -----------------------------------------------------------------------------

import jwt from "jsonwebtoken";
import { DateTime } from "luxon";
import { Log } from "../../domain/entities/log.entity.js";

export class LoginUseCase {
  // El caso de uso depende de "contratos" (repositorios), no de implementaciones.
  /**
   * @param {Object} userRepository Repositorio de usuarios con el contrato findByUsername
   * @param {Object} logRepository  Repositorio de logs con el contrato create
   */
  constructor(userRepository, logRepository) {
    this.userRepository = userRepository;
    this.logRepository = logRepository;
  }

  /**
   * Autentica y emite un token JWT; registra log de acceso.
   * @param {string} username Nombre de usuario
   * @param {string} password Contraseña en texto plano
   * @returns {Promise<{token: string, user: Object}>} Token y datos públicos del usuario
   * @throws {Error} Si las credenciales son inválidas o el usuario no existe
   */
  async login(username, password) {
    // 1) Buscar usuario por username
    const user = await this.userRepository.findByUsername(username);

    if (!user) {
      throw new Error("Usuario no encontrado");
    }

    // 2) Verificación sencilla (comparación directa de password)
    if (password !== user.password) {
      throw new Error("Contraseña incorrecta");
    }

    // 3) Construir payload del JWT con datos no sensibles
    const payload = {
      code: user.code,
      user: user.user,
    };

    // 4) Firmar el token con secreto y expiración
    const token = jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: "8h" } // La sesión durará 8 horas
    );

    // 5) Crear log de login correcto con hora de Madrid
    const madridNow = DateTime.now().setZone('Europe/Madrid').toFormat('yyyy-MM-dd HH:mm:ss');

    const log = new Log(user.code, user.user, user.full_name, user.email, madridNow);
    await this.logRepository.create(log);

    // 6) Devolver token y datos de usuario relevantes para el frontend
    return {
      token: token,
      user: {
        username: user.user,
        fullName: user.full_name,
        email: user.email,
        permissions: user.permision || null, // En caso de ser el admin este campo será null
        isAdmin: user.isAdmin || false       // Solo el admin tendrá este campo como true.
        // ESto se debe a que en la BD el admin no tiene el campo 'permissions' y es el único que tiene el campo 'isAdmin'.
      }
    }
  }
}

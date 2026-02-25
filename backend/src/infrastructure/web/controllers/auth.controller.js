// src/infrastructure/web/controllers/auth.controller.js
// -----------------------------------------------------------------------------
// Controlador de autenticación.
// Responsabilidad: traducir HTTP ↔ caso de uso. No contiene lógica de negocio.
// Recibe sus dependencias (casos de uso) por inyección en el constructor.
// -----------------------------------------------------------------------------

export class AuthController {
  /**
   * @param {Object} deps - Dependencias inyectadas desde el contenedor.
   * @param {Object} deps.loginUseCase - Caso de uso de login.
   * @param {Object} deps.userRepository - Repositorio de usuarios (para validateToken).
   */
  constructor({ loginUseCase, userRepository }) {
    this.loginUseCase = loginUseCase;
    this.userRepository = userRepository;
  }

  /**
   * POST /api/auth/login
   * Autentica al usuario con username y password.
   * Delega toda la lógica al caso de uso y traduce el resultado a HTTP.
   */
  async login(req, res, next) {
    try {
      const { username, password } = req.body;

      // Validación básica de presencia de campos
      if (!username || !password) {
        return res.status(400).json({ message: 'Usuario y contraseña son requeridos.' });
      }

      // Ejecutar la lógica de negocio
      const result = await this.loginUseCase.login(username, password);

      // Devolver el resultado tal cual lo genera el caso de uso
      return res.status(200).json(result);
    } catch (error) {
      // Errores conocidos del caso de uso → 401
      if (
        error.message === 'Usuario no encontrado' ||
        error.message === 'Contraseña incorrecta'
      ) {
        return res.status(401).json({ message: error.message });
      }

      // Errores inesperados → delegar al middleware global de errores
      next(error);
    }
  }

  /**
   * GET /api/auth/validate-token
   * Valida el token JWT (ya verificado por el authMiddleware) y devuelve
   * los datos del usuario asociado.
   */
  async validateToken(req, res, next) {
    try {
      // El authMiddleware ya decodificó el token y lo puso en req.user
      const { user: usernameFromToken } = req.user;

      // Buscar el usuario completo en la base de datos
      const user = await this.userRepository.findByUsername(usernameFromToken);

      if (!user) {
        return res.status(404).json({ message: 'Usuario del token no encontrado.' });
      }

      // Construir respuesta según el tipo de usuario (admin vs normal)
      const userResponse = {
        username: user.user,
        fullName: user.full_name,
        email: user.email,
      };

      if (user.isAdmin === true) {
        userResponse.isAdmin = true;
      } else {
        // fallback a objeto vacío por si el campo no existe en BD
        userResponse.permissions = user.permision || {};
      }

      return res.status(200).json({
        message: 'Token válido.',
        user: userResponse,
      });
    } catch (error) {
      next(error);
    }
  }
}
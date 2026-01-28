// backend/src/infrastructure/web/controllers/auth.controller.js
// Controlador de autenticación: login y validación de token.
// Orquesta casos de uso y repositorios, y devuelve respuestas HTTP.

import { LoginUseCase } from '../../../application/use_cases/login.usecase.js';
import { UserRepository } from '../../database/repositories/user.repository.js';
import { LogRepository } from '../../database/repositories/log_user.repository.js';

/**
 * Endpoint de login.
 * - Valida presencia de credenciales.
 * - Instancia repositorios y caso de uso.
 * - Ejecuta el login y devuelve token + datos de usuario.
 * - Gestiona errores conocidos (usuario/contraseña).
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @returns {Promise<void>}
 */
export const login = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ message: 'Usuario y contraseña son requeridos.' });
    }

    // Instanciamos las dependencias necesarias para el caso de uso.
    const userRepository = new UserRepository();
    const logRepository = new LogRepository();
    const loginUseCase = new LoginUseCase(userRepository, logRepository);
    
    // Ejecutamos la lógica de negocio.
    const result = await loginUseCase.login(username, password);
    
    // Enviamos la respuesta exitosa.
    res.status(200).json(result);

  } catch (error) {
    // Manejamos errores específicos del caso de uso.
    if (error.message === 'Usuario no encontrado' || error.message === 'Contraseña incorrecta') {
      return res.status(401).json({ message: error.message });
    }
    // Manejamos otros errores inesperados.
    console.error('Error en el login:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * Endpoint para validar un token ya emitido y devolver info del usuario.
 * - Lee el usuario del token ya verificado (middleware previo).
 * - Obtiene el usuario y construye la respuesta según sea admin o no.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @returns {Promise<void>}
 */
export const validateToken = async (req, res) => {
  try {
    const { user: usernameFromToken } = req.user;

    const userRepository = new UserRepository();
    const user = await userRepository.findByUsername(usernameFromToken);

    if (!user) {
      return res.status(404).json({ message: 'Usuario del token no encontrado.' });
    }

    // ⚙️ Construimos la respuesta dependiendo del tipo de usuario
    const userResponse = {
      username: user.user,
      fullName: user.full_name,
      email: user.email,
    };

    if (user.isAdmin === true) {
      userResponse.isAdmin = true;
    } else {
      userResponse.permissions = user.permision || {}; // fallback por si no existiera
    }

    res.status(200).json({
      message: 'Token válido.',
      user: userResponse,
    });

  } catch (error) {
    console.error('Error en la validación de token:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

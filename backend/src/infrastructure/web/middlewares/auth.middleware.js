// src/infrastructure/web/middlewares/auth.middleware.js
// -----------------------------------------------------------------------------
// Middleware de autenticación JWT.
// Verifica el token del header Authorization y adjunta el payload en req.user.
// Usa la configuración centralizada en vez de leer process.env directamente.
// -----------------------------------------------------------------------------

import jwt from 'jsonwebtoken';
import config from '../../../config/env.js';

/**
 * Middleware que valida el token JWT en cada petición protegida.
 * - Extrae el token del header "Authorization: Bearer <token>".
 * - Verifica firma y expiración con el secreto de config.
 * - Si es válido, adjunta el payload decodificado en req.user.
 * - Si no es válido, responde con 401.
 */
export const authMiddleware = (req, res, next) => {
  try {
    // Leer el header Authorization
    const authHeader = req.headers['authorization'];

    // Verificar que el header existe
    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: 'Acceso denegado. No se proporcionó token de autenticación.',
      });
    }

    // Verificar que tiene el formato correcto "Bearer <token>"
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Acceso denegado. El token tiene un formato incorrecto.',
      });
    }

    // Extraer el token quitando el prefijo "Bearer "
    const token = authHeader.split(' ')[1];

    // Verificar la firma y expiración del token
    const decodedPayload = jwt.verify(token, config.jwt.secret);

    // Adjuntar el payload al request para que los controladores lo usen
    req.user = decodedPayload;

    // Continuar al siguiente middleware o controlador
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Token no válido o ha expirado.',
    });
  }
};
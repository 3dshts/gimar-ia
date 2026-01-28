// backend/src/infrastructure/web/middlewares/auth.middleware.js
import jwt from "jsonwebtoken";

/**
 * Middleware de autenticación.
 * - Busca y valida el token JWT en el header `Authorization`.
 * - Si el token es válido, adjunta el payload decodificado en `req.user`.
 * - Si no es válido o no existe, responde con 401.
 * 
 * @param {import('express').Request} req Objeto de la petición
 * @param {import('express').Response} res Objeto de la respuesta
 * @param {import('express').NextFunction} next Función para pasar al siguiente middleware/controlador
 */
export const authMiddleware = (req, res, next) => {
  try {
    // 1. Buscamos el token en el encabezado 'Authorization'.
    const authHeader = req.headers["authorization"];

    // 2. Comprobamos si el token fue enviado y si tiene el formato correcto "Bearer <token>".
    if (!authHeader) {
      return res
        .status(401)
        .json({
          message: "Acceso denegado. No se proporcionó token de auteticación.",
        });
    }
    if (!authHeader.startsWith("Bearer ")) {
      return res
        .status(401)
        .json({
          message: "Acceso denegado. El token tiene un formato incorrecto.",
        });
    }

    // 3. Extraemos el token, quitando el prefijo "Bearer ".
    const token = authHeader.split(" ")[1];

    // 4. Verificamos el token con la clave secreta.
    // jwt.verify valida la firma y la expiración; lanza error si algo falla.
    const decodedPayload = jwt.verify(token, process.env.JWT_SECRET);

    // 5. Si el token es válido, adjuntamos el payload al request.
    req.user = decodedPayload;

    // 6. Continuamos hacia el siguiente middleware/controlador.
    next();
  } catch (error) {
    // Si el token no es válido, devolvemos error 401.
    res.status(401).json({ message: "Token no válido o ha expirado." });
  }
};

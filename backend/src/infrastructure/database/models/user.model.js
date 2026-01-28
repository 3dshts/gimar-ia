// backend/src/infrastructure/database/models/user.model.js
// ------------------------------------------------------
// Mongoose model: USER
// Define el esquema de usuarios y su subdocumento de permisos.
// ------------------------------------------------------

import mongoose from 'mongoose';

/**
 * Subdocumento de permisos por funcionalidad.
 * Todos los campos son booleanos y representan flags de acceso
 * a distintas áreas de la aplicación.
*/
const permissionSchema = new mongoose.Schema({
  buzon: Boolean,
  alertas_produccion: Boolean,
  prototipos: Boolean,
  situacion_pedidos: Boolean,
  gestion_pedidos: Boolean,
  gestion_nominas: Boolean,
  intrastat: Boolean,
  inventario: Boolean,
  parte_situacion: Boolean,
  notas_fabricacion: Boolean,
}, { _id: false });

/**
 * Esquema principal de usuario.
 *
 * Campos:
 * - code: Identificador numérico interno (unique).
 * - full_name: Nombre completo para display.
 * - user: Nombre de usuario (unique), utilizado para autenticación.
 * - password: Contraseña (no exponer en respuestas públicas).
 * - email: Correo del usuario.
 * - permision: Subdocumento de permisos (nota: el nombre podría ser 'permission').
 * - isAdmin: Flag opcional de rol administrador.
 */
const userSchema = new mongoose.Schema({
  code: { type: Number, required: true, unique: true },
  full_name: { type: String, required: true },
  user: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  email: { type: String, required: true },
  permision: { type: permissionSchema, required: true },
  isAdmin: { type: Boolean, required: false },
});

export const UserModel = mongoose.model('USER', userSchema, 'USER');

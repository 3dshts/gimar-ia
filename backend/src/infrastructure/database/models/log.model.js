// backend/src/infrastructure/database/models/log.model.js
// ------------------------------------------------------
// Mongoose model: LOG_USER
// Define el esquema para los registros (logs) de login/actividad.
// ------------------------------------------------------

import mongoose from 'mongoose';

/**
 * Esquema de Log.
 *
 * Campos:
 * - code: Código/razón del evento (numérico).
 * - user: Username que generó el evento.
 * - fullName: Nombre completo del usuario.
 * - email: Correo del usuario.
 * - date: Fecha/hora del evento como String.
 */
const logSchema = new mongoose.Schema({
  code: { type: Number, required: true },
  user: { type: String, required: true },
  fullName: { type: String, required: true },
  email: { type: String, required: true },
  date: { type: String, required: true }
});

// Índice para ordenar/consultar por fecha de manera eficiente.
logSchema.index({ date: -1 });

// Nombre explícito de la colección: 'LOG_USER' (mayúsculas por consistencia con USER).
export const LogModel = mongoose.model('LOG_USER', logSchema, 'LOG_USER');

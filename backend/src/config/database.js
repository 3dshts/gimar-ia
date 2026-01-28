// backend/src/config/database.js

import mongoose from 'mongoose';

import { UserModel } from '../infrastructure/database/models/user.model.js';

/**
 * Establece la conexión con la base de datos de MongoDB.
 */
export const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI);
    console.log(`✅ MongoDB Conectado: ${conn.connection.host}`);

  } catch (error) {
    console.error(`Error de conexión: ${error.message}`);
    process.exit(1);
  }
};
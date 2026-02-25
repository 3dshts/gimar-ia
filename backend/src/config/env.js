// src/config/env.js
// -----------------------------------------------------------------------------
// Configuración centralizada de variables de entorno.
// Este módulo es el ÚNICO lugar donde se lee process.env en toda la app.
// Funciona tanto en local (lee .env con dotenv) como en Lambda (AWS inyecta
// las variables automáticamente en process.env desde serverless.yml).
// -----------------------------------------------------------------------------

import dotenv from 'dotenv';

// En local carga el .env; en Lambda no encuentra archivo y no falla.
dotenv.config();

const config = {
  // --- Servidor ---
  port: parseInt(process.env.PORT, 10) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',

  // --- Base de datos ---
  db: {
    uri: process.env.MONGODB_URI,
  },

  // --- JWT ---
  jwt: {
    secret: process.env.JWT_SECRET,
    expiration: process.env.JWT_EXPIRATION || '8h',
  },

  // --- Google OAuth ---
  google: {
    clientId: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    redirectUri: process.env.GOOGLE_REDIRECT_URI,
    refreshToken: process.env.GOOGLE_REFRESH_TOKEN,
    accessToken: process.env.GOOGLE_ACCESS_TOKEN,
    calendarId: process.env.GOOGLE_CALENDAR_ID || 'primary',
  },

  // --- Google Drive ---
  drive: {
    mainFolderId: process.env.DRIVE_ID,
    idsPath: process.env.GOOGLE_DRIVE_IDS_PATH,
  },

  // --- ERP Externo ---
  erp: {
    baseUrl: process.env.ERP_BASE_URL,
    apiPath: process.env.ERP_API_PATH,
    bearerToken: process.env.ERP_BEARER_TOKEN,
    maxLimit: parseInt(process.env.ERP_MAX_LIMIT, 10) || 10000,
  },

  // --- Lambda Endpoints (Extracción de imágenes de prototipos) ---
  lambda: {
    swImagesUrl: process.env.LAMBDA_SW_IMAGES_URL,
    versaceImagesUrl: process.env.LAMBDA_VERSACE_IMAGES_URL,
  },
};

// ---------------------------------------------------------------------------
// Validación de variables obligatorias al arrancar.
// Si falta alguna, la app falla rápido con un mensaje claro en vez de
// romperse más adelante con un error críptico.
// ---------------------------------------------------------------------------
const REQUIRED_VARS = [
  'MONGODB_URI',
  'JWT_SECRET',
  'GOOGLE_CLIENT_ID',
  'GOOGLE_CLIENT_SECRET',
  'GOOGLE_REFRESH_TOKEN',
];

for (const varName of REQUIRED_VARS) {
  if (!process.env[varName]) {
    throw new Error(`❌ Variable de entorno requerida no encontrada: ${varName}`);
  }
}

export default config;
// src/infrastructure/web/routes/google.oauth.routes.js
// -----------------------------------------------------------------------------
// Ruta de callback para el flujo OAuth2 de Google.
// Se usa exclusivamente para obtener/renovar tokens de forma manual.
// Este archivo NO pasa por el contenedor de inyección de dependencias porque
// es un flujo aislado que solo se ejecuta una vez al configurar credenciales.
// -----------------------------------------------------------------------------

import { Router } from 'express';
import { OAuth2Client } from 'google-auth-library';
import fs from 'fs';
import path from 'path';
import config from '../../../config/env.js';

const router = Router();
const TOKENS_PATH = path.resolve('backend/src/credentials/tokens.json');

/**
 * GET /oauth2/callback
 * Callback tras la autorización de Google OAuth2.
 * Recibe el código de autorización como query param, lo intercambia por
 * tokens (access + refresh) y los persiste en tokens.json para uso posterior.
 */
router.get('/oauth2/callback', async (req, res) => {
  const code = req.query.code;

  if (!code) {
    return res.status(400).send('Falta el código de autorización');
  }

  const client = new OAuth2Client(
    config.google.clientId,
    config.google.clientSecret,
    config.google.redirectUri,
  );

  try {
    const { tokens } = await client.getToken(code);
    fs.writeFileSync(TOKENS_PATH, JSON.stringify(tokens, null, 2));
    console.log('[GoogleOAuth] Tokens guardados correctamente en tokens.json');
    return res.send('Autenticación exitosa. Ya puedes cerrar esta pestaña.');
  } catch (error) {
    console.error('[GoogleOAuth] Error intercambiando el código:', error.message);
    return res.status(500).send('Error intercambiando el código de autorización');
  }
});

export default router;
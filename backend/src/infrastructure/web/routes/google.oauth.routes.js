// backend/src/infrastructure/web/routes/google.oauth.routes.js
import { Router } from 'express';
import { OAuth2Client } from 'google-auth-library';
import fs from 'fs';
import path from 'path';

const router = Router();
const TOKENS_PATH = path.resolve('backend/src/credentials/tokens.json');

/**
 * GET /oauth2/callback
 * Endpoint de callback tras la autorización de Google OAuth2.
 * - Recibe `code` como query param.
 * - Intercambia el code por tokens y los guarda en tokens.json.
 * - Devuelve un mensaje al navegador.
 */
router.get('/oauth2/callback', async (req, res) => {
  const code = req.query.code;

  if (!code) {
    return res.status(400).send('❌ Falta el código de autorización');
  }

  const client = new OAuth2Client(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    process.env.GOOGLE_REDIRECT_URI
  );

  try {
    const { tokens } = await client.getToken(code);
    fs.writeFileSync(TOKENS_PATH, JSON.stringify(tokens, null, 2));
    console.log('✅ Tokens guardados correctamente en tokens.json');
    return res.send('✅ ¡Autenticación exitosa! Ya puedes cerrar esta pestaña.');
  } catch (e) {
    console.error('❌ Error intercambiando el código:', e.message);
    return res.status(500).send('❌ Error intercambiando el código');
  }
});

export default router;
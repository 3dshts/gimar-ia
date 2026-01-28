# Infrastructure / Web / Middlewares

Este directorio contiene middlewares de Express que implementan lógica transversal para el backend.  
Los middlewares procesan las peticiones **antes de llegar a los controladores**.

## Archivos
- **`auth.middleware.js`**  
  Verifica la validez de un token JWT incluido en el encabezado `Authorization`.  
  - Rechaza solicitudes sin token o con formato incorrecto.  
  - Decodifica el payload y lo adjunta a `req.user` si es válido.

- **`google.middleware.js`**  
  Gestiona la integración con Google APIs:  
  - Crea el cliente de OAuth2 con tokens persistidos en `src/credentials/tokens.json`.  
  - Refresca automáticamente tokens y los guarda.  
  - Proporciona `getDrive()` para interactuar con Google Drive.  
  - Incluye utilidad `bufferToStream()` para subir archivos.

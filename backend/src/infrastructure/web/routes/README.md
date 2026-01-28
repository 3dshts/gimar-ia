# Infrastructure / Web / Routes

Este directorio define las rutas de Express y las conecta con los controladores correspondientes.  
Su propósito es organizar los endpoints HTTP de la API y agruparlos por dominio funcional.

## Archivos
- **`mainRoutes.js`**  
  Ruta raíz (`/`) que responde con un mensaje de estado.  
  Monta subrutas para autenticación, administración y Google.

- **`auth.routes.js`**  
  Rutas relacionadas con autenticación:  
  - `POST /login`: login de usuario.  
  - `GET /validate-token`: validación de token JWT (requiere middleware).

- **`admin.routes.js`**  
  Rutas administrativas:  
  - `GET /users`: listado de usuarios.  
  - `GET /logs`: listado de logs (con o sin filtros).

- **`google.routes.js`**  
  Rutas para interacción con Google Drive:  
  - `POST /checkFolder`: comprobar existencia de carpeta.  
  - `POST /uploadImgAlert`: subir imagen de alerta (convertida a PNG).  
  - `POST /createFolderStructure`: crear estructura de carpetas recursiva.

- **`google.oauth.routes.js`**  
  Ruta de callback para la autenticación OAuth2 con Google:  
  - `GET /oauth2/callback`: recibe el código de autorización y guarda tokens.

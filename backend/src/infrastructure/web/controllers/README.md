# Infrastructure / Web / Controllers

Controladores HTTP de Express.  
Reciben `req`, validan/normalizan la entrada, invocan **casos de uso** y devuelven respuestas JSON con los códigos de estado adecuados.

## Propósito
- Ser el punto de entrada/salida HTTP.
- No contener lógica de negocio: delegar en **use cases** y **repositorios**.
- Formatear errores y respuestas de forma consistente.

## Archivos
- **`mainController.js`**  
  Respuesta simple para la ruta raíz, usada como verificación de conexión.

- **`google.controller.js`**  
  Endpoints para subir imágenes a Google Drive (conversión a PNG), comprobar carpetas, crear carpetas (incluida creación recursiva) y utilidades de conversión con `sharp`.

- **`auth.controller.js`**  
  Login de usuario con emisión de JWT (vía `LoginUseCase`) y validación de token para recuperar datos del usuario.

- **`admin.controller.js`**  
  Endpoints administrativos: listado de usuarios y logs (paginado y con filtros), usando sus **use cases** correspondientes.

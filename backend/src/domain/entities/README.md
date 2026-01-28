# Domain / Entities

Este directorio define las **entidades de dominio** del sistema.  
Aunque en la implementación actual la lógica trabaja directamente con los **modelos de MongoDB** (`/infrastructure/database/models`), aquí se documenta cómo lucen los objetos principales del negocio:

- `User`: representa un usuario del sistema (atributos, permisos, credenciales).
- `Log`: representa un registro de login (actividad de autenticación de un usuario).

## Propósito
- Servir como **documentación centralizada** de las entidades clave.
- Listar qué **funciones, use cases y repositorios** están relacionadas con cada entidad.
- Posible base para evolucionar hacia una arquitectura más estricta (DDD), donde los repositorios devuelvan entidades en lugar de documentos de base de datos.

## Archivos
- **`user.entity.js`**  
  Define la estructura de un usuario. Documenta la relación con `user.model.js`, `user.repository.js`, y los casos de uso de login y gestión de usuarios.

- **`log.entity.js`**  
  Define la estructura de un registro de login. Documenta la relación con `log.model.js`, `log_user.repository.js` y los casos de uso de consulta de logs.

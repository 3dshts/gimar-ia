# Infrastructure / Database / Models

Este directorio define los **modelos de Mongoose** que representan las colecciones en MongoDB.  
Son la base para que los repositorios realicen las operaciones de lectura y escritura.

## Propósito
- Mapear las entidades del negocio a estructuras persistidas en MongoDB.
- Definir los campos, tipos y restricciones de cada colección.
- Proveer objetos `Model` que se utilizan en los repositorios.

## Archivos
- **`user.model.js`**  
  Define la colección `USER`. Representa a los usuarios del sistema, incluyendo sus credenciales, correo, rol de administrador y permisos asociados.

- **`log.model.js`**  
  Define la colección `LOG_USER`. Representa los registros de login/actividad de usuarios, almacenando información de acceso y fecha del evento.

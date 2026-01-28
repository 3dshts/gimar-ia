# Infrastructure / Database / Repositories

Este directorio contiene las **implementaciones de repositorios** que acceden a la base de datos usando los modelos de Mongoose.  
Su responsabilidad es **encapsular las consultas** y devolver datos listos para la capa de aplicación.

## Propósito
- Aislar la lógica de acceso a datos del resto de la aplicación.
- Ofrecer métodos claros para lectura/escritura.
- Aplicar paginación, ordenación y filtros según necesidades del caso de uso.

## Archivos
- **`log.repository.js`**  
  Proporciona operaciones sobre la colección de logs (`LOG_USER`):
  - `findAllPaginated({ page, limit })`: lista logs paginados, ordenados por fecha descendente, e incluye metadatos de paginación.
  - `findAllFilteredPaginated({ page, limit, filters })`: aplica filtros por `user`, `fullName`, `email` (búsqueda parcial insensible a mayúsculas) y por rango de fechas (`from`, `to`), devuelve resultados paginados y totales.
  - `create(logData)`: crea un nuevo registro de log con los campos `code`, `user`, `fullName`, `email`, `date`.

- **`user.repository.js`**  
  Proporciona operaciones sobre la colección de usuarios (`USER`):
  - `findAll()`: devuelve todos los usuarios (consulta directa al modelo).
  - `findByUsername(username)`: busca un usuario por su nombre de usuario e informa por consola si se encontró o no.

# Application / Use Cases

Este directorio agrupa los **casos de uso** de la aplicación.  
Cada caso de uso orquesta una acción de negocio concreta consumiendo **repositorios** (contratos), sin conocer detalles de infraestructura (DB, HTTP, etc.).

## Propósito
- Encapsular la lógica de aplicación (workflows).
- Aislar a la capa web de la persistencia y de otros adaptadores.
- Exponer un método `execute(...)` (o similar) por cada acción.

## Archivos
- **`get_all_logs_filtered.usecase.js`**  
  Lista logs con **paginación** y **filtros** (texto parcial en `user`, `fullName`, `email` y rango de fechas).

- **`get_all_logs.usecase.js`**  
  Lista logs con **paginación**, ordenados por fecha descendente.

- **`get_all_users.usecase.js`**  
  Devuelve todos los usuarios.

- **`login.usecase.js`**  
  Autentica a un usuario por `username` y `password`, emite un **JWT** y **registra un log** del login exitoso.

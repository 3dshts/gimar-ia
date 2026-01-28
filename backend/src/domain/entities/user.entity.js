// backend/src/domain/entities/user.entity.js

// Representa un usuario en nuestro sistema, independiente de la base de datos.
// Actualmente se usa como documentación de la estructura del dominio.

export class User {
  constructor(code, fullName, user, password, email, permissions) {
    this.code = code;
    this.fullName = fullName;
    this.user = user;
    this.password = password;
    this.email = email;
    this.permissions = permissions;
  }
}

/**
 * 🔗 Funciones relacionadas con User en el sistema:
 * - infrastructure/database/models/user.model.js → Definición del esquema en MongoDB
 * - infrastructure/database/repositories/user.repository.js → Consultas a la DB
 * - application/use_cases/login.usecase.js → Autenticación de usuario
 * - application/use_cases/get_all_users.usecase.js → Listado de usuarios
 * - web/controllers/auth.controller.js → Endpoints de login/registro
 */

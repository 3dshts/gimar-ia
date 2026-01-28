// backend/src/domain/entities/log.entity.js

// Representa un registro de login en el sistema.
// Actualmente se usa como documentación de la estructura del dominio.

export class Log {
  constructor(code, user, fullName, email, date) {
    this.code = code;
    this.user = user;
    this.fullName = fullName;
    this.email = email;
    this.date = date;
  }
}

/**
 * 🔗 Funciones relacionadas con Log en el sistema:
 * - infrastructure/database/models/log.model.js → Definición del esquema en MongoDB
 * - infrastructure/database/repositories/log_user.repository.js → Consultas a la DB
 * - application/use_cases/get_all_logs.usecase.js → Listado completo de logs
 * - application/use_cases/get_all_logs_filtered.usecase.js → Listado filtrado de logs
 * - web/controllers/admin.controller.js → Endpoints para administración de logs
 */

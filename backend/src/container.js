// src/container.js
// -----------------------------------------------------------------------------
// Contenedor de inyección de dependencias.
// Aquí se instancian TODAS las dependencias de la aplicación y se conectan
// entre sí. Es el único lugar donde se hace "new" de repositorios,
// casos de uso y controladores.
//
// ESTADO ACTUAL:
// - auth ✅
// - admin ✅
// - external ✅
// - google, calendar: pendientes
// -----------------------------------------------------------------------------

// --- Configuración centralizada ---
import config from "./config/env.js";

// --- Google Services (para inyectar en repositorios) ---
import {
  getDrive,
  getCalendar,
  bufferToStream,
} from "./infrastructure/web/middlewares/google.middleware.js";
import driveIds from "./config/drive-ids.json" with { type: "json" };

// --- Repositorios ---
import { UserRepository } from "./infrastructure/database/repositories/user.repository.js";
import { LogRepository } from "./infrastructure/database/repositories/log_user.repository.js";
import { ExternalAPIRepository } from "./infrastructure/database/repositories/external_api.repository.js";
import { CalendarRepository } from "./infrastructure/database/google/calendar.repository.js";
import { DriveRepository } from "./infrastructure/database/google/drive.repository.js";

// --- Casos de uso: Auth ---
import { LoginUseCase } from "./application/use_cases/login.usecase.js";

// --- Casos de uso: Admin ---
import { GetAllUsersUseCase } from "./application/use_cases/get_all_users.usecase.js";
import { GetAllLogsUseCase } from "./application/use_cases/get_all_logs.usecase.js";
import { GetAllLogsFilteredUseCase } from "./application/use_cases/get_all_logs_filtered.usecase.js";

// --- Casos de uso: External ---
import { GetNotasProduccionUseCase } from "./application/use_cases/get_notas_produccion.usecase.js";

// --- Casos de uso: Calendar ---
import { ListCalendarCommentsUseCase } from "./application/use_cases/list_calendar_comments.usecase.js";
import { CreateCalendarCommentUseCase } from "./application/use_cases/create_calendar_comment.usecase.js";
import { UpdateCalendarCommentUseCase } from "./application/use_cases/update_calendar_comment.usecase.js";
import { DeleteCalendarCommentUseCase } from "./application/use_cases/delete_calendar_comment.usecase.js";

// --- Casos de uso: Drive ---
import { UploadImageAlertUseCase } from "./application/use_cases/upload_image_drive.usecase.js";
import { UploadExcelUseCase } from "./application/use_cases/upload_excel_drive.usecase.js";
import { UploadPdfUseCase } from "./application/use_cases/upload_pdf_drive.usecase.js";
import { CheckFolderDriveUseCase } from "./application/use_cases/check_folder_drive.usecase.js";
import { CreateFolderStructureDriveUseCase } from "./application/use_cases/create_folder_structure_drive.usecase.js";

// --- Controladores ---
import { AuthController } from "./infrastructure/web/controllers/auth.controller.js";
import { AdminController } from "./infrastructure/web/controllers/admin.controller.js";
import { ExternalApiController } from "./infrastructure/web/controllers/external_api.controller.js";
import { CalendarController } from "./infrastructure/web/controllers/calendar.controller.js";
import { GoogleController } from "./infrastructure/web/controllers/google.controller.js";

// --- Rutas ---
import { createAuthRoutes } from "./infrastructure/web/routes/auth.routes.js";
import { createAdminRoutes } from "./infrastructure/web/routes/admin.routes.js";
import { createExternalApiRoutes } from "./infrastructure/web/routes/external_api.routes.js";
import { createCalendarRoutes } from "./infrastructure/web/routes/calendar.routes.js";
import { createGoogleRoutes } from "./infrastructure/web/routes/google.routes.js";

/**
 * Crea y devuelve todas las dependencias de la aplicación ya conectadas.
 * Se llama una sola vez al arrancar el servidor.
 * @returns {Object} Objeto con todas las rutas listas para montar en Express.
 */
export function createContainer() {
  // ===========================
  // REPOSITORIOS
  // ===========================
  // Se instancian una sola vez y se comparten entre los casos de uso que los necesiten
  const userRepository = new UserRepository();
  const logRepository = new LogRepository();
  const externalApiRepository = new ExternalAPIRepository();
  // Calendar — recibe la instancia del cliente de Google Calendar y el ID del calendario
  const calendarRepository = new CalendarRepository({
    calendar: getCalendar(),
    calendarId: config.google.calendarId,
  });
  // Drive — recibe la instancia del cliente de Google Drive, los IDs y el helper bufferToStream
  const driveRepository = new DriveRepository({
    drive: getDrive(),
    driveIds,
    bufferToStream,
  });

  // ===========================
  // CASOS DE USO
  // ===========================

  // Auth
  const loginUseCase = new LoginUseCase(userRepository, logRepository);

  // Admin
  const getAllUsersUseCase = new GetAllUsersUseCase(userRepository);
  const getAllLogsUseCase = new GetAllLogsUseCase(logRepository);
  const getAllLogsFilteredUseCase = new GetAllLogsFilteredUseCase(
    logRepository,
  );

  // External — recibe el repositorio y la config del ERP por inyección
  const getNotasProduccionUseCase = new GetNotasProduccionUseCase({
    externalApiRepository,
    erpConfig: config.erp,
  });

  // Calendar
  const listCalendarCommentsUseCase = new ListCalendarCommentsUseCase(
    calendarRepository,
  );
  const createCalendarCommentUseCase = new CreateCalendarCommentUseCase(
    calendarRepository,
  );
  const updateCalendarCommentUseCase = new UpdateCalendarCommentUseCase(
    calendarRepository,
  );
  const deleteCalendarCommentUseCase = new DeleteCalendarCommentUseCase(
    calendarRepository,
  );

  // Google Drive
  const uploadImageAlertUseCase = new UploadImageAlertUseCase(driveRepository);
  const uploadExcelUseCase = new UploadExcelUseCase(driveRepository);
  const uploadPdfUseCase = new UploadPdfUseCase(driveRepository);
  const checkFolderUseCase = new CheckFolderDriveUseCase(driveRepository);
  const createFolderStructureUseCase = new CreateFolderStructureDriveUseCase(driveRepository);

  // ===========================
  // CONTROLADORES
  // ===========================
  const authController = new AuthController({ loginUseCase, userRepository });
  const adminController = new AdminController({
    getAllUsersUseCase,
    getAllLogsUseCase,
    getAllLogsFilteredUseCase,
  });
  const externalApiController = new ExternalApiController({
    getNotasProduccionUseCase,
  });

  const calendarController = new CalendarController({
    listCalendarCommentsUseCase,
    createCalendarCommentUseCase,
    updateCalendarCommentUseCase,
    deleteCalendarCommentUseCase,
    calendarRepository,
  });

  const googleController = new GoogleController({
    uploadImageAlertUseCase,
    uploadExcelUseCase,
    uploadPdfUseCase,
    checkFolderUseCase,
    createFolderStructureUseCase,
    driveRepository,
    lambdaConfig: config.lambda,
  });

  // ===========================
  // RUTAS
  // ===========================
  const authRoutes = createAuthRoutes({ authController });
  const adminRoutes = createAdminRoutes({ adminController });
  const externalApiRoutes = createExternalApiRoutes({ externalApiController });
  const calendarRoutes = createCalendarRoutes({ calendarController });
  const googleRoutes = createGoogleRoutes({ googleController });

  return {
    authRoutes,
    adminRoutes,
    externalApiRoutes,
    calendarRoutes,
    googleRoutes,
  };
}

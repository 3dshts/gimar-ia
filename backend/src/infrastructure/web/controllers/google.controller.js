// src/infrastructure/web/controllers/google.controller.js
// -----------------------------------------------------------------------------
// Controlador de Google Drive.
// Gestiona la subida de archivos (imágenes, Excel, PDF), verificación de
// carpetas y creación de estructuras de directorios en Drive.
// Recibe todos los casos de uso y configuración por inyección de dependencias.
// -----------------------------------------------------------------------------

export class GoogleController {
  /**
   * @param {Object} deps - Dependencias inyectadas desde el contenedor.
   * @param {Object} deps.uploadImageAlertUseCase - Subida de imágenes de alertas.
   * @param {Object} deps.uploadExcelUseCase - Subida de Excel y gestión de carpetas.
   * @param {Object} deps.uploadPdfUseCase - Subida de PDFs.
   * @param {Object} deps.checkFolderUseCase - Verificación de carpetas/archivos.
   * @param {Object} deps.createFolderStructureUseCase - Creación recursiva de carpetas.
   * @param {Object} deps.driveRepository - Repositorio de Drive (para IDs de carpetas y permisos).
   * @param {Object} deps.lambdaConfig - URLs de las Lambdas de extracción de imágenes.
   */
  constructor({
    uploadImageAlertUseCase,
    uploadExcelUseCase,
    uploadPdfUseCase,
    checkFolderUseCase,
    createFolderStructureUseCase,
    driveRepository,
    lambdaConfig,
  }) {
    this.uploadImageAlertUseCase = uploadImageAlertUseCase;
    this.uploadExcelUseCase = uploadExcelUseCase;
    this.uploadPdfUseCase = uploadPdfUseCase;
    this.checkFolderUseCase = checkFolderUseCase;
    this.createFolderStructureUseCase = createFolderStructureUseCase;
    this.driveRepository = driveRepository;
    this.lambdaConfig = lambdaConfig;
  }

  /**
   * POST /api/google/uploadImgAlert
   * Sube una imagen de alerta a Drive en la carpeta del día (zona Madrid).
   * Requiere form-data con campo "file" (imagen).
   */
  async uploadImgAlert(req, res, next) {
    try {
      if (!req.file) {
        return res
          .status(400)
          .json({ error: 'Falta archivo (form-data "file")' });
      }

      if (!req.file.mimetype.startsWith("image/")) {
        return res
          .status(400)
          .json({ error: "El archivo debe ser una imagen" });
      }

      const parentFolderId = this.driveRepository.getImagesAlertsFolderId();

      const result = await this.uploadImageAlertUseCase.execute({
        file: req.file,
        originalname: req.file.originalname,
        mimetype: req.file.mimetype,
        buffer: req.file.buffer,
        parentFolderId,
      });

      return res.status(201).json(result);
    } catch (error) {
      console.error("[GoogleController] Error al subir imagen:", error);
      const code = error?.code || error?.response?.status || 500;
      return res.status(code).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/uploadPrototypeExcel
   * Sube un Excel de prototipo a Drive y extrae imágenes mediante Lambda externa.
   * Requiere form-data con campo "file" (Excel) y "marca" en el body.
   * Marcas válidas: "STUART WEITZMAN", "VERSACE".
   */
  async uploadPrototypeExcel(req, res, next) {
    try {
      if (!req.file) {
        return res
          .status(400)
          .json({ error: 'Falta archivo (form-data "file")' });
      }

      const { marca } = req.body;
      if (!marca) {
        return res
          .status(400)
          .json({ error: 'Falta el campo "marca" en el body' });
      }

      const marcasValidas = ["STUART WEITZMAN", "VERSACE"];
      if (!marcasValidas.includes(marca)) {
        return res.status(400).json({
          error: `Marca no válida. Debe ser una de: ${marcasValidas.join(", ")}`,
        });
      }

      const excelMimeTypes = [
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.ms-excel",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.template",
        "application/vnd.ms-excel.template.macroEnabled.12",
      ];
      if (!excelMimeTypes.includes(req.file.mimetype)) {
        return res.status(400).json({
          error: "El archivo debe ser un Excel (.xlsx, .xls, .xltx, .xltm)",
        });
      }

      // Resolver URL de la Lambda según la marca
      let imagenesEndpoint;
      if (marca === "STUART WEITZMAN") {
        imagenesEndpoint = this.lambdaConfig.swImagesUrl;
      } else if (marca === "VERSACE") {
        imagenesEndpoint = this.lambdaConfig.versaceImagesUrl;
      }

      // Llamar a la Lambda para extraer imágenes del Excel
      let id_imagen;
      try {
        const imagenesResponse = await fetch(imagenesEndpoint, {
          method: "POST",
          headers: { "Content-Type": "application/octet-stream" },
          body: req.file.buffer,
        });

        if (!imagenesResponse.ok) {
          throw new Error(
            `Error en la API de imágenes: ${imagenesResponse.status} ${imagenesResponse.statusText}`,
          );
        }

        id_imagen = await imagenesResponse.json();
      } catch (apiError) {
        console.error(
          "[GoogleController] Error en las llamadas a las APIs:",
          apiError,
        );
        return res.status(500).json({
          error: `Error al procesar el Excel con las APIs externas: ${apiError.message}`,
        });
      }

      // Resolver carpeta raíz según la marca
      let parentFolderId;
      switch (marca) {
        case "STUART WEITZMAN":
          parentFolderId = this.driveRepository.getSWPrototipeFolderId();
          break;
        case "VERSACE":
          parentFolderId = this.driveRepository.getVersacePrototipeFolderId();
          break;
      }

      // Subir el Excel a Drive
      const excelResult = await this.uploadExcelUseCase.executeFolder({
        file: req.file,
        originalname: req.file.originalname,
        mimetype: req.file.mimetype,
        buffer: req.file.buffer,
        parentFolderId,
      });

      // Asignar permisos públicos a cada imagen extraída
      id_imagen.archivos.forEach((archivo) => {
        this.driveRepository.setPublicReadPermissions(archivo.id);
      });

      console.log(id_imagen);

      return res.status(201).json({
        message: "Excel subido e imágenes extraídas correctamente",
        id_archivo: excelResult.id,
        nombre_archivo: excelResult.name,
        id_imagen,
      });
    } catch (error) {
      console.error(
        "[GoogleController] Error al subir prototipo Excel:",
        error,
      );
      const code = error?.code || error?.response?.status || 500;
      return res.status(code).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/uploadPedidoPDF
   * Sube un PDF de pedido Versace a Drive.
   * Requiere form-data con campo "file" (PDF).
   */
  async uploadPedidoPdf(req, res, next) {
    try {
      if (!req.file) {
        return res
          .status(400)
          .json({ error: 'Falta archivo (form-data "file")' });
      }

      const pdfMimeTypes = ["application/pdf"];
      if (!pdfMimeTypes.includes(req.file.mimetype)) {
        return res
          .status(400)
          .json({ error: "El archivo debe ser un PDF (.pdf)" });
      }

      const parentFolderId = this.driveRepository.getVersacePedidosFolderId();

      const pdfResult = await this.uploadPdfUseCase.execute({
        file: req.file,
        originalname: req.file.originalname,
        mimetype: req.file.mimetype,
        buffer: req.file.buffer,
        parentFolderId,
      });

      return res.status(201).json({
        message: "PDF subido correctamente",
        pdf: {
          id: pdfResult.id,
          name: pdfResult.name,
          webViewLink: pdfResult.webViewLink,
          webContentLink: pdfResult.webContentLink,
        },
      });
    } catch (error) {
      console.error("[GoogleController] Error al subir PDF:", error);
      const code = error?.code || error?.response?.status || 500;
      return res.status(code).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/uploadIntrastatPDF
   * Sube uno o varios PDFs de Intrastat a Drive, organizados por tipo (COMPRA/VENTA).
   * Requiere form-data con campo "files" (PDFs) y "marca" en el body.
   */
  async uploadIntrastatPDF(req, res, next) {
    try {
      const files = req.files || [];

      if (!files || files.length === 0) {
        return res
          .status(400)
          .json({ error: 'Falta archivo(s) (form-data "files")' });
      }

      const { marca } = req.body;
      if (!marca) {
        return res
          .status(400)
          .json({ error: 'Falta el campo "marca" en el body' });
      }

      const marcasValidas = ["COMPRA", "VENTA"];
      if (!marcasValidas.includes(marca)) {
        return res.status(400).json({
          error: `Marca no válida. Debe ser una de: ${marcasValidas.join(", ")}`,
        });
      }

      // Verificar que todos los archivos son PDFs
      const pdfMimeTypes = ["application/pdf"];
      const archivosInvalidos = files.filter(
        (file) => !pdfMimeTypes.includes(file.mimetype),
      );

      if (archivosInvalidos.length > 0) {
        return res.status(400).json({
          error: `Todos los archivos deben ser PDF. Archivos inválidos: ${archivosInvalidos
            .map((f) => f.originalname)
            .join(", ")}`,
        });
      }

      // Resolver carpeta destino según el tipo de operación
      let parentFolderId;
      switch (marca) {
        case "COMPRA":
          parentFolderId = this.driveRepository.getIntrastatComprasFolderId();
          break;
        case "VENTA":
          parentFolderId = this.driveRepository.getIntrastatVentasFolderId();
          break;
      }

      // Crear carpeta del día y subir todos los PDFs en paralelo
      const idCarpeta =
        await this.uploadPdfUseCase.executeFolderDia(parentFolderId);

      const uploadPromises = files.map((file) =>
        this.uploadPdfUseCase.execute({
          file: file,
          originalname: file.originalname,
          mimetype: file.mimetype,
          buffer: file.buffer,
          parentFolderId: idCarpeta,
        }),
      );

      const resultados = await Promise.allSettled(uploadPromises);

      // Clasificar resultados en exitosos y fallidos
      const exitosos = [];
      const fallidos = [];

      resultados.forEach((resultado, index) => {
        if (resultado.status === "fulfilled") {
          const pdfResult = resultado.value;
          exitosos.push({
            id: pdfResult.id,
            name: pdfResult.name,
            webViewLink: pdfResult.webViewLink,
            webContentLink: pdfResult.webContentLink,
            folderId: pdfResult.targetFolderId,
            folderName: pdfResult.folderName,
          });
        } else {
          fallidos.push({
            archivo: files[index].originalname,
            error: resultado.reason?.message || "Error desconocido",
          });
        }
      });

      // 201 = todos OK, 500 = todos fallaron, 207 = resultado mixto
      const statusCode =
        fallidos.length === 0 ? 201 : exitosos.length === 0 ? 500 : 207;

      return res.status(statusCode).json({
        message: `${exitosos.length} de ${files.length} PDF(s) subido(s) correctamente`,
        exitosos,
        fallidos: fallidos.length > 0 ? fallidos : undefined,
        resumen: {
          total: files.length,
          exitosos: exitosos.length,
          fallidos: fallidos.length,
        },
      });
    } catch (error) {
      console.error("[GoogleController] Error al subir PDF(s):", error);
      const code = error?.code || error?.response?.status || 500;
      return res.status(code).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/uploadInventarioPDF
   * Sube uno o varios PDFs de inventario a Drive en la carpeta del día.
   * Requiere form-data con campo "files" (PDFs).
   */
  async uploadInventarioPDF(req, res, next) {
    try {
      const files = req.files || [];

      if (!files || files.length === 0) {
        return res
          .status(400)
          .json({ error: 'Falta archivo(s) (form-data "files")' });
      }

      const pdfMimeTypes = ["application/pdf"];
      const archivosInvalidos = files.filter(
        (file) => !pdfMimeTypes.includes(file.mimetype),
      );

      if (archivosInvalidos.length > 0) {
        return res.status(400).json({
          error: `Todos los archivos deben ser PDF. Archivos inválidos: ${archivosInvalidos
            .map((f) => f.originalname)
            .join(", ")}`,
        });
      }

      const parentFolderId = this.driveRepository.getInventarioFolderID();

      // Crear carpeta del día y subir todos los PDFs en paralelo
      const idCarpeta =
        await this.uploadPdfUseCase.executeFolderDia(parentFolderId);

      const uploadPromises = files.map((file) =>
        this.uploadPdfUseCase.execute({
          file: file,
          originalname: file.originalname,
          mimetype: file.mimetype,
          buffer: file.buffer,
          parentFolderId: idCarpeta,
        }),
      );

      const resultados = await Promise.allSettled(uploadPromises);

      const exitosos = [];
      const fallidos = [];

      resultados.forEach((resultado, index) => {
        if (resultado.status === "fulfilled") {
          const pdfResult = resultado.value;
          exitosos.push({
            id: pdfResult.id,
            name: pdfResult.name,
            webViewLink: pdfResult.webViewLink,
            webContentLink: pdfResult.webContentLink,
            folderId: pdfResult.targetFolderId,
            folderName: pdfResult.folderName,
          });
        } else {
          fallidos.push({
            archivo: files[index].originalname,
            error: resultado.reason?.message || "Error desconocido",
          });
        }
      });

      const statusCode =
        fallidos.length === 0 ? 201 : exitosos.length === 0 ? 500 : 207;

      return res.status(statusCode).json({
        message: `${exitosos.length} de ${files.length} PDF(s) subido(s) correctamente`,
        exitosos,
        fallidos: fallidos.length > 0 ? fallidos : undefined,
        resumen: {
          total: files.length,
          exitosos: exitosos.length,
          fallidos: fallidos.length,
        },
      });
    } catch (error) {
      console.error("[GoogleController] Error al subir PDF(s):", error);
      const code = error?.code || error?.response?.status || 500;
      return res.status(code).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/uploadNominasExcels
   * Sube múltiples Excels de nóminas organizados en carpetas por año/mes/tipo.
   * Requiere form-data con campos:
   *   - archivoResumen (1 Excel)
   *   - archivosDetalle1 (múltiples Excels de resúmenes)
   *   - archivosDetalle2 (múltiples Excels de retenciones)
   *   - anio y mes en el body
   */
  async uploadNominasExcels(req, res, next) {
    try {
      console.log("[NominasController] ========== INICIO REQUEST ==========");
      console.log("[NominasController] Body:", req.body);
      console.log(
        "[NominasController] Files keys:",
        Object.keys(req.files || {}),
      );

      const archivoResumen = req.files?.archivoResumen?.[0];
      const archivosDetalle1 = req.files?.archivosDetalle1 || [];
      const archivosDetalle2 = req.files?.archivosDetalle2 || [];

      console.log(
        "[NominasController] archivoResumen:",
        archivoResumen ? archivoResumen.originalname : "NO EXISTE",
      );
      console.log(
        "[NominasController] archivosDetalle1 count:",
        archivosDetalle1.length,
      );
      console.log(
        "[NominasController] archivosDetalle2 count:",
        archivosDetalle2.length,
      );

      if (!archivoResumen) {
        return res
          .status(400)
          .json({ error: "Falta el archivo de nóminas (archivoResumen)" });
      }

      if (archivosDetalle1.length === 0) {
        return res
          .status(400)
          .json({ error: "Faltan archivos de resúmenes (archivosDetalle1)" });
      }

      if (archivosDetalle2.length === 0) {
        return res
          .status(400)
          .json({ error: "Faltan archivos de retenciones (archivosDetalle2)" });
      }

      const { anio, mes } = req.body;
      console.log("[NominasController] Año:", anio, "| Mes:", mes);

      if (!anio || !mes) {
        return res
          .status(400)
          .json({ error: 'Faltan los campos "anio" y/o "mes" en el body' });
      }

      // Validar que todos los archivos son Excel
      const excelMimeTypes = [
        "application/vnd.ms-excel",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.ms-excel.sheet.macroenabled.12",
      ];

      const todosLosArchivos = [
        archivoResumen,
        ...archivosDetalle1,
        ...archivosDetalle2,
      ];

      console.log("[NominasController] Validando MIME types de archivos...");
      todosLosArchivos.forEach((file) => {
        console.log(
          `[NominasController] ${file.originalname} -> ${file.mimetype} -> ${
            excelMimeTypes.includes(file.mimetype) ? "VÁLIDO" : "INVÁLIDO"
          }`,
        );
      });

      const archivosInvalidos = todosLosArchivos.filter(
        (file) => !excelMimeTypes.includes(file.mimetype.toLowerCase()),
      );

      if (archivosInvalidos.length > 0) {
        console.log(
          "[NominasController] ERROR: Archivos con MIME inválido:",
          archivosInvalidos.map((f) => `${f.originalname} (${f.mimetype})`),
        );
        return res.status(400).json({
          error: `Todos los archivos deben ser Excel. Archivos inválidos: ${archivosInvalidos
            .map((f) => f.originalname)
            .join(", ")}`,
        });
      }

      console.log("[NominasController] Validación exitosa. Continuando...");

      const parentFolderIdAsesorias =
        this.driveRepository.getNominasAsesoriasFolderID();
      const parentFolderIdNominas =
        this.driveRepository.getNominasNominasFolderID();

      console.log("[NominasController] Carpetas padre resueltas:");
      console.log(
        `[NominasController] Asesorías ID: ${parentFolderIdAsesorias}`,
      );
      console.log(`[NominasController] Nóminas ID: ${parentFolderIdNominas}`);

      // Paso 1: Obtener/crear carpetas base (Año / Mes)
      const folderAnoMes = await this.uploadExcelUseCase.getOrCreateMesAnio({
        parentFolderId: parentFolderIdAsesorias,
        mes,
        anio,
      });

      const folderAnoMesNomina =
        await this.uploadExcelUseCase.getOrCreateMesAnio({
          parentFolderId: parentFolderIdNominas,
          mes,
          anio,
        });

      // Paso 2: Crear subcarpetas (RETENCIONES, RESUMEN, NOMINAS) en paralelo
      const [folderRetenciones, folderResumenes, folderNominas] =
        await Promise.all([
          this.uploadExcelUseCase.createFolderIfNotExists({
            folderName: "RETENCIONES",
            parentFolderId: folderAnoMes,
          }),
          this.uploadExcelUseCase.createFolderIfNotExists({
            folderName: "RESUMEN",
            parentFolderId: folderAnoMes,
          }),
          this.uploadExcelUseCase.createFolderIfNotExists({
            folderName: "NOMINAS",
            parentFolderId: folderAnoMesNomina,
          }),
        ]);

      // Paso 3: Subir todos los archivos en paralelo
      const retencionesPromises = archivosDetalle2.map(async (archivo) => {
        try {
          const result = await this.uploadExcelUseCase.uploadFileToFolder({
            originalname: archivo.originalname,
            mimetype: archivo.mimetype,
            buffer: archivo.buffer,
            folderId: folderRetenciones,
          });
          return result.id;
        } catch (error) {
          console.error(`Error retención ${archivo.originalname}:`, error);
          return null;
        }
      });

      const resumenesPromises = archivosDetalle1.map(async (archivo) => {
        try {
          const result = await this.uploadExcelUseCase.uploadFileToFolder({
            originalname: archivo.originalname,
            mimetype: archivo.mimetype,
            buffer: archivo.buffer,
            folderId: folderResumenes,
          });
          return result.id;
        } catch (error) {
          console.error(`Error resumen ${archivo.originalname}:`, error);
          return null;
        }
      });

      const [retencionesIds, resumenesIds, excelResumen] = await Promise.all([
        Promise.all(retencionesPromises),
        Promise.all(resumenesPromises),
        this.uploadExcelUseCase.uploadFileToFolder({
          originalname: archivoResumen.originalname,
          mimetype: archivoResumen.mimetype,
          buffer: archivoResumen.buffer,
          folderId: folderNominas,
        }),
      ]);

      // Filtrar errores (nulls) de las subidas que fallaron
      const retencionesData = retencionesIds.filter((id) => id !== null);
      const nominasData = resumenesIds.filter((id) => id !== null);

      return res.status(200).json({
        id_excel_resumen: excelResumen.id,
        ids_retenciones: retencionesData,
        ids_nominas: nominasData,
      });
    } catch (error) {
      console.error("[NominasController] Error al procesar nóminas:", error);
      const code = error?.code || error?.response?.status || 500;
      return res.status(code).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/uploadSituacionVersace
   * Sube 4 archivos de Situación de Pedidos Versace:
   *   - informeFechas (1 PDF)
   *   - dirma (1 Excel)
   *   - informePasado (1 Excel)
   *   - informeNuevo (1 Excel)
   * Cada archivo se sube a su carpeta correspondiente en Drive.
   */
  async uploadSituacionVersace(req, res, next) {
    try {
      if (!req.files) {
        return res.status(400).json({ error: "No se recibieron archivos" });
      }

      const { informeFechas, dirma, informePasado, informeNuevo } = req.files;

      // Validar presencia de cada archivo requerido
      if (!informeFechas || !informeFechas[0]) {
        return res
          .status(400)
          .json({ error: 'Falta el archivo "informeFechas" (PDF)' });
      }
      if (!dirma || !dirma[0]) {
        return res
          .status(400)
          .json({ error: 'Falta el archivo "dirma" (Excel)' });
      }
      if (!informePasado || !informePasado[0]) {
        return res
          .status(400)
          .json({ error: 'Falta el archivo "informePasado" (Excel)' });
      }
      if (!informeNuevo || !informeNuevo[0]) {
        return res
          .status(400)
          .json({ error: 'Falta el archivo "informeNuevo" (Excel)' });
      }

      // Tipos MIME aceptados (incluye octet-stream para archivos sin MIME explícito)
      const pdfMimeTypes = ["application/pdf", "application/octet-stream"];
      const excelMimeTypes = [
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.ms-excel",
        "application/vnd.ms-excel.sheet.macroEnabled.12",
        "application/octet-stream",
      ];

      if (!pdfMimeTypes.includes(informeFechas[0].mimetype)) {
        return res
          .status(400)
          .json({ error: 'El archivo "informeFechas" debe ser un PDF' });
      }
      if (!excelMimeTypes.includes(dirma[0].mimetype)) {
        return res.status(400).json({
          error: 'El archivo "dirma" debe ser un Excel (.xlsx, .xls, .xlsm)',
        });
      }
      if (!excelMimeTypes.includes(informePasado[0].mimetype)) {
        return res.status(400).json({
          error:
            'El archivo "informePasado" debe ser un Excel (.xlsx, .xls, .xlsm)',
        });
      }
      if (!excelMimeTypes.includes(informeNuevo[0].mimetype)) {
        return res.status(400).json({
          error:
            'El archivo "informeNuevo" debe ser un Excel (.xlsx, .xls, .xlsm)',
        });
      }

      // Resolver carpetas destino según el tipo de archivo
      const parentFolderIdPDF = this.driveRepository.getSituacionPedidosPDF();
      const parentFolderIdDirma =
        this.driveRepository.getSituacionPedidosDirma();
      const parentFolderIdVersace =
        this.driveRepository.getSituacionPedidosVersace();

      console.log('[SituacionVersace] Subiendo archivos...');

      // PDF: crear carpeta del día y subir el archivo en dos pasos
      const folderDiaPDF = await this.uploadPdfUseCase.executeFolderDia(parentFolderIdPDF);
      const informeFechasResult = await this.uploadPdfUseCase.execute({
        file: informeFechas[0],
        originalname: informeFechas[0].originalname,
        mimetype: informeFechas[0].mimetype,
        buffer: informeFechas[0].buffer,
        parentFolderId: folderDiaPDF,
      });
      console.log(`[SituacionVersace] Informe Fechas subido: ${informeFechasResult.id}`);

      // Excel DIRMA
      const dirmaResult = await this.uploadExcelUseCase.executeFolderDia({
        file: dirma[0],
        originalname: dirma[0].originalname,
        mimetype: dirma[0].mimetype,
        buffer: dirma[0].buffer,
        parentFolderId: parentFolderIdDirma,
      });
      console.log(`[SituacionVersace] DIRMA subido: ${dirmaResult.id}`);

      // Excel Informe Pasado
      const informePasadoResult = await this.uploadExcelUseCase.executeFolderDia({
        file: informePasado[0],
        originalname: informePasado[0].originalname,
        mimetype: informePasado[0].mimetype,
        buffer: informePasado[0].buffer,
        parentFolderId: parentFolderIdVersace,
      });
      console.log(`[SituacionVersace] Informe Pasado subido: ${informePasadoResult.id}`);

      // Excel Informe Nuevo
      const informeNuevoResult = await this.uploadExcelUseCase.executeFolderDia({
        file: informeNuevo[0],
        originalname: informeNuevo[0].originalname,
        mimetype: informeNuevo[0].mimetype,
        buffer: informeNuevo[0].buffer,
        parentFolderId: parentFolderIdVersace,
      });
      console.log(`[SituacionVersace] Informe Nuevo subido: ${informeNuevoResult.id}`);

      return res.status(201).json({
        message: "Archivos de Situación Pedidos Versace subidos correctamente",
        id_informe_fechas: informeFechasResult.id,
        id_dirma: dirmaResult.id,
        id_informe_pasado: informePasadoResult.id,
        id_informe_nuevo: informeNuevoResult.id,
      });
    } catch (error) {
      console.error("[SituacionVersace] Error al subir archivos:", error);
      const code = error?.code || error?.response?.status || 500;
      return res.status(code).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/uploadSituacionSW
   * Sube archivos de Situación de Pedidos Stuart Weitzman:
   *   - erpSusy (múltiples PDFs)
   *   - planningCliente (1 Excel)
   * Los PDFs se suben secuencialmente para evitar rate limiting de Drive.
   */
  async uploadSituacionSW(req, res, next) {
    try {
      if (!req.files) {
        return res.status(400).json({ error: "No se recibieron archivos" });
      }

      const { erpSusy, planningCliente } = req.files;

      if (!erpSusy || erpSusy.length === 0) {
        return res
          .status(400)
          .json({ error: 'Falta al menos un archivo "erpSusy" (PDF)' });
      }
      if (!planningCliente || !planningCliente[0]) {
        return res
          .status(400)
          .json({ error: 'Falta el archivo "planningCliente" (Excel)' });
      }

      const pdfMimeTypes = ["application/pdf", "application/octet-stream"];
      const excelMimeTypes = [
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.ms-excel",
        "application/vnd.ms-excel.sheet.macroEnabled.12",
        "application/octet-stream",
      ];

      for (const pdf of erpSusy) {
        if (!pdfMimeTypes.includes(pdf.mimetype)) {
          return res.status(400).json({
            error: `El archivo "${pdf.originalname}" debe ser un PDF`,
          });
        }
      }

      if (!excelMimeTypes.includes(planningCliente[0].mimetype)) {
        return res.status(400).json({
          error:
            'El archivo "planningCliente" debe ser un Excel (.xlsx, .xls, .xlsm)',
        });
      }

      const parentFolderIdERP = this.driveRepository.getSituacionPedidosERP();
      const parentFolderIdSW = this.driveRepository.getSituacionPedidosSW();

      console.log(
        `[SituacionSW] Subiendo ${erpSusy.length} PDFs de ERP SUSY...`,
      );

      // Crear la carpeta del día una sola vez antes del bucle
      const folderDiaERP =
        await this.uploadPdfUseCase.executeFolderDia(parentFolderIdERP);

      // Subir PDFs secuencialmente para evitar rate limiting
      const idsPdfs = [];
      const exitosos = [];
      const fallidos = [];

      for (const pdfFile of erpSusy) {
        try {
          const pdfResult = await this.uploadPdfUseCase.execute({
            file: pdfFile,
            originalname: pdfFile.originalname,
            mimetype: pdfFile.mimetype,
            buffer: pdfFile.buffer,
            parentFolderId: folderDiaERP,
          });

          idsPdfs.push(pdfResult.id);
          exitosos.push({ nombre: pdfFile.originalname, id: pdfResult.id });
          console.log(
            `[SituacionSW] PDF "${pdfFile.originalname}" subido: ${pdfResult.id}`,
          );
        } catch (error) {
          console.error(
            `[SituacionSW] Error subiendo PDF "${pdfFile.originalname}":`,
            error,
          );
          fallidos.push({ nombre: pdfFile.originalname, error: error.message });
        }
      }

      console.log("[SituacionSW] Subiendo Planning Cliente...");

      const planningResult = await this.uploadExcelUseCase.executeFolderDia({
        file: planningCliente[0],
        originalname: planningCliente[0].originalname,
        mimetype: planningCliente[0].mimetype,
        buffer: planningCliente[0].buffer,
        parentFolderId: parentFolderIdSW,
      });

      console.log(
        `[SituacionSW] Planning Cliente subido: ${planningResult.id}`,
      );

      return res.status(201).json({
        message:
          "Archivos de Situación Pedidos Stuart Weitzman subidos correctamente",
        ids_pdfs: idsPdfs,
        id_excel: planningResult.id,
        exitosos,
        fallidos,
      });
    } catch (error) {
      console.error("[SituacionSW] Error al subir archivos:", error);
      const code = error?.code || error?.response?.status || 500;
      return res.status(code).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/checkFolder
   * Verifica la existencia y metadatos de una carpeta o archivo en Drive.
   * Requiere "idFileFolder" en el body.
   */
  async checkFolder(req, res, next) {
    try {
      const { idFileFolder } = req.body;

      if (!idFileFolder) {
        return res
          .status(400)
          .json({ error: "Falta idFileFolder en el cuerpo de la petición" });
      }

      const folderInfo = await this.checkFolderUseCase.execute({
        idFileFolder,
      });

      return res.status(200).json(folderInfo);
    } catch (error) {
      console.error("[GoogleController] Error al verificar carpeta:", error);
      return res.status(500).json({
        error:
          error.response?.data?.error ||
          error.message ||
          "Error interno del servidor.",
      });
    }
  }

  /**
   * POST /api/google/createFolderStructure
   * Crea recursivamente una estructura de carpetas en Drive a partir de un árbol JSON.
   * Requiere "structure" en el body con formato { name: string, children: [...] }.
   */
  async createFolderStructure(req, res, next) {
    try {
      const { structure } = req.body;

      if (!structure || !structure.name) {
        return res.status(400).json({
          error: "Falta estructura válida en el cuerpo de la petición",
        });
      }

      await this.createFolderStructureUseCase.execute({ structure });

      return res.status(201).json({
        status: "ok",
        message: "Estructura creada en Drive correctamente",
      });
    } catch (error) {
      console.error(
        "[GoogleController] Error al crear estructura de carpetas:",
        error,
      );
      return res.status(500).json({ error: "Error interno del servidor." });
    }
  }
}

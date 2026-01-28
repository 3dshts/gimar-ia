// backend/src/infrastructure/web/controllers/google.controller.js
// Controlador de endpoints de Google Drive: subida de imágenes, verificación y creación de carpetas.

import { DriveRepository } from "../../database/google/drive.repository.js";

import { UploadImageAlertUseCase } from "../../../application/use_cases/upload_image_drive.usecase.js";
import { UploadExcelUseCase } from "../../../application/use_cases/upload_excel_drive.usecase.js";
import { UploadPdfUseCase } from "../../../application/use_cases/upload_pdf_drive.usecase.js";
import { ExcelImageExtractorUseCase } from "../../../application/use_cases/extract_images_excel.usecase.js"; // ✅ correcto
import { CheckFolderDriveUseCase } from "../../../application/use_cases/check_folder_drive.usecase.js";
import { CreateFolderStructureDriveUseCase } from "../../../application/use_cases/create_folder_structure_drive.usecase.js";

/**
 * POST /google/upload-img-alert
 * Sube una imagen a Google Drive en la carpeta del día (zona Madrid), manteniendo su formato original.
 * Requiere `multipart/form-data` con el campo `file` (imagen).
 * - Valida que exista archivo y que el MIME sea de imagen.
 * - Crea la carpeta del día si no existe.
 * - Sube el archivo y habilita permisos de lectura pública (anyone).
 * @param {import('express').Request} req Petición HTTP
 * @param {import('express').Response} res Respuesta HTTP
 * @returns {Promise<void>}
 */
export const uploadImgAlert = async (req, res) => {
  try {
    // Validación básica del archivo
    if (!req.file) {
      return res
        .status(400)
        .json({ error: 'Falta archivo (form-data "file")' });
    }

    // Verificar que el archivo es una imagen
    if (!req.file.mimetype.startsWith("image/")) {
      return res.status(400).json({ error: "El archivo debe ser una imagen" });
    }

    const driveRepository = new DriveRepository();
    const uploadImageAlertUseCase = new UploadImageAlertUseCase(
      driveRepository
    );
    const parentFolderId = driveRepository.getImagesAlertsFolderId();

    const result = await uploadImageAlertUseCase.execute({
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
};

export const uploadPrototypeExcel = async (req, res) => {
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

    // 🔹 Definir endpoints según la marca
    let datosEndpoint, imagenesEndpoint;
    if (marca === "STUART WEITZMAN") {
      imagenesEndpoint =
        "https://cb5x6ehri0.execute-api.eu-central-1.amazonaws.com/default/sw";
    } else if (marca === "VERSACE") {
      imagenesEndpoint =
        "https://cb5x6ehri0.execute-api.eu-central-1.amazonaws.com/default/versace";
    }

    // 🔹 Llamadas a las APIs con el Excel en binario
    let datos, id_imagen;

    try {
      //   // Primera llamada: obtener datos
      //   const datosResponse = await fetch(datosEndpoint, {
      //     method: "POST",
      //     headers: {
      //       "Content-Type": "application/octet-stream",
      //     },
      //     body: req.file.buffer,
      //   });

      //   if (!datosResponse.ok) {
      //     throw new Error(
      //       `Error en la API de datos: ${datosResponse.status} ${datosResponse.statusText}`
      //     );
      //   }

      //   datos = await datosResponse.json();

      // Segunda llamada: obtener imágenes
      const imagenesResponse = await fetch(imagenesEndpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/octet-stream",
        },
        body: req.file.buffer,
      });

      if (!imagenesResponse.ok) {
        throw new Error(
          `Error en la API de imágenes: ${imagenesResponse.status} ${imagenesResponse.statusText}`
        );
      }

      id_imagen = await imagenesResponse.json();
    } catch (apiError) {
      console.error(
        "[GoogleController] Error en las llamadas a las APIs:",
        apiError
      );
      return res.status(500).json({
        error: `Error al procesar el Excel con las APIs externas: ${apiError.message}`,
      });
    }

    // 🔹 Resolver carpeta raíz según la marca
    const driveRepository = new DriveRepository();
    let parentFolderId;
    switch (marca) {
      case "STUART WEITZMAN":
        parentFolderId = driveRepository.getSWPrototipeFolderId();
        break;
      case "VERSACE":
        parentFolderId = driveRepository.getVersacePrototipeFolderId();
        break;
    }

    // 🔹 Subir el Excel a Drive
    const uploadExcelUseCase = new UploadExcelUseCase(driveRepository);
    const excelResult = await uploadExcelUseCase.executeFolder({
      file: req.file,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      buffer: req.file.buffer,
      parentFolderId,
    });

    id_imagen.archivos.forEach((archivo) => {
      driveRepository.setPublicReadPermissions(archivo.id);
    });

    //console.log(datos);
    console.log(id_imagen);

    // 🔹 Retornar resultado completo con datos e imágenes
    return res.status(201).json({
      message: "Excel subido e imágenes extraídas correctamente",
      id_archivo: excelResult.id,
      nombre_archivo: excelResult.name,
      id_imagen,
    });
  } catch (error) {
    console.error("[GoogleController] Error al subir prototipo Excel:", error);
    const code = error?.code || error?.response?.status || 500;
    return res.status(code).json({
      error:
        error.response?.data?.error ||
        error.message ||
        "Error interno del servidor.",
    });
  }
};

/**
 * POST /google/upload-pedido-pdf
 * Sube un archivo PDF a Google Drive en la carpeta correspondiente según la marca.
 * Requiere `multipart/form-data` con el campo `file` (PDF) y `marca` en el body.
 * - Valida que exista archivo y que el MIME sea PDF.
 * - Crea la carpeta del día si no existe.
 * - Sube el archivo y habilita permisos de lectura pública.
 * @param {import('express').Request} req Petición HTTP
 * @param {import('express').Response} res Respuesta HTTP
 * @returns {Promise<void>}
 */
export const uploadPedidoPdf = async (req, res) => {
  try {
    // Validación básica del archivo
    if (!req.file) {
      return res
        .status(400)
        .json({ error: 'Falta archivo (form-data "file")' });
    }

    // Verificar que el archivo es un PDF
    const pdfMimeTypes = ["application/pdf"];
    if (!pdfMimeTypes.includes(req.file.mimetype)) {
      return res.status(400).json({
        error: "El archivo debe ser un PDF (.pdf)",
      });
    }

    // Resolver carpeta raíz según la marca
    const driveRepository = new DriveRepository();
    let parentFolderId = driveRepository.getVersacePedidosFolderId();

    // Subir el PDF
    const uploadPdfUseCase = new UploadPdfUseCase(driveRepository);
    const pdfResult = await uploadPdfUseCase.execute({
      file: req.file,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      buffer: req.file.buffer,
      parentFolderId,
    });

    // Retornar resultado
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
};

/**
 * POST /google/upload-pedido-pdf
 * Sube uno o varios archivos PDF a Google Drive en la carpeta correspondiente según la marca.
 * Requiere `multipart/form-data` con el campo `files` (PDF) y `marca` en el body.
 * - Valida que existan archivos y que el MIME sea PDF.
 * - Crea la carpeta del día si no existe.
 * - Sube los archivos y habilita permisos de lectura pública.
 * @param {import('express').Request} req Petición HTTP
 * @param {import('express').Response} res Respuesta HTTP
 * @returns {Promise<void>}
 */
export const uploadIntrastatPDF = async (req, res) => {
  try {
    // Validación básica de archivos (ahora soporta múltiples)
    // IMPORTANTE: req.files puede ser un array o un objeto según la configuración de multer
    const files = req.files || [];

    if (!files || files.length === 0) {
      return res
        .status(400)
        .json({ error: 'Falta archivo(s) (form-data "files")' });
    }

    // Validación del campo marca
    const { marca } = req.body;
    if (!marca) {
      return res
        .status(400)
        .json({ error: 'Falta el campo "marca" en el body' });
    }

    // Validar marcas permitidas
    const marcasValidas = ["COMPRA", "VENTA"];
    if (!marcasValidas.includes(marca)) {
      return res.status(400).json({
        error: `Marca no válida. Debe ser una de: ${marcasValidas.join(", ")}`,
      });
    }

    // Verificar que todos los archivos son PDFs
    const pdfMimeTypes = ["application/pdf"];
    const archivosInvalidos = files.filter(
      (file) => !pdfMimeTypes.includes(file.mimetype)
    );

    if (archivosInvalidos.length > 0) {
      return res.status(400).json({
        error: `Todos los archivos deben ser PDF. Archivos inválidos: ${archivosInvalidos
          .map((f) => f.originalname)
          .join(", ")}`,
      });
    }

    // Resolver carpeta raíz según la marca
    const driveRepository = new DriveRepository();
    let parentFolderId;
    switch (marca) {
      case "COMPRA":
        parentFolderId = driveRepository.getIntrastatComprasFolderId();
        break;
      case "VENTA":
        parentFolderId = driveRepository.getIntrastatVentasFolderId();
        break;
    }

    // Subir los PDFs (procesamiento paralelo para mejor rendimiento)
    const uploadPdfUseCase = new UploadPdfUseCase(driveRepository);

    const idCarpeta = await uploadPdfUseCase.executeFolderDia(parentFolderId)

    const uploadPromises = files.map((file) =>
      uploadPdfUseCase.execute({
        file: file,
        originalname: file.originalname,
        mimetype: file.mimetype,
        buffer: file.buffer,
        parentFolderId: idCarpeta,
      })
    );

    const resultados = await Promise.allSettled(uploadPromises);

    // Separar éxitos y errores
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

    // Retornar resultado con detalle de éxitos y fallos
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
};

export const uploadInventarioPDF = async (req, res) => {
  try {
    // Validación básica de archivos (ahora soporta múltiples)
    // IMPORTANTE: req.files puede ser un array o un objeto según la configuración de multer
    const files = req.files || [];

    if (!files || files.length === 0) {
      return res
        .status(400)
        .json({ error: 'Falta archivo(s) (form-data "files")' });
    }

    // Verificar que todos los archivos son PDFs
    const pdfMimeTypes = ["application/pdf"];
    const archivosInvalidos = files.filter(
      (file) => !pdfMimeTypes.includes(file.mimetype)
    );

    if (archivosInvalidos.length > 0) {
      return res.status(400).json({
        error: `Todos los archivos deben ser PDF. Archivos inválidos: ${archivosInvalidos
          .map((f) => f.originalname)
          .join(", ")}`,
      });
    }

    // Resolver carpeta raíz según la marca
    const driveRepository = new DriveRepository();
    let parentFolderId = driveRepository.getInventarioFolderID();

    // Subir los PDFs (procesamiento paralelo para mejor rendimiento)
    const uploadPdfUseCase = new UploadPdfUseCase(driveRepository);

    const idCarpeta = await uploadPdfUseCase.executeFolderDia(parentFolderId)

    
    const uploadPromises = files.map((file) =>
      uploadPdfUseCase.execute({
        file: file,
        originalname: file.originalname,
        mimetype: file.mimetype,
        buffer: file.buffer,
       parentFolderId: idCarpeta,
      })
    );

    const resultados = await Promise.allSettled(uploadPromises);

    // Separar éxitos y errores
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

    // Retornar resultado con detalle de éxitos y fallos
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
};

/**
 * POST /nominas/uploadExcels
 * Sube múltiples archivos Excel de nóminas, procesa retenciones y nóminas,
 * y combina los resultados.
 * Requiere `multipart/form-data` con:
 * - `archivoResumen`: archivo Excel único de nóminas
 * - `archivosDetalle1`: archivos Excel de resúmenes (múltiples)
 * - `archivosDetalle2`: archivos Excel de retenciones (múltiples)
 * - `anio`: año de las nóminas
 * - `mes`: mes de las nóminas
 * @param {import('express').Request} req Petición HTTP
 * @param {import('express').Response} res Respuesta HTTP
 * @returns {Promise<void>}
 */
export const uploadNominasExcels = async (req, res) => {
  try {
    console.log("[NominasController] ========== INICIO REQUEST ==========");
    console.log("[NominasController] Body:", req.body);
    console.log(
      "[NominasController] Files keys:",
      Object.keys(req.files || {})
    );

    // Validación de archivos
    const archivoResumen = req.files?.archivoResumen?.[0];
    const archivosDetalle1 = req.files?.archivosDetalle1 || [];
    const archivosDetalle2 = req.files?.archivosDetalle2 || [];

    console.log(
      "[NominasController] archivoResumen:",
      archivoResumen ? archivoResumen.originalname : "NO EXISTE"
    );
    console.log(
      "[NominasController] archivosDetalle1 count:",
      archivosDetalle1.length
    );
    console.log(
      "[NominasController] archivosDetalle2 count:",
      archivosDetalle2.length
    );

    if (!archivoResumen) {
      console.log("[NominasController] ERROR: Falta archivoResumen");
      return res.status(400).json({
        error: "Falta el archivo de nóminas (archivoResumen)",
      });
    }

    if (archivosDetalle1.length === 0) {
      console.log("[NominasController] ERROR: Faltan archivosDetalle1");
      return res.status(400).json({
        error: "Faltan archivos de resúmenes (archivosDetalle1)",
      });
    }

    if (archivosDetalle2.length === 0) {
      console.log("[NominasController] ERROR: Faltan archivosDetalle2");
      return res.status(400).json({
        error: "Faltan archivos de retenciones (archivosDetalle2)",
      });
    }

    // Validación de metadatos
    const { anio, mes } = req.body;
    console.log("[NominasController] Año:", anio, "| Mes:", mes);

    if (!anio || !mes) {
      console.log("[NominasController] ERROR: Faltan anio o mes");
      return res.status(400).json({
        error: 'Faltan los campos "anio" y/o "mes" en el body',
      });
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
        }`
      );
    });

    const archivosInvalidos = todosLosArchivos.filter(
      (file) => !excelMimeTypes.includes(file.mimetype.toLowerCase())
    );

    if (archivosInvalidos.length > 0) {
      console.log(
        "[NominasController] ERROR: Archivos con MIME inválido:",
        archivosInvalidos.map((f) => `${f.originalname} (${f.mimetype})`)
      );
      return res.status(400).json({
        error: `Todos los archivos deben ser Excel. Archivos inválidos: ${archivosInvalidos
          .map((f) => f.originalname)
          .join(", ")}`,
      });
    }

    console.log("[NominasController] Validación exitosa. Continuando...");

    const driveRepository = new DriveRepository();
    const uploadExcelUseCase = new UploadExcelUseCase(driveRepository);

    const parentFolderIdAsesorias =
      driveRepository.getNominasAsesoriasFolderID();
    const parentFolderIdNominas = driveRepository.getNominasNominasFolderID();

    console.log("[NominasController] Carpetas padre resueltas:");
    console.log(`[NominasController] Asesorías ID: ${parentFolderIdAsesorias}`);
    console.log(`[NominasController] Nóminas ID: ${parentFolderIdNominas}`);

    // 1. Crear carpetas UNA sola vez (secuencial)

    // 1. Obtener carpeta base (Año / Mes)
    const folderAnoMes = await uploadExcelUseCase.getOrCreateMesAnio({
      parentFolderId: parentFolderIdAsesorias,
      mes,
      anio,
    });

    const folderAnoMesNomina = await uploadExcelUseCase.getOrCreateMesAnio({
      parentFolderId: parentFolderIdNominas,
      mes,
      anio,
    });


    // 2. Crear las subcarpetas usando folderAnoMes como padre
    // Nota: Para la de nóminas, usamos createFolderIfNotExists en lugar de getOrCreateNominasFolder
    // para no repetir la búsqueda del año y mes.
    const [folderRetenciones, folderResumenes, folderNominas] =
      await Promise.all([
        uploadExcelUseCase.createFolderIfNotExists({
          folderName: "RETENCIONES",
          parentFolderId: folderAnoMes,
        }),
        uploadExcelUseCase.createFolderIfNotExists({
          folderName: "RESUMEN",
          parentFolderId: folderAnoMes,
        }),
        // AQUI EL CAMBIO: Usamos la función simple apuntando a la carpeta del mes
        uploadExcelUseCase.createFolderIfNotExists({
          folderName: "NOMINAS",
          parentFolderId: folderAnoMesNomina, 
        }),
      ]);

    // 2. Subir archivos en paralelo (carpetas ya existen)
    const retencionesPromises = archivosDetalle2.map(async (archivo) => {
      try {
        const result = await uploadExcelUseCase.uploadFileToFolder({
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
        const result = await uploadExcelUseCase.uploadFileToFolder({
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

    // 3. Ejecutar todas las subidas en paralelo
    const [retencionesIds, resumenesIds, excelResumen] = await Promise.all([
      Promise.all(retencionesPromises),
      Promise.all(resumenesPromises),
      uploadExcelUseCase.uploadFileToFolder({
        originalname: archivoResumen.originalname,
        mimetype: archivoResumen.mimetype,
        buffer: archivoResumen.buffer,
        folderId: folderNominas,
      }),
    ]);

    // Filtrar nulls (errores)
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
};

// backend/src/infrastructure/web/controllers/google.controller.js
// NUEVOS CONTROLADORES PARA SITUACIÓN PEDIDOS
// Añadir estos dos controladores al archivo google.controller.js existente

/**
 * POST /google/uploadSituacionVersace
 * Sube 4 archivos para Situación de Pedidos Versace:
 * - 1 PDF: Informe Fechas
 * - 3 Excel: DIRMA, Informe Pasado, Informe Nuevo
 *
 * Requiere `multipart/form-data` con los campos:
 * - informeFechas (PDF)
 * - dirma (Excel)
 * - informePasado (Excel)
 * - informeNuevo (Excel)
 *
 * @param {import('express').Request} req Petición HTTP
 * @param {import('express').Response} res Respuesta HTTP
 * @returns {Promise<void>}
 */
export const uploadSituacionVersace = async (req, res) => {
  try {
    // Validar que existan todos los archivos requeridos
    if (!req.files) {
      return res.status(400).json({
        error: "No se recibieron archivos",
      });
    }

    const { informeFechas, dirma, informePasado, informeNuevo } = req.files;

    // Validar presencia de todos los archivos
    if (!informeFechas || !informeFechas[0]) {
      return res.status(400).json({
        error: 'Falta el archivo "informeFechas" (PDF)',
      });
    }
    if (!dirma || !dirma[0]) {
      return res.status(400).json({
        error: 'Falta el archivo "dirma" (Excel)',
      });
    }
    if (!informePasado || !informePasado[0]) {
      return res.status(400).json({
        error: 'Falta el archivo "informePasado" (Excel)',
      });
    }
    if (!informeNuevo || !informeNuevo[0]) {
      return res.status(400).json({
        error: 'Falta el archivo "informeNuevo" (Excel)',
      });
    }

    // Validar tipos de archivo
    const pdfMimeTypes = ["application/pdf", "application/octet-stream"];
    const excelMimeTypes = [
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "application/vnd.ms-excel",
      "application/vnd.ms-excel.sheet.macroEnabled.12",
      "application/octet-stream",
    ];

    if (!pdfMimeTypes.includes(informeFechas[0].mimetype)) {
      return res.status(400).json({
        error: 'El archivo "informeFechas" debe ser un PDF',
      });
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

    // Inicializar repositorios y casos de uso
    const driveRepository = new DriveRepository();
    const uploadPdfUseCase = new UploadPdfUseCase(driveRepository);
    const uploadExcelUseCase = new UploadExcelUseCase(driveRepository);

    // Obtener carpetas según el tipo de archivo
    const parentFolderIdPDF = driveRepository.getSituacionPedidosPDF();
    const parentFolderIdDirma = driveRepository.getSituacionPedidosDirma();
    const parentFolderIdVersace = driveRepository.getSituacionPedidosVersace();

    console.log("[SituacionVersace] Subiendo archivos...");

    // Subir Informe Fechas (PDF)
    const informeFechasResult = await uploadPdfUseCase.executeFolderDia({
      file: informeFechas[0],
      originalname: informeFechas[0].originalname,
      mimetype: informeFechas[0].mimetype,
      buffer: informeFechas[0].buffer,
      parentFolderId: parentFolderIdPDF,
    });

    console.log(
      `[SituacionVersace] Informe Fechas subido: ${informeFechasResult.id}`
    );

    // Subir DIRMA (Excel)
    const dirmaResult = await uploadExcelUseCase.executeFolderDia({
      file: dirma[0],
      originalname: dirma[0].originalname,
      mimetype: dirma[0].mimetype,
      buffer: dirma[0].buffer,
      parentFolderId: parentFolderIdDirma,
    });

    console.log(`[SituacionVersace] DIRMA subido: ${dirmaResult.id}`);

    // Subir Informe Pasado (Excel)
    const informePasadoResult = await uploadExcelUseCase.executeFolderDia({
      file: informePasado[0],
      originalname: informePasado[0].originalname,
      mimetype: informePasado[0].mimetype,
      buffer: informePasado[0].buffer,
      parentFolderId: parentFolderIdVersace,
    });

    console.log(
      `[SituacionVersace] Informe Pasado subido: ${informePasadoResult.id}`
    );

    // Subir Informe Nuevo (Excel)
    const informeNuevoResult = await uploadExcelUseCase.executeFolderDia({
      file: informeNuevo[0],
      originalname: informeNuevo[0].originalname,
      mimetype: informeNuevo[0].mimetype,
      buffer: informeNuevo[0].buffer,
      parentFolderId: parentFolderIdVersace,
    });

    console.log(
      `[SituacionVersace] Informe Nuevo subido: ${informeNuevoResult.id}`
    );

    // Retornar los IDs de todos los archivos subidos
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
};

/**
 * POST /google/uploadSituacionSW
 * Sube archivos para Situación de Pedidos Stuart Weitzman:
 * - Múltiples PDFs: ERP SUSY
 * - 1 Excel: Planning Cliente
 *
 * Requiere `multipart/form-data` con los campos:
 * - erpSusy (PDFs múltiples)
 * - planningCliente (Excel único)
 *
 * @param {import('express').Request} req Petición HTTP
 * @param {import('express').Response} res Respuesta HTTP
 * @returns {Promise<void>}
 */
export const uploadSituacionSW = async (req, res) => {
  try {
    // Validar que existan archivos
    if (!req.files) {
      console.log("❌ ERROR: No req.files");
      return res.status(400).json({
        error: "No se recibieron archivos",
      });
    }
    // Validar que existan archivos
    if (!req.files) {
      return res.status(400).json({
        error: "No se recibieron archivos",
      });
    }

    const { erpSusy, planningCliente } = req.files;

    // Validar presencia de archivos
    if (!erpSusy || erpSusy.length === 0) {
      return res.status(400).json({
        error: 'Falta al menos un archivo "erpSusy" (PDF)',
      });
    }
    if (!planningCliente || !planningCliente[0]) {
      return res.status(400).json({
        error: 'Falta el archivo "planningCliente" (Excel)',
      });
    }

    // Validar tipos de archivo
    const pdfMimeTypes = ["application/pdf", "application/octet-stream"];
    const excelMimeTypes = [
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "application/vnd.ms-excel",
      "application/vnd.ms-excel.sheet.macroEnabled.12",
      "application/octet-stream",
    ];

    // Validar que todos los PDFs sean PDFs
    for (const pdf of erpSusy) {
      if (!pdfMimeTypes.includes(pdf.mimetype)) {
        return res.status(400).json({
          error: `El archivo "${pdf.originalname}" debe ser un PDF`,
        });
      }
    }

    // Validar que el Excel sea Excel
    if (!excelMimeTypes.includes(planningCliente[0].mimetype)) {
      return res.status(400).json({
        error:
          'El archivo "planningCliente" debe ser un Excel (.xlsx, .xls, .xlsm)',
      });
    }

    // Inicializar repositorios y casos de uso
    const driveRepository = new DriveRepository();
    const uploadPdfUseCase = new UploadPdfUseCase(driveRepository);
    const uploadExcelUseCase = new UploadExcelUseCase(driveRepository);

    // Obtener carpetas según el tipo de archivo
    const parentFolderIdERP = driveRepository.getSituacionPedidosERP();
    const parentFolderIdSW = driveRepository.getSituacionPedidosSW();

    console.log(`[SituacionSW] Subiendo ${erpSusy.length} PDFs de ERP SUSY...`);

    // Subir todos los PDFs de ERP SUSY
    const idsPdfs = [];
    const exitosos = [];
    const fallidos = [];

    for (const pdfFile of erpSusy) {
      try {
        const pdfResult = await uploadPdfUseCase.executeFolderDia({
          file: pdfFile,
          originalname: pdfFile.originalname,
          mimetype: pdfFile.mimetype,
          buffer: pdfFile.buffer,
          parentFolderId: parentFolderIdERP,
        });

        idsPdfs.push(pdfResult.id);
        exitosos.push({
          nombre: pdfFile.originalname,
          id: pdfResult.id,
        });

        console.log(
          `[SituacionSW] PDF "${pdfFile.originalname}" subido: ${pdfResult.id}`
        );
      } catch (error) {
        console.error(
          `[SituacionSW] Error subiendo PDF "${pdfFile.originalname}":`,
          error
        );
        fallidos.push({
          nombre: pdfFile.originalname,
          error: error.message,
        });
      }
    }

    console.log("[SituacionSW] Subiendo Planning Cliente...");

    // Subir Planning Cliente (Excel)
    const planningResult = await uploadExcelUseCase.executeFolderDia({
      file: planningCliente[0],
      originalname: planningCliente[0].originalname,
      mimetype: planningCliente[0].mimetype,
      buffer: planningCliente[0].buffer,
      parentFolderId: parentFolderIdSW,
    });

    console.log(`[SituacionSW] Planning Cliente subido: ${planningResult.id}`);

    // Retornar los IDs de todos los archivos subidos
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
};

/**
 * POST /google/check-folder
 * Verifica la existencia y metadatos de una carpeta/archivo en Drive por su ID.
 * Espera `idFileFolder` en `req.body`.
 * @param {import('express').Request} req Petición HTTP
 * @param {import('express').Response} res Respuesta HTTP
 * @returns {Promise<void>}
 */
export const checkFolder = async (req, res) => {
  try {
    const { idFileFolder } = req.body;

    if (!idFileFolder) {
      return res
        .status(400)
        .json({ error: "Falta idFileFolder en el cuerpo de la petición" });
    }

    const driveRepository = new DriveRepository();
    const checkFolderUseCase = new CheckFolderDriveUseCase(driveRepository);

    const folderInfo = await checkFolderUseCase.execute({ idFileFolder });

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
};

/**
 * POST /google/create-folder-structure
 * Endpoint que recibe `structure` (árbol de carpetas) y lo crea recursivamente en Drive.
 * Ejemplo de body:
 * {
 *   "structure": { "name":"Carpeta X", "children":[ {"name":"Sub1","children":[]}, ... ] }
 * }
 * @param {import('express').Request} req Petición HTTP
 * @param {import('express').Response} res Respuesta HTTP
 * @returns {Promise<void>}
 */
export const createFolderStructure = async (req, res) => {
  try {
    const { structure } = req.body;

    if (!structure || !structure.name) {
      return res
        .status(400)
        .json({ error: "Falta estructura válida en el cuerpo de la petición" });
    }

    const driveRepository = new DriveRepository();
    const createFolderStructureUseCase = new CreateFolderStructureDriveUseCase(
      driveRepository
    );

    await createFolderStructureUseCase.execute({ structure });

    return res.status(201).json({
      status: "ok",
      message: "Estructura creada en Drive correctamente",
    });
  } catch (error) {
    console.error(
      "[GoogleController] Error al crear estructura de carpetas:",
      error
    );
    return res.status(500).json({ error: "Error interno del servidor." });
  }
};

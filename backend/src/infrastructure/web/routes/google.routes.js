// backend/src/infrastructure/web/routes/google.routes.js
import { Router } from "express";
import {
  uploadImgAlert,
  checkFolder,
  createFolderStructure,
  uploadPrototypeExcel,
  uploadPedidoPdf,
  uploadIntrastatPDF,
  uploadNominasExcels,
  uploadInventarioPDF,
  uploadSituacionSW,
  uploadSituacionVersace
} from "../controllers/google.controller.js";
import multer from "multer";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB por archivo
    files: 50, // máximo 20 archivos
  },
});
const router = Router();

/**
 * POST /checkFolder
 * Verifica la existencia de una carpeta en Drive.
 */
router.post("/checkFolder", checkFolder);

/**
 * POST /uploadImgAlert
 * Sube una imagen a Google Drive (carpeta de alertas).
 * - Convierte el archivo a PNG.
 * - Crea la carpeta del día si no existe.
 * - Requiere form-data con campo `file`.
 */
router.post(
  "/uploadImgAlert",
  (req, res, next) => {
    // Middleware de debug para inspeccionar cabeceras
    console.log("---- /uploadImgAlert DEBUG ----");
    console.log("Content-Type:", req.headers["content-type"]);
    next();
  },
  upload.single("file"),
  (req, res, next) => {
    // Middleware de debug para inspeccionar archivo y body
    console.log(
      "MULTER file:",
      !!req.file,
      req.file?.originalname,
      req.file?.mimetype,
      req.file?.size
    );
    console.log("MULTER body keys:", Object.keys(req.body || {}));
    next();
  },
  uploadImgAlert
);

// ------------------------------
// POST /uploadPrototypeExcel
// ------------------------------
// 🔹 Recibe un Excel y la marca en el body
// form-data: { file: <excel>, marca: "STUART WEITZMAN" }
router.post(
  "/uploadPrototypeExcel",
  upload.single("file"),
  uploadPrototypeExcel
);

router.post("/uploadPedidoPDF", upload.single("file"), uploadPedidoPdf);

router.post(
  "/uploadIntrastatPDF",
  upload.array("files", 20),
  uploadIntrastatPDF
);

router.post(
  "/uploadInventarioPDF",
  upload.array("files", 50),
  uploadInventarioPDF
);

router.post(
  '/uploadNominasExcels',
  upload.fields([
    { name: 'archivoResumen', maxCount: 1 },
    { name: 'archivosDetalle1', maxCount: 20 },
    { name: 'archivosDetalle2', maxCount: 20 }
  ]),
  uploadNominasExcels
);


// ------------------------------
// POST /uploadSituacionVersace
// ------------------------------
// 🔹 Recibe 4 archivos: 1 PDF (informeFechas) y 3 Excel (dirma, informePasado, informeNuevo)
// form-data: { informeFechas: <pdf>, dirma: <excel>, informePasado: <excel>, informeNuevo: <excel> }
router.post(
  '/uploadSituacionVersace',
  upload.fields([
    { name: 'informeFechas', maxCount: 1 },
    { name: 'dirma', maxCount: 1 },
    { name: 'informePasado', maxCount: 1 },
    { name: 'informeNuevo', maxCount: 1 }
  ]),
  uploadSituacionVersace
);

// ------------------------------
// POST /uploadSituacionSW
// ------------------------------
// 🔹 Recibe múltiples PDFs (erpSusy) y 1 Excel (planningCliente)
// form-data: { erpSusy: [<pdf1>, <pdf2>, ...], planningCliente: <excel> }
router.post(
  '/uploadSituacionSW',
  upload.fields([
    { name: 'erpSusy', maxCount: 20 },
    { name: 'planningCliente', maxCount: 1 }
  ]),
  uploadSituacionSW
);

/**
 * POST /createFolderStructure
 * Crea recursivamente una estructura de carpetas en Drive
 * a partir de un objeto `structure` enviado en el body.
 */
router.post("/createFolderStructure", createFolderStructure);


export default router;

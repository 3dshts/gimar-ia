// src/infrastructure/web/routes/google.routes.js
// -----------------------------------------------------------------------------
// Definición de rutas de Google Drive.
// Patrón factory: recibe el controlador ya instanciado desde el contenedor.
// La configuración de multer se importa desde el middleware centralizado.
// -----------------------------------------------------------------------------

import { Router } from 'express';
import upload from '../middlewares/multer.middleware.js';

/**
 * Crea y devuelve el router de Google Drive.
 * @param {Object} deps - Dependencias inyectadas.
 * @param {Object} deps.googleController - Instancia del controlador de Google.
 * @returns {Router} Router de Express configurado.
 */
export function createGoogleRoutes({ googleController }) {
  const router = Router();

  // POST /checkFolder → Verificar existencia de carpeta/archivo en Drive
  router.post('/checkFolder', (req, res, next) => googleController.checkFolder(req, res, next));

  // POST /uploadImgAlert → Subir imagen de alerta (1 archivo)
  router.post('/uploadImgAlert', upload.single('file'), (req, res, next) => googleController.uploadImgAlert(req, res, next));

  // POST /uploadPrototypeExcel → Subir Excel de prototipo con extracción de imágenes (1 archivo + marca)
  router.post('/uploadPrototypeExcel', upload.single('file'), (req, res, next) => googleController.uploadPrototypeExcel(req, res, next));

  // POST /uploadPedidoPDF → Subir PDF de pedido Versace (1 archivo)
  router.post('/uploadPedidoPDF', upload.single('file'), (req, res, next) => googleController.uploadPedidoPdf(req, res, next));

  // POST /uploadIntrastatPDF → Subir múltiples PDFs de Intrastat (hasta 20 archivos + marca)
  router.post('/uploadIntrastatPDF', upload.array('files', 20), (req, res, next) => googleController.uploadIntrastatPDF(req, res, next));

  // POST /uploadInventarioPDF → Subir múltiples PDFs de inventario (hasta 50 archivos)
  router.post('/uploadInventarioPDF', upload.array('files', 50), (req, res, next) => googleController.uploadInventarioPDF(req, res, next));

  // POST /uploadNominasExcels → Subir Excels de nóminas (resumen + detalles + retenciones)
  router.post(
    '/uploadNominasExcels',
    upload.fields([
      { name: 'archivoResumen', maxCount: 1 },
      { name: 'archivosDetalle1', maxCount: 20 },
      { name: 'archivosDetalle2', maxCount: 20 },
    ]),
    (req, res, next) => googleController.uploadNominasExcels(req, res, next),
  );

  // POST /uploadSituacionVersace → Subir 4 archivos de situación pedidos Versace
  router.post(
    '/uploadSituacionVersace',
    upload.fields([
      { name: 'informeFechas', maxCount: 1 },
      { name: 'dirma', maxCount: 1 },
      { name: 'informePasado', maxCount: 1 },
      { name: 'informeNuevo', maxCount: 1 },
    ]),
    (req, res, next) => googleController.uploadSituacionVersace(req, res, next),
  );

  // POST /uploadSituacionSW → Subir PDFs de ERP + Excel de planning SW
  router.post(
    '/uploadSituacionSW',
    upload.fields([
      { name: 'erpSusy', maxCount: 20 },
      { name: 'planningCliente', maxCount: 1 },
    ]),
    (req, res, next) => googleController.uploadSituacionSW(req, res, next),
  );

  // POST /createFolderStructure → Crear estructura recursiva de carpetas
  router.post('/createFolderStructure', (req, res, next) => googleController.createFolderStructure(req, res, next));

  return router;
}
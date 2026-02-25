// src/infrastructure/web/middlewares/multer.middleware.js
// -----------------------------------------------------------------------------
// Configuración centralizada de Multer para subida de archivos.
// Almacena en memoria (memoryStorage) para procesar los buffers directamente
// sin escribir archivos temporales en disco, ideal para Lambda.
// Límites: 10MB por archivo, máximo 50 archivos por petición.
// -----------------------------------------------------------------------------

import multer from 'multer';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB por archivo
    files: 100,                   // Máximo 100 archivos por petición
  },
});

export default upload;
// backend/src/application/use_cases/upload_image_drive.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: subir imagen de alerta a Google Drive.
// Orquesta la creación de carpeta del día y subida del archivo.
// -----------------------------------------------------------------------------

export class UploadImageAlertUseCase {
  /**
   * @param {Object} driveRepository Repositorio de Drive con los contratos necesarios
   */
  constructor(driveRepository) {
    this.driveRepository = driveRepository;
  }

  /**
   * Ejecuta la subida de imagen de alerta.
   * - Obtiene o crea la carpeta del día actual.
   * - Sube el archivo manteniendo su formato original.
   * - Configura permisos públicos de lectura.
   * @param {Object} params
   * @param {Object} params.file Archivo subido (req.file)
   * @param {string} params.originalname Nombre original del archivo
   * @param {string} params.mimetype Tipo MIME del archivo
   * @param {Buffer} params.buffer Buffer del archivo
   * @param {string} params.parentFolderId Carpeta padre (ya resuelta por el controlador)
   * @returns {Promise<Object>} Metadatos del archivo subido
   */
  async execute({ file, originalname, mimetype, buffer, parentFolderId }) {
    // 1. Obtener ID ID/nombre de carpeta del día
    const folderName = this.driveRepository.generateDayFolderName();

    // 2. Buscar carpeta del día actual
    let targetFolderId = await this.driveRepository.findFolderByName(folderName, parentFolderId);

    // 3. Si no existe, crearla
    if (!targetFolderId) {
      targetFolderId = await this.driveRepository.createFolder(folderName, parentFolderId);
    }

    // 4. Subir el archivo con su formato original
    const uploadedFile = await this.driveRepository.uploadFile({
      name: originalname,
      parentId: targetFolderId,
      mimeType: mimetype,
      buffer: buffer
    });

    // 5. Configurar permisos públicos
    await this.driveRepository.setPublicReadPermissions(uploadedFile.id);

    return uploadedFile;
  }
}
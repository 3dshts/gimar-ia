// backend/src/application/use_cases/upload_pdf_drive.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: subir archivo PDF a Google Drive en una carpeta concreta.
// Recibe directamente el `parentFolderId` desde el controlador.
// -----------------------------------------------------------------------------

export class UploadPdfUseCase {
  /**
   * @param {Object} driveRepository Repositorio de Drive con los contratos necesarios
   */
  constructor(driveRepository) {
    this.driveRepository = driveRepository;
  }

  /**
   * Ejecuta la subida de archivo PDF.
   * - Obtiene o crea la carpeta del día actual en la carpeta padre recibida.
   * - Sube el archivo PDF manteniendo su formato original.
   * - Configura permisos públicos de lectura.
   * @param {Object} params
   * @param {Object} params.file Archivo subido (req.file)
   * @param {string} params.originalname Nombre original del archivo
   * @param {string} params.mimetype Tipo MIME del archivo
   * @param {Buffer} params.buffer Buffer del archivo
   * @param {string} params.parentFolderId Carpeta padre (ya resuelta por el controlador)
   * @returns {Promise<Object>} Metadatos del archivo subido con targetFolderId
   */
  async executeFolder({ file, originalname, mimetype, buffer, parentFolderId }) {
    // 1. Generar nombre de carpeta del día (puedes usar la misma función que para Excel)
    const folderName = this.driveRepository.generateFolderName(originalname);

    // 2. Buscar carpeta del día actual
    let targetFolderId = await this.driveRepository.findFolderByName(folderName, parentFolderId);

    // 3. Si no existe, crearla
    if (!targetFolderId) {
      targetFolderId = await this.driveRepository.createFolder(folderName, parentFolderId);
    }

    // 4. Subir el archivo PDF con su formato original
    const uploadedFile = await this.driveRepository.uploadFile({
      name: originalname,
      parentId: targetFolderId,
      mimeType: mimetype,
      buffer: buffer
    });

    // 5. Configurar permisos públicos
    await this.driveRepository.setPublicReadPermissions(uploadedFile.id);

    // 6. Retornar con targetFolderId y folderName para consistencia
    return {
      ...uploadedFile,
      targetFolderId,
      folderName
    };
  }

  

  async executeFolderDia(parentFolderId ) {
    // 1. Generar nombre de carpeta del día (puedes usar la misma función que para Excel)
    const folderName = this.driveRepository.generateDayFolderName();

    // 2. Buscar carpeta del día actual
    let targetFolderId = await this.driveRepository.findFolderByName(folderName, parentFolderId);

    // 3. Si no existe, crearla
    if (!targetFolderId) {
      targetFolderId = await this.driveRepository.createFolder(folderName, parentFolderId);
    }

    return targetFolderId;// 5. Configurar permisos públicos
  }

  async execute({ file, originalname, mimetype, buffer, parentFolderId }) {
    // 1. Subir el archivo PDF con su formato original
    const uploadedFile = await this.driveRepository.uploadFile({
      name: originalname,
      parentId: parentFolderId,
      mimeType: mimetype,
      buffer: buffer
    });

    // 2. Configurar permisos públicos
    await this.driveRepository.setPublicReadPermissions(uploadedFile.id);

    // 3. Retornar con targetFolderId y folderName para consistencia
    return {
      ...uploadedFile,
    };
  }
}

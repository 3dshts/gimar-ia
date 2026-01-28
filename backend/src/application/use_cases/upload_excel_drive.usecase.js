// backend/src/application/use_cases/upload_excel_drive.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: subir archivo Excel de prototipo a Google Drive en una carpeta concreta.
// Ahora recibe directamente el `parentFolderId` desde el controlador.
// -----------------------------------------------------------------------------

export class UploadExcelUseCase {
  /**
   * @param {Object} driveRepository Repositorio de Drive con los contratos necesarios
   */
  constructor(driveRepository) {
    this.driveRepository = driveRepository;
  }

  /**
   * Ejecuta la subida de archivo Excel de prototipo.
   * - Obtiene o crea la carpeta del día actual en la carpeta padre recibida.
   * - Sube el archivo Excel manteniendo su formato original.
   * - Configura permisos públicos de lectura.
   * @param {Object} params
   * @param {Object} params.file Archivo subido (req.file)
   * @param {string} params.originalname Nombre original del archivo
   * @param {string} params.mimetype Tipo MIME del archivo
   * @param {Buffer} params.buffer Buffer del archivo
   * @param {string} params.parentFolderId Carpeta padre (ya resuelta por el controlador)
   * @returns {Promise<Object>} Metadatos del archivo subido
   */
  async execute({ file, originalname, mimetype, buffer, targetFolderId }) {
    // 1. Subir el archivo Excel con su formato original
    const uploadedFile = await this.driveRepository.uploadFile({
      name: originalname,
      parentId: targetFolderId,
      mimeType: mimetype,
      buffer: buffer,
    });

    // 2. Configurar permisos públicos
    await this.driveRepository.setPublicReadPermissions(uploadedFile.id);

    return uploadedFile;
  }

  /**
   * Ejecuta la subida de archivo Excel de prototipo.
   * - Obtiene o crea la carpeta del día actual en la carpeta padre recibida.
   * - Sube el archivo Excel manteniendo su formato original.
   * - Configura permisos públicos de lectura.
   * @param {Object} params
   * @param {Object} params.file Archivo subido (req.file)
   * @param {string} params.originalname Nombre original del archivo
   * @param {string} params.mimetype Tipo MIME del archivo
   * @param {Buffer} params.buffer Buffer del archivo
   * @param {string} params.parentFolderId Carpeta padre (ya resuelta por el controlador)
   * @returns {Promise<Object>} Metadatos del archivo subido
   */
  async executeFolder({
    file,
    originalname,
    mimetype,
    buffer,
    parentFolderId,
  }) {
    // 1. Generar nombre de carpeta del día
    const folderName = this.driveRepository.generateFolderName(originalname);

    // 2. Buscar carpeta del día actual
    let targetFolderId = await this.driveRepository.findFolderByName(
      folderName,
      parentFolderId
    );

    // 3. Si no existe, crearla
    if (!targetFolderId) {
      targetFolderId = await this.driveRepository.createFolder(
        folderName,
        parentFolderId
      );
    }

    // 4. Subir el archivo Excel con su formato original
    const uploadedFile = await this.driveRepository.uploadFile({
      name: originalname,
      parentId: targetFolderId,
      mimeType: mimetype,
      buffer: buffer,
    });

    // 5. Configurar permisos públicos
    await this.driveRepository.setPublicReadPermissions(uploadedFile.id);

    return uploadedFile;
  }

  async executeFolderDia({
    file,
    originalname,
    mimetype,
    buffer,
    parentFolderId,
  }) {
    // 1. Generar nombre de carpeta del día
    const folderName = this.driveRepository.generateDayFolderName();

    // 2. Buscar carpeta del día actual
    let targetFolderId = await this.driveRepository.findFolderByName(
      folderName,
      parentFolderId
    );

    // 3. Si no existe, crearla
    if (!targetFolderId) {
      targetFolderId = await this.driveRepository.createFolder(
        folderName,
        parentFolderId
      );
    }
    // 4. Subir el archivo Excel con su formato original
    const uploadedFile = await this.driveRepository.uploadFile({
      name: originalname,
      parentId: targetFolderId,
      mimeType: mimetype,
      buffer: buffer,
    });

    // 5. Configurar permisos públicos
    await this.driveRepository.setPublicReadPermissions(uploadedFile.id);

    return uploadedFile;
  }

  /**
   * Obtiene o crea la estructura de carpetas para nóminas.
   * @returns {Promise<string>} ID de la carpeta destino
   */
  async getOrCreateNominasFolder({ parentFolderId, mes, anio, nombre }) {
    // Carpeta año
    const folderNameAno = this.driveRepository.generateFolderName(anio);
    let targetFolderIdAnio = await this.driveRepository.findFolderByName(
      folderNameAno,
      parentFolderId
    );
    if (!targetFolderIdAnio) {
      targetFolderIdAnio = await this.driveRepository.createFolder(
        folderNameAno,
        parentFolderId
      );
    }

    // Carpeta mes
    const folderNameMes = this.driveRepository.generateFolderName(mes);
    let targetFolderIdMes = await this.driveRepository.findFolderByName(
      folderNameMes,
      targetFolderIdAnio
    );
    if (!targetFolderIdMes) {
      targetFolderIdMes = await this.driveRepository.createFolder(
        folderNameMes,
        targetFolderIdAnio
      );
    }

    // Carpeta nombre (si existe)
    if (nombre) {
      const folderNameCarpeta = this.driveRepository.generateFolderName(nombre);
      let targetFolderIdCarpeta = await this.driveRepository.findFolderByName(
        folderNameCarpeta,
        targetFolderIdMes
      );
      if (!targetFolderIdCarpeta) {
        targetFolderIdCarpeta = await this.driveRepository.createFolder(
          folderNameCarpeta,
          targetFolderIdMes
        );
      }
      return targetFolderIdCarpeta;
    }

    return targetFolderIdMes;
  }

  /**
   * Obtiene o crea la estructura de carpetas para nóminas.
   * @returns {Promise<string>} ID de la carpeta destino
   */
  async getOrCreateMesAnio({ parentFolderId, mes, anio }) {
    // Carpeta año
    const folderNameAno = this.driveRepository.generateFolderName(anio);
    let targetFolderIdAnio = await this.driveRepository.findFolderByName(
      folderNameAno,
      parentFolderId
    );
    if (!targetFolderIdAnio) {
      targetFolderIdAnio = await this.driveRepository.createFolder(
        folderNameAno,
        parentFolderId
      );
    }

    // Carpeta mes
    const folderNameMes = this.driveRepository.generateFolderName(mes);
    let targetFolderIdMes = await this.driveRepository.findFolderByName(
      folderNameMes,
      targetFolderIdAnio
    );
    if (!targetFolderIdMes) {
      targetFolderIdMes = await this.driveRepository.createFolder(
        folderNameMes,
        targetFolderIdAnio
      );
    }
    return targetFolderIdMes;
  }

  async createFolderIfNotExists({ folderName, parentFolderId }) {
    const folderName_ = this.driveRepository.generateFolderName(folderName);

    // Buscamos si existe
    let existingId = await this.driveRepository.findFolderByName(
      folderName_,
      parentFolderId
    );

    // Si existe, la devolvemos directamente
    if (existingId) {
      return existingId;
    }

    // Si NO existe, la creamos
    const newFolder = await this.driveRepository.createFolder(
      folderName_,
      parentFolderId
    );

    // createFolder suele devolver un objeto o el ID, asegúrate de devolver el ID
    return newFolder.id || newFolder;
  }

  /**
   * Sube un archivo a una carpeta ya existente.
   */
  async uploadFileToFolder({ originalname, mimetype, buffer, folderId }) {
    const uploadedFile = await this.driveRepository.uploadFile({
      name: originalname,
      parentId: folderId,
      mimeType: mimetype,
      buffer: buffer,
    });
    await this.driveRepository.setPublicReadPermissions(uploadedFile.id);
    return uploadedFile;
  }
}

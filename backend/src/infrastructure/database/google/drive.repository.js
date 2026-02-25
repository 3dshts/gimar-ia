// src/infrastructure/database/google/drive.repository.js
// -----------------------------------------------------------------------------
// Repositorio de Google Drive.
// Encapsula toda la comunicación con la API de Drive: búsqueda, creación de
// carpetas, subida de archivos y gestión de permisos.
// Recibe sus dependencias por inyección desde el contenedor.
// -----------------------------------------------------------------------------

export class DriveRepository {
  /**
   * @param {Object} deps - Dependencias inyectadas desde el contenedor.
   * @param {Object} deps.drive - Cliente autenticado de Google Drive API.
   * @param {Object} deps.driveIds - Mapa de IDs de carpetas (drive-ids.json).
   * @param {Function} deps.bufferToStream - Convierte un Buffer en ReadableStream.
   */
  constructor({ drive, driveIds, bufferToStream }) {
    this.drive = drive;
    this.driveIds = driveIds;
    this.bufferToStream = bufferToStream;
  }

  // ==========================================================================
  // OPERACIONES CON CARPETAS
  // ==========================================================================

  /**
   * Busca una carpeta por nombre dentro de un directorio padre.
   * @param {string} folderName - Nombre exacto de la carpeta.
   * @param {string} parentId - ID de la carpeta padre.
   * @returns {Promise<string|null>} ID de la carpeta o null si no existe.
   */
  async findFolderByName(folderName, parentId) {
    const search = await this.drive.files.list({
      q: `name = '${folderName}' and mimeType = 'application/vnd.google-apps.folder' and '${parentId}' in parents and trashed = false`,
      fields: 'files(id,name)',
      pageSize: 1,
      includeItemsFromAllDrives: true,
      supportsAllDrives: true,
    });

    return search.data.files?.[0]?.id || null;
  }

  /**
   * Crea una carpeta dentro de otra carpeta padre.
   * @param {string} name - Nombre de la nueva carpeta.
   * @param {string} parentId - ID de la carpeta padre.
   * @returns {Promise<string>} ID de la carpeta creada.
   */
  async createFolder(name, parentId) {
    const file = await this.drive.files.create({
      resource: {
        name,
        mimeType: 'application/vnd.google-apps.folder',
        parents: [parentId],
      },
      fields: 'id, name',
      supportsAllDrives: true,
    });

    return file.data.id;
  }

  /**
   * Crea recursivamente un árbol de carpetas a partir de una estructura JSON.
   * @param {Object} folder - Nodo con { name: string, children?: Array }.
   * @param {string} parentId - ID de la carpeta padre raíz.
   * @returns {Promise<string>} ID de la carpeta creada en el nivel actual.
   */
  async createRecursiveFolders(folder, parentId) {
    const newFolderId = await this.createFolder(folder.name, parentId);

    if (folder.children && folder.children.length > 0) {
      for (const child of folder.children) {
        await this.createRecursiveFolders(child, newFolderId);
      }
    }

    return newFolderId;
  }

  // ==========================================================================
  // OPERACIONES CON ARCHIVOS
  // ==========================================================================

  /**
   * Sube un archivo a Drive, le asigna permisos públicos de lectura y
   * devuelve los metadatos actualizados (con links de descarga y vista).
   * @param {Object} params
   * @param {string} params.name - Nombre del archivo.
   * @param {string} params.parentId - ID de la carpeta destino.
   * @param {string} params.mimeType - Tipo MIME del archivo.
   * @param {Buffer} params.buffer - Contenido del archivo.
   * @returns {Promise<Object>} Metadatos: { id, name, mimeType, webContentLink, webViewLink }.
   */
  async uploadFile({ name, parentId, mimeType, buffer }) {
    const response = await this.drive.files.create({
      resource: { name, parents: [parentId] },
      media: { mimeType, body: this.bufferToStream(buffer) },
      fields: 'id, name, mimeType, webContentLink, webViewLink',
      supportsAllDrives: true,
    });

    const fileData = response.data;

    // Hacer el archivo público para lectura
    await this.drive.permissions.create({
      fileId: fileData.id,
      resource: { role: 'reader', type: 'anyone' },
      supportsAllDrives: true,
    });

    // Re-obtener metadatos con los links ya disponibles
    const updatedFile = await this.drive.files.get({
      fileId: fileData.id,
      fields: 'id, name, mimeType, webContentLink, webViewLink',
      supportsAllDrives: true,
    });

    return updatedFile.data;
  }

  /**
   * Asigna permisos de lectura pública (anyone) a un archivo existente.
   * @param {string} fileId - ID del archivo en Drive.
   * @returns {Promise<void>}
   */
  async setPublicReadPermissions(fileId) {
    await this.drive.permissions.create({
      fileId,
      resource: { role: 'reader', type: 'anyone' },
      supportsAllDrives: true,
    });
  }

  /**
   * Obtiene los metadatos de un archivo o carpeta por su ID.
   * @param {string} fileId - ID del recurso en Drive.
   * @returns {Promise<Object>} Metadatos: { id, name, mimeType, parents, driveId, shortcutDetails }.
   */
  async getFileMetadata(fileId) {
    const response = await this.drive.files.get({
      fileId,
      fields: 'id, name, mimeType, parents, driveId, shortcutDetails',
    });
    return response.data;
  }

  // ==========================================================================
  // GENERADORES DE NOMBRES DE CARPETA
  // ==========================================================================

  /**
   * Genera el nombre de carpeta del día actual en formato DD-MM-YYYY (zona Madrid).
   * Ejemplo: "03-02-2026"
   * @returns {string}
   */
  generateDayFolderName() {
    return new Intl.DateTimeFormat('es-ES', {
      timeZone: 'Europe/Madrid',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    })
      .format(new Date())
      .replace(/\//g, '-');
  }

  /**
   * Genera un nombre de carpeta limpio a partir de un texto (nombre de archivo, año, mes, etc.).
   * Elimina extensión, caracteres especiales y reemplaza espacios por guiones bajos.
   * Ejemplo: "Informe Q1 (2025).xlsx" → "Informe_Q1_2025"
   * @param {string} originalname - Texto original.
   * @returns {string} Nombre sanitizado.
   */
  generateFolderName(originalname) {
    return originalname
      .replace(/\.[^/.]+$/, '')             // Eliminar extensión
      .replace(/[^a-zA-Z0-9\s\-_]/g, '')   // Eliminar caracteres especiales
      .replace(/\s+/g, '_')                 // Espacios → guiones bajos
      .trim();
  }

  // ==========================================================================
  // ACCESO A IDS DE CARPETAS DE DRIVE (drive-ids.json)
  // ==========================================================================

  /**
   * Obtiene un ID de carpeta del mapa de configuración.
   * Centraliza la validación para evitar repetir la misma lógica en cada getter.
   * @param {string} key - Clave en el objeto driveIds.
   * @param {string} label - Nombre descriptivo para el mensaje de error.
   * @returns {string} ID de la carpeta.
   * @throws {Error} Si la clave no existe en la configuración.
   * @private
   */
  _getFolderId(key, label) {
    if (!this.driveIds?.[key]) {
      throw new Error(`Falta ID de carpeta "${label}" (key: ${key}) en drive-ids.json`);
    }
    return this.driveIds[key];
  }

  // --- Alertas ---
  /** @returns {string} ID de la carpeta de imágenes de alertas. */
  getImagesAlertsFolderId() {
    return this._getFolderId('imgs_alertas', 'Imágenes de alertas');
  }

  // --- Prototipos ---
  /** @returns {string} ID de la carpeta de prototipos Stuart Weitzman. */
  getSWPrototipeFolderId() {
    return this._getFolderId('sw_prototipos', 'Prototipos SW');
  }

  /** @returns {string} ID de la carpeta de prototipos Versace. */
  getVersacePrototipeFolderId() {
    return this._getFolderId('versace_prototipos', 'Prototipos Versace');
  }

  // --- Pedidos ---
  /** @returns {string} ID de la carpeta de pedidos Stuart Weitzman. */
  getSWPedidosFolderId() {
    return this._getFolderId('sw_pedidos', 'Pedidos SW');
  }

  /** @returns {string} ID de la carpeta de pedidos Versace. */
  getVersacePedidosFolderId() {
    return this._getFolderId('versace_pedidos', 'Pedidos Versace');
  }

  // --- Intrastat ---
  /** @returns {string} ID de la carpeta de ventas Intrastat. */
  getIntrastatVentasFolderId() {
    return this._getFolderId('intrastat_ventas', 'Intrastat ventas');
  }

  /** @returns {string} ID de la carpeta de compras Intrastat. */
  getIntrastatComprasFolderId() {
    return this._getFolderId('intrastat_compras', 'Intrastat compras');
  }

  // --- Nóminas ---
  /** @returns {string} ID de la carpeta de nóminas — asesorías. */
  getNominasAsesoriasFolderID() {
    return this._getFolderId('nominas_asesorias', 'Nóminas asesorías');
  }

  /** @returns {string} ID de la carpeta de nóminas — nóminas. */
  getNominasNominasFolderID() {
    return this._getFolderId('nominas_nominas', 'Nóminas nóminas');
  }

  // --- Inventario ---
  /** @returns {string} ID de la carpeta de inventario. */
  getInventarioFolderID() {
    return this._getFolderId('inventario', 'Inventario');
  }

  // --- Situación de Pedidos ---
  /** @returns {string} ID de la carpeta de informes PDF de situación de pedidos. */
  getSituacionPedidosPDF() {
    return this._getFolderId('situacion_pedidos_pdf', 'Situación pedidos PDF');
  }

  /** @returns {string} ID de la carpeta DIRMA de situación de pedidos. */
  getSituacionPedidosDirma() {
    return this._getFolderId('situacion_pedidos_dirma', 'Situación pedidos DIRMA');
  }

  /** @returns {string} ID de la carpeta Versace de situación de pedidos. */
  getSituacionPedidosVersace() {
    return this._getFolderId('situacion_pedidos_versace', 'Situación pedidos Versace');
  }

  /** @returns {string} ID de la carpeta ERP de situación de pedidos. */
  getSituacionPedidosERP() {
    return this._getFolderId('situacion_pedidos_erp', 'Situación pedidos ERP');
  }

  /** @returns {string} ID de la carpeta SW de situación de pedidos. */
  getSituacionPedidosSW() {
    return this._getFolderId('situacion_pedidos_sw', 'Situación pedidos SW');
  }
}
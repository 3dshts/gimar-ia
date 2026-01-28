// backend/src/infrastructure/database/repositories/drive.repository.js
// -----------------------------------------------------------------------------
// Repositorio para operaciones con Google Drive.
// Encapsula toda la lógica de infraestructura de Google Drive API.
// -----------------------------------------------------------------------------

import { getDrive, bufferToStream } from '../../web/middlewares/google.middleware.js';
import ids from '../../../config/drive-ids.json' with { type: "json" };

export class DriveRepository {
  constructor() {
    this.drive = getDrive();
    this.driveIds = ids;
  }

  /**
   * Busca una carpeta por nombre dentro de un directorio padre.
   * @param {string} folderName Nombre de la carpeta a buscar
   * @param {string} parentId ID del directorio padre
   * @returns {Promise<string|null>} ID de la carpeta encontrada o null
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
   * Crea una carpeta en Drive bajo un ID padre.
   * @param {string} name Nombre de la carpeta
   * @param {string} parentId ID de la carpeta padre
   * @returns {Promise<string>} ID de la carpeta creada
   */
  async createFolder(name, parentId) {
    const fileMetadata = {
      name,
      mimeType: "application/vnd.google-apps.folder",
      parents: [parentId],
    };

    const file = await this.drive.files.create({
      resource: fileMetadata,
      fields: "id, name",
      supportsAllDrives: true,
    });

    return file.data.id;
  }

  /**
   * Sube un archivo a Google Drive y lo hace público.
   * @param {Object} params
   * @param {string} params.name Nombre del archivo
   * @param {string} params.parentId ID de la carpeta padre
   * @param {string} params.mimeType Tipo MIME del archivo
   * @param {Buffer} params.buffer Buffer del archivo
   * @returns {Promise<Object>} Metadatos del archivo subido, incluyendo webContentLink y webViewLink
   */
  async uploadFile({ name, parentId, mimeType, buffer }) {
    // Subir el archivo y pedir los links en la respuesta
    const response = await this.drive.files.create({
      resource: { name, parents: [parentId] },
      media: { mimeType, body: bufferToStream(buffer) },
      fields: "id, name, mimeType, webContentLink, webViewLink",
      supportsAllDrives: true,
    });
  
    const fileData = response.data;
  
    // Configurar permisos públicos
    await this.drive.permissions.create({
      fileId: fileData.id,
      resource: {
        role: 'reader',
        type: 'anyone',
      },
      supportsAllDrives: true,
    });
  
    // Volver a obtener los links actualizados
    const updatedFile = await this.drive.files.get({
      fileId: fileData.id,
      fields: "id, name, mimeType, webContentLink, webViewLink",
      supportsAllDrives: true,
    });
  
    return updatedFile.data;
  }

  /**
   * Configura permisos de lectura pública para un archivo.
   * @param {string} fileId ID del archivo
   * @returns {Promise<void>}
   */
  async setPublicReadPermissions(fileId) {
    await this.drive.permissions.create({
      fileId,
      resource: {
        role: 'reader',
        type: 'anyone',
      },
      supportsAllDrives: true,
    });
  }

  /**
   * Obtiene metadatos de un archivo o carpeta por su ID.
   * @param {string} fileId ID del archivo o carpeta
   * @returns {Promise<Object>} Metadatos del archivo/carpeta
   */
  async getFileMetadata(fileId) {
    const response = await this.drive.files.get({
      fileId,
      fields: "id, name, mimeType, parents, driveId, shortcutDetails",
    });
    return response.data;
  }


  /**
   * Obtiene el ID de la carpeta de imágenes de alertas.
   * @returns {string} ID de la carpeta
   */
  getImagesAlertsFolderId() {
    if (!this.driveIds || !this.driveIds.imgs_alertas) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.imgs_alertas;
  }

    /**
   * Obtiene el ID de la carpeta de prototipos de Stuart Weitzman.
   * @returns {string} ID de la carpeta
   */
  getSWPrototipeFolderId() {
    if (!this.driveIds || !this.driveIds.imgs_alertas) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.sw_prototipos;
  }

    /**
   * Obtiene el ID de la carpeta de prototipos de Versace.
   * @returns {string} ID de la carpeta
   */
  getVersacePrototipeFolderId() {
    if (!this.driveIds || !this.driveIds.imgs_alertas) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.versace_prototipos;
  }

  
    /**
   * Obtiene el ID de la carpeta de pedidos de Stuart Weitzman.
   * @returns {string} ID de la carpeta
   */
  getSWPedidosFolderId() {
    if (!this.driveIds || !this.driveIds.sw_pedidos) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.sw_pedidos;
  }

    /**
   * Obtiene el ID de la carpeta de pedidos de Versace.
   * @returns {string} ID de la carpeta
   */
  getVersacePedidosFolderId() {
    if (!this.driveIds || !this.driveIds.versace_pedidos) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.versace_pedidos;
  }

   /**
   * Obtiene el ID de la carpeta de ventas de Intrastat.
   * @returns {string} ID de la carpeta
   */
  getIntrastatVentasFolderId() {
    if (!this.driveIds || !this.driveIds.intrastat_ventas) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.intrastat_ventas;
  }

   /**
   * Obtiene el ID de la carpeta de compras de Intrastat.
   * @returns {string} ID de la carpeta
   */
  getIntrastatComprasFolderId() {
    if (!this.driveIds || !this.driveIds.intrastat_compras) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.intrastat_compras;
  }

  /**
   * Obtiene el ID de la carpeta de Asesorias.
   * @returns {string} ID de la carpeta
   */
  getNominasAsesoriasFolderID() {
    if (!this.driveIds || !this.driveIds.nominas_asesorias) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.nominas_asesorias;
  }

  /**
   * Obtiene el ID de la carpeta de Nominas.
   * @returns {string} ID de la carpeta
   */
  getNominasNominasFolderID() {
    if (!this.driveIds || !this.driveIds.nominas_nominas) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.nominas_nominas;
  }

  /**
   * Obtiene el ID de la carpeta de Inventario.
   * @returns {string} ID de la carpeta
   */
  getInventarioFolderID() {
    if (!this.driveIds || !this.driveIds.inventario) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.inventario;
  }

  /**
   * Obtiene el ID de la carpeta de Inventario.
   * @returns {string} ID de la carpeta
   */
  getSituacionPedidosPDF() {
    if (!this.driveIds || !this.driveIds.situacion_pedidos_pdf) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.situacion_pedidos_pdf;
  }

  /**
   * Obtiene el ID de la carpeta de Inventario.
   * @returns {string} ID de la carpeta
   */
  getSituacionPedidosDirma() {
    if (!this.driveIds || !this.driveIds.situacion_pedidos_dirma) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.situacion_pedidos_dirma;
  }

  /**
   * Obtiene el ID de la carpeta de Inventario.
   * @returns {string} ID de la carpeta
   */
  getSituacionPedidosVersace() {
    if (!this.driveIds || !this.driveIds.situacion_pedidos_versace) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.situacion_pedidos_versace;
  }

  /**
   * Obtiene el ID de la carpeta de Inventario.
   * @returns {string} ID de la carpeta
   */
  getSituacionPedidosERP() {
    if (!this.driveIds || !this.driveIds.situacion_pedidos_erp) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.situacion_pedidos_erp;
  }

  /**
   * Obtiene el ID de la carpeta de Inventario.
   * @returns {string} ID de la carpeta
   */
  getSituacionPedidosSW() {
    if (!this.driveIds || !this.driveIds.situacion_pedidos_sw) {
      throw new Error("Falta DRIVE_ID en la configuración");
    }
    return this.driveIds.situacion_pedidos_sw;
  }


  /**
   * Genera el nombre de carpeta del día actual en formato DD-MM-YYYY (zona Madrid).
   * @returns {string} Nombre de la carpeta del día
   */
  generateDayFolderName() {
    return new Intl.DateTimeFormat('es-ES', {
      timeZone: 'Europe/Madrid',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    }).format(new Date()).replace(/\//g, '-');
  }

  /**
   * Genera el nombre de la carpeta basado en el nombre del Excel
   * @param {string} originalname Nombre original del archivo
   * @returns {string} Nombre de la carpeta
   */
  generateFolderName(originalname) {
    // Remover la extensión del archivo
    const nameWithoutExtension = originalname.replace(/\.[^/.]+$/, "");
    
    // Limpiar caracteres especiales y espacios
    const cleanName = nameWithoutExtension
      .replace(/[^a-zA-Z0-9\s\-_]/g, '') // Remover caracteres especiales
      .replace(/\s+/g, '_') // Reemplazar espacios con guiones bajos
      .trim();

    return cleanName;
  }

  /**
   * Crea recursivamente una estructura de carpetas a partir de un árbol.
   * @param {Object} folder Nodo raíz con nombre y opcionales children
   * @param {string} parentId ID de la carpeta padre donde colgará la estructura
   * @returns {Promise<string>} ID de la carpeta creada en este nivel
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
}
// backend/src/application/use_cases/extract_images_excel.usecase.js
// -----------------------------------------------------------------------------
// Utilidad para extraer imágenes de archivos Excel - SOLO del rango B8:K28
// -----------------------------------------------------------------------------

import JSZip from 'jszip';
import ExcelJS from 'exceljs';

export class ExcelImageExtractorUseCase {
  /**
   * Extrae SOLO las imágenes que están en el rango B8:K28 de cada hoja
   * @param {Buffer} excelBuffer Buffer del archivo Excel
   * @returns {Promise<Array>} Array de objetos con información de las imágenes del rango específico
   */
  static async extractImages(excelBuffer) {
    try {
      const zip = await JSZip.loadAsync(excelBuffer);
      const images = [];
      const mediaFolder = zip.folder('xl/media');

      if (!mediaFolder) {
        console.log('No se encontró carpeta de medios en el Excel');
        return images;
      }

      // Obtener información de hojas y posiciones de imágenes
      const worksheetsInfo = await this.getWorksheetsWithImages(zip);
      
      // Extraer archivos de medios disponibles
      const mediaFiles = new Map();
      mediaFolder.forEach((relativePath, file) => {
        if (!file.dir && this.isImageFile(file.name)) {
          const imageId = this.getImageIdFromFilename(file.name);
          mediaFiles.set(imageId, file);
        }
      });

      console.log(`📊 Encontradas ${worksheetsInfo.length} hojas de trabajo`);
      console.log(`🖼️ Encontrados ${mediaFiles.size} archivos de medios`);

      // Procesar cada hoja
      for (const worksheetInfo of worksheetsInfo) {
        const { sheetName, sheetIndex, imagePositions } = worksheetInfo;
        
        console.log(`📋 Procesando hoja: ${sheetName}`);
        console.log(`🔍 Imágenes encontradas en la hoja: ${imagePositions.length}`);
        
        // Filtrar SOLO las imágenes que están en la celda principal B8
        const targetImages = imagePositions.filter(pos => {
          const isInTarget = this.isImageInTargetRange(pos);
          console.log(`   📍 Imagen en posición Col:${pos.col}, Row:${pos.row} - En celda B8: ${isInTarget}`);
          return isInTarget;
        });

        console.log(`✅ Imágenes en celda B8 para hoja ${sheetName}: ${targetImages.length}`);

        // Procesar cada imagen que está en el rango objetivo
        for (let i = 0; i < targetImages.length; i++) {
          const imagePos = targetImages[i];
          const mediaFile = mediaFiles.get(imagePos.imageId);
          
          if (mediaFile) {
            console.log(`📥 Extrayendo imagen ${imagePos.imageId} de la hoja ${sheetName}`);
            
            const imageBuffer = await mediaFile.async('nodebuffer');
            const extension = this.getFileExtension(mediaFile.name);
            
            images.push({
              name: `${sheetName}_B8_${i + 1}.${extension}`,
              buffer: imageBuffer,
              mimetype: this.getMimeType(extension),
              originalName: mediaFile.name,
              size: imageBuffer.length,
              sheetName: sheetName,
              sheetIndex: sheetIndex,
              position: {
                col: imagePos.col,
                row: imagePos.row,
                cell: 'B8'
              }
            });
          } else {
            console.warn(`⚠️ No se encontró el archivo de medios para ${imagePos.imageId}`);
          }
        }
      }

      console.log(`🎯 Total de imágenes extraídas de la celda B8: ${images.length}`);
      return images;

    } catch (error) {
      console.error('❌ Error al extraer imágenes del Excel:', error);
      throw new Error(`Error al extraer imágenes: ${error.message}`);
    }
  }

  /**
   * Obtiene información de las hojas de trabajo y sus imágenes
   */
  static async getWorksheetsWithImages(zipContent) {
    const worksheetsInfo = [];
    
    try {
      // Leer el workbook.xml para obtener información de las hojas
      const workbookXml = await zipContent.file('xl/workbook.xml')?.async('text');
      if (!workbookXml) {
        console.log('No se encontró workbook.xml');
        return worksheetsInfo;
      }

      // Parsear nombres de hojas
      const sheetMatches = workbookXml.match(/<sheet[^>]*name="([^"]*)"[^>]*sheetId="(\d+)"/g);
      const sheets = [];
      if (sheetMatches) {
        sheetMatches.forEach(match => {
          const nameMatch = match.match(/name="([^"]*)"/);
          const idMatch = match.match(/sheetId="(\d+)"/);
          if (nameMatch && idMatch) {
            sheets.push({
              name: nameMatch[1],
              id: parseInt(idMatch[1])
            });
          }
        });
      }

      console.log(`📚 Hojas encontradas: ${sheets.map(s => s.name).join(', ')}`);

      // Procesar cada hoja de trabajo
      for (let i = 0; i < sheets.length; i++) {
        const sheet = sheets[i];
        const drawingFile = zipContent.file(`xl/drawings/drawing${i + 1}.xml`);
        
        if (drawingFile) {
          const drawingXml = await drawingFile.async('text');
          const imagePositions = this.parseImagePositions(drawingXml, i + 1);
          
          worksheetsInfo.push({
            sheetName: sheet.name,
            sheetIndex: i + 1,
            imagePositions
          });
        } else {
          console.log(`📄 No se encontró archivo de dibujos para la hoja: ${sheet.name}`);
        }
      }
    } catch (error) {
      console.error('Error procesando hojas de trabajo:', error);
    }

    return worksheetsInfo;
  }

  /**
   * Parsea las posiciones de las imágenes desde el XML de dibujos
   */
  static parseImagePositions(drawingXml, sheetIndex) {
    const positions = [];
    
    try {
      // También buscar elementos twoCellAnchor que pueden definir rangos de celdas
      const anchorMatches = drawingXml.match(/<xdr:(oneCellAnchor|twoCellAnchor)[^>]*>[\s\S]*?<\/xdr:\1>/g);
      
      if (anchorMatches) {
        anchorMatches.forEach((match, index) => {
          // Extraer coordenadas de la celda desde <xdr:from>
          const fromMatch = match.match(/<xdr:from>[\s\S]*?<xdr:col>(\d+)<\/xdr:col>[\s\S]*?<xdr:row>(\d+)<\/xdr:row>[\s\S]*?<\/xdr:from>/);
          
          // Extraer ID de la imagen desde r:embed
          const embedMatch = match.match(/r:embed="([^"]+)"/);
          
          if (fromMatch && embedMatch) {
            const col = parseInt(fromMatch[1]);
            const row = parseInt(fromMatch[2]);
            
            console.log(`🔍 Hoja ${sheetIndex}: Imagen ${embedMatch[1]} en Col:${col}, Row:${row}`);
            
            positions.push({
              imageId: embedMatch[1],
              col: col,
              row: row,
              index: index
            });
          }
        });
      }
    } catch (error) {
      console.error('Error parseando posiciones de imágenes:', error);
    }
    
    return positions;
  }

  /**
   * Verifica si una imagen está en la celda principal de la combinada B8
   * Solo busca en fila 8, columna B (celda principal de la combinada B8:K28)
   */
  static isImageInTargetRange(position) {
  // Rango B8:K28
  const colStart = 1;   // B
  const colEnd = 4;    // K
  const rowStart = 7;   // fila 8
  const rowEnd = 10;    // fila 28

  return (
    position.col >= colStart &&
    position.col <= colEnd &&
    position.row >= rowStart &&
    position.row <= rowEnd
  );
}

  /**
   * Extrae el ID de imagen desde el nombre del archivo de medios
   * Mapea archivos como "image1.png" -> "rId1" basándose en relationships
   */
  static getImageIdFromFilename(filename) {
    // Los archivos de medios siguen el patrón image1.png, image2.jpg, etc.
    const match = filename.match(/image(\d+)/);
    if (match) {
      return `rId${match[1]}`;
    }
    // Fallback para nombres no estándar
    return filename.replace(/\.[^/.]+$/, '');
  }

  /**
   * Lee valores de celdas usando exceljs (método auxiliar)
   */
  static async extractCellData(excelBuffer) {
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(excelBuffer);

    const sheet = workbook.worksheets[0];
    const rows = [];

    sheet.eachRow((row) => {
      rows.push(row.values);
    });

    return rows;
  }

  /**
   * Sube las imágenes extraídas a Drive
   */
  static async uploadImagesToDrive(images, targetFolderId, driveRepository) {
    const uploadedImages = [];
    
    console.log(`📤 Subiendo ${images.length} imágenes a Drive...`);
    
    for (const image of images) {
      try {
        console.log(`📤 Subiendo: ${image.name} (${image.sheetName})`);
        
        const uploadedImage = await driveRepository.uploadFile({
          name: image.name,
          parentId: targetFolderId,
          mimeType: image.mimetype,
          buffer: image.buffer
        });

        await driveRepository.setPublicReadPermissions(uploadedImage.id);

        uploadedImages.push({
          id: uploadedImage.id,
          name: uploadedImage.name,
          webViewLink: uploadedImage.webViewLink,
          webContentLink: uploadedImage.webContentLink,
          size: image.size,
          mimetype: image.mimetype,
          sheetName: image.sheetName,
          position: image.position
        });
        
        console.log(`✅ Subida exitosa: ${image.name}`);
      } catch (imageError) {
        console.error(`❌ Error al subir imagen ${image.name}:`, imageError);
      }
    }

    console.log(`🎉 Total de imágenes subidas: ${uploadedImages.length}`);
    return uploadedImages;
  }

  // Métodos auxiliares (sin cambios)
  static isImageFile(filename) {
    const imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff', '.svg'];
    const extension = filename.toLowerCase().substring(filename.lastIndexOf('.'));
    return imageExtensions.includes(extension);
  }

  static getFileExtension(filename) {
    return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
  }

  static getMimeType(extension) {
    const mimeTypes = {
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'gif': 'image/gif',
      'bmp': 'image/bmp',
      'tiff': 'image/tiff',
      'svg': 'image/svg+xml'
    };
    return mimeTypes[extension.toLowerCase()] || 'image/jpeg';
  }
}
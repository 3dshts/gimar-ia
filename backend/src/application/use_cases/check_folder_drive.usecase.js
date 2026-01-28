// backend/src/application/use_cases/check_folder_drive.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: verificar existencia y metadatos de carpeta/archivo en Drive.
// -----------------------------------------------------------------------------

export class CheckFolderDriveUseCase {
  /**
   * @param {Object} driveRepository Repositorio de Drive con el contrato getFileMetadata
   */
  constructor(driveRepository) {
    this.driveRepository = driveRepository;
  }

  /**
   * Ejecuta la verificación de carpeta/archivo por su ID.
   * @param {Object} params
   * @param {string} params.idFileFolder ID del archivo/carpeta a verificar
   * @returns {Promise<Object>} Metadatos del archivo/carpeta
   */
  async execute({ idFileFolder }) {
    return await this.driveRepository.getFileMetadata(idFileFolder);
  }
}
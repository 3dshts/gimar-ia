// backend/src/application/use_cases/create_folder_structure_drive.usecase.js
// -----------------------------------------------------------------------------
// Caso de uso: crear estructura recursiva de carpetas en Google Drive.
// -----------------------------------------------------------------------------

export class CreateFolderStructureDriveUseCase {
  /**
   * @param {Object} driveRepository Repositorio de Drive con el contrato createRecursiveFolders
   */
  constructor(driveRepository) {
    this.driveRepository = driveRepository;
  }

  /**
   * Ejecuta la creación recursiva de estructura de carpetas.
   * @param {Object} params
   * @param {Object} params.structure Árbol de carpetas con formato:
   *   {
   *     "name": "Carpeta X",
   *     "children": [
   *       {"name": "Subcarpeta X1", "children": []},
   *       {"name": "Subcarpeta X2", "children": [
   *         {"name": "Subcarpeta X21", "children": []}
   *       ]}
   *     ]      
   *   }
   * @returns {Promise<string>} ID de la carpeta raíz creada
   */
  async execute({ structure }) {
    const parentRootId = this.driveRepository.getImagesAlertsFolderId();
    return await this.driveRepository.createRecursiveFolders(structure, parentRootId);
  }
}
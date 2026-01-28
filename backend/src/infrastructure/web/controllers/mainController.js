// backend/src/infrastructure/web/controllers/mainController.js
/**
 * @desc Responde a la petición en la ruta raíz con un objeto JSON.
 *       Útil como healthcheck simple y como prueba de conexión desde el frontend.
 * @param {object} req - Objeto de la petición de Express.
 * @param {object} res - Objeto de la respuesta de Express.
 */
export const getHomePage = (req, res) => {
  // Enviamos una respuesta en formato JSON.
  // Esto es lo que nuestra app de Flutter esperará recibir.
  res.status(200).json({ 
    message: '¡Conexión con el backend de Susy Shoes exitosa! 👠' 
  });
  console.log('Healthcheck realizado con éxito: ' + Date.now() + ' 🟢');
};

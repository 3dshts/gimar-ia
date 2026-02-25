// backend/src/scripts/server.js
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import { connectDB } from './config/database.js';
import mainRoutes from './infrastructure/web/routes/main.routes.js';


// Carga las variables de entorno desde el archivo .env.
// Nota: si .env está en la raíz del proyecto, no es necesario especificar path.
dotenv.config({ path: './src/config/.env' });
dotenv.config();

// Conectar a la base de datos
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());



// Monta las rutas principales (auth, admin, google, etc.).
// Todas se agrupan en mainRoutes.
// Rutas
app.use('/', mainRoutes);

export default app;

const PORT = process.env.PORT || 3000;

// Inicia el servidor y lo pone a escuchar en el puerto configurado.
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en https://susy-shoes-ia.onrender.com`);
});
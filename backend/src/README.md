# SUSY SHOES SL — Backend

Este backend está construido con **Node.js + Express** siguiendo una arquitectura en capas.  
Se conecta a **MongoDB Atlas** como base de datos y expone una API REST para ser consumida por el frontend (Flutter/React).

---

## 📂 Estructura de carpetas

backend/
└─ src/
 ├── application/
 │ └── use_cases/ # Casos de uso (lógica de negocio orquestada)
 │
 ├── config/ # Configuración (DB, .env, tokens Drive)
 │
 ├── credentials/ # Tokens OAuth2 persistentes de Google (tokens.json)
 │
 ├── domain/
 │ └── entities/ # Entidades de dominio (documentación de modelos de negocio)
 │
 ├── infrastructure/
 │ ├── database/
 │ │ │ ├── models/ # Modelos de Mongoose (MongoDB)
 │ │ └── repositories/ # Repositorios que encapsulan queries a Mongo
 │ │
 │ └── web/
 │ ├── controllers/ # Controladores Express (llaman a casos de uso)
 │ ├── middlewares/ # Middlewares Express (auth, Google, etc.)
 │ └── routes/ # Definición de rutas de la API
 │
 └── server.js # Punto de entrada del backend

---

## ⚙️ Flujo general

1. **Request del cliente** → entra a través de **Routes**.
2. **Controllers** → reciben la petición, validan datos básicos y llaman a un caso de uso.
3. **Use Cases** → orquestan la lógica de negocio y llaman a los repositorios.
4. **Repositories** → consultan/actualizan la base de datos mediante los **Models**.
5. **Response** → vuelve al cliente en formato JSON.

---

## 🔑 Principales directorios

- **`application/use_cases/`**  
  Casos de uso como `LoginUseCase`, `GetAllUsersUseCase`, `GetAllLogsUseCase`, etc.  
  Encapsulan la lógica de aplicación y dependen de repositorios.

- **`config/`**  
  Configuración de entorno (`.env`), conexión a MongoDB, IDs de carpetas de Drive y tokens temporales.

- **`credentials/`**  
  Tokens persistentes de Google OAuth2 (`tokens.json`).  
  Permite mantener la sesión sin pedir autenticación repetida.

- **`domain/entities/`**  
  Entidades de dominio (`User`, `Log`).  
  Actualmente funcionan como **documentación estructural** del modelo de negocio.

- **`infrastructure/database/`**  
  - **models/**: esquemas de Mongoose para colecciones `USER` y `LOG_USER`.  
  - **repositories/**: métodos de acceso a datos (findAll, findByUsername, paginación de logs, etc.).

- **`infrastructure/web/`**  
  - **controllers/**: manejan requests HTTP (`auth.controller.js`, `admin.controller.js`, etc.).  
  - **middlewares/**: lógica transversal (`auth.middleware.js` para JWT, `google.middleware.js` para Google APIs).  
  - **routes/**: definen endpoints y asocian rutas a controladores.

- **`server.js`**  
  Punto de entrada: configura Express, carga middlewares globales, conecta a MongoDB y monta las rutas.

---

## 🚀 Endpoints principales

- **Auth** (`/api/auth`)  
  - `POST /login` → login y emisión de JWT  
  - `GET /validate-token` → validación de token y retorno de usuario

- **Admin** (`/api/admin`)  
  - `GET /users` → listado de usuarios  
  - `GET /logs` → listado de logs (con o sin filtros, paginados)

- **Google** (`/api/google`)  
  - `POST /checkFolder` → comprobar carpeta en Drive  
  - `POST /uploadImgAlert` → subir imagen (convertida a PNG) a Drive  
  - `POST /createFolderStructure` → crear estructura de carpetas  
  - `GET /oauth2/callback` → callback para guardar tokens de OAuth2

- **Root** (`/`)  
  - Devuelve un JSON con mensaje de conexión

---

## ✅ Buenas prácticas aplicadas

- **Arquitectura en capas** (limita dependencias entre dominio, aplicación e infraestructura).  
- **Mongoose con modelos explícitos** (colecciones nombradas manualmente).  
- **JWT** para autenticación y autorización.  
- **Google Drive API** integrada con refresco automático de tokens.  
- **Rutas organizadas** en submódulos por dominio.

---
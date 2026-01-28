// backend/src/infrastructure/web/middlewares/google.middleware.js
import { OAuth2Client } from "google-auth-library";
import { PassThrough } from "stream";
import dotenv from "dotenv";

dotenv.config();

async function streamToBuffer(stream) {
  const chunks = [];
  for await (const chunk of stream) {
    chunks.push(chunk);
  }
  return Buffer.concat(chunks);
}

function readTokensFromEnv() {
  const refreshToken = process.env.GOOGLE_REFRESH_TOKEN;
  if (!refreshToken)
    throw new Error("❌ Falta GOOGLE_REFRESH_TOKEN en variables de entorno");
  return { refresh_token: refreshToken };
}

function generateGoogleClient() {
  const client = new OAuth2Client(
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_SECRET,
    process.env.GOOGLE_REDIRECT_URI
  );

  client.setCredentials(readTokensFromEnv());

  client.on("tokens", (newTokens) => {
    if (newTokens.access_token) console.log("✅ Nuevo access_token generado");
  });

  return client;
}

class GoogleDriveWrapper {
  constructor(auth) {
    this.auth = auth;

    this.files = {
      create: this.createFile.bind(this),
      list: this.listFiles.bind(this),
      get: this.getFile.bind(this),
      update: this.updateFile.bind(this),
    };

    this.permissions = {
      create: this.createPermission.bind(this),
    };
  }

  async _getHeaders(extra = {}) {
    const accessTokenResponse = await this.auth.getAccessToken();
    return {
      Authorization: `Bearer ${accessTokenResponse.token}`,
      ...extra,
    };
  }

  // ----------------- FILES -----------------
  async listFiles(params = {}) {
    const searchParams = new URLSearchParams();
    if (params.q) searchParams.append("q", params.q);
    if (params.fields) searchParams.append("fields", params.fields);

    const url = `https://www.googleapis.com/drive/v3/files?${searchParams.toString()}`;
    const response = await fetch(url, {
      method: "GET",
      headers: await this._getHeaders(),
    });
    if (!response.ok) throw new Error(await response.text());
    return { data: await response.json() };
  }

  async getFile({ fileId, fields }) {
    const searchParams = new URLSearchParams();
    if (fields) searchParams.append("fields", fields);

    const url = `https://www.googleapis.com/drive/v3/files/${fileId}?${searchParams.toString()}`;
    const response = await fetch(url, {
      method: "GET",
      headers: await this._getHeaders(),
    });
    if (!response.ok) throw new Error(await response.text());
    return { data: await response.json() };
  }

  async createFile({ resource, media }) {
    // Si no hay media, subimos solo metadata
    if (!media) {
      const response = await fetch(
        "https://www.googleapis.com/drive/v3/files",
        {
          method: "POST",
          headers: await this._getHeaders({
            "Content-Type": "application/json",
          }),
          body: JSON.stringify(resource),
        }
      );
      if (!response.ok) throw new Error(await response.text());
      return { data: await response.json() };
    }

    // Multipart upload
    const boundary = "foo_bar_baz";
    const delimiter = `--${boundary}`;
    const close_delim = `--${boundary}--`;

    // Convertir stream a buffer si es necesario
    const mediaBuffer = Buffer.isBuffer(media.body)
      ? media.body
      : await streamToBuffer(media.body);

    // Construir el body multipart correctamente
    const multipartBody = Buffer.concat([
      Buffer.from(
        `${delimiter}\r\n` +
          `Content-Type: application/json; charset=UTF-8\r\n\r\n` +
          `${JSON.stringify(resource)}\r\n`,
        "utf8"
      ),
      Buffer.from(
        `${delimiter}\r\n` + `Content-Type: ${media.mimeType}\r\n\r\n`,
        "utf8"
      ),
      mediaBuffer,
      Buffer.from(`\r\n${close_delim}`, "utf8"),
    ]);

    const response = await fetch(
      "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart",
      {
        method: "POST",
        headers: await this._getHeaders({
          "Content-Type": `multipart/related; boundary=${boundary}`,
        }),
        body: multipartBody,
      }
    );

    if (!response.ok) throw new Error(await response.text());
    return { data: await response.json() };
  }

  async updateFile({ fileId, resource, media }) {
    if (!media) {
      const response = await fetch(
        `https://www.googleapis.com/drive/v3/files/${fileId}`,
        {
          method: "PATCH",
          headers: await this._getHeaders({
            "Content-Type": "application/json",
          }),
          body: JSON.stringify(resource),
        }
      );
      if (!response.ok) throw new Error(await response.text());
      return { data: await response.json() };
    }

    // Multipart update
    const boundary = "foo_bar_baz";
    const delimiter = `--${boundary}`;
    const close_delim = `--${boundary}--`;

    let mediaBuffer = Buffer.isBuffer(media.body)
      ? media.body
      : await streamToBuffer(media.body);

    const multipartBody = [
      delimiter,
      "Content-Type: application/json; charset=UTF-8",
      "",
      JSON.stringify(resource),
      "",
      delimiter,
      `Content-Type: ${media.mimeType}`,
      "",
    ].join("\r\n");

    const bodyBuffer = Buffer.concat([
      Buffer.from(multipartBody, "utf8"),
      mediaBuffer,
      Buffer.from("\r\n" + close_delim, "utf8"),
    ]);

    const response = await fetch(
      `https://www.googleapis.com/upload/drive/v3/files/${fileId}?uploadType=multipart`,
      {
        method: "PATCH",
        headers: await this._getHeaders({
          "Content-Type": `multipart/related; boundary=${boundary}`,
        }),
        body: bodyBuffer,
      }
    );

    if (!response.ok) throw new Error(await response.text());
    return { data: await response.json() };
  }

  // ----------------- PERMISSIONS -----------------
  async createPermission({ fileId, resource }) {
    const url = `https://www.googleapis.com/drive/v3/files/${fileId}/permissions`;
    const response = await fetch(url, {
      method: "POST",
      headers: await this._getHeaders({ "Content-Type": "application/json" }),
      body: JSON.stringify(resource),
    });

    if (!response.ok) throw new Error(await response.text());
    return { data: await response.json() };
  }
}

// ============================================
// GOOGLE CALENDAR WRAPPER
// ============================================

class GoogleCalendarWrapper {
  constructor(auth) {
    this.auth = auth;
    this.baseUrl = "https://www.googleapis.com/calendar/v3";
  }

  async _getHeaders(extra = {}) {
    const accessTokenResponse = await this.auth.getAccessToken();
    return {
      Authorization: `Bearer ${accessTokenResponse.token}`,
      "Content-Type": "application/json",
      ...extra,
    };
  }

  /**
   * Lista eventos de un calendario en un rango de fechas.
   * @param {string} calendarId ID del calendario (ej: 'primary')
   * @param {string} timeMin Fecha mínima ISO (ej: '2025-11-01T00:00:00Z')
   * @param {string} timeMax Fecha máxima ISO (ej: '2025-11-30T23:59:59Z')
   * @returns {Promise<Object>} Objeto con array de eventos
   */
  async listEvents(calendarId, timeMin, timeMax) {
    const searchParams = new URLSearchParams({
      timeMin,
      timeMax,
      singleEvents: "true",
      orderBy: "startTime",
    });

    const url = `${
      this.baseUrl
    }/calendars/${calendarId}/events?${searchParams.toString()}`;

    console.log(`📅 [Calendar] Listando eventos: ${timeMin} → ${timeMax}`);

    const response = await fetch(url, {
      method: "GET",
      headers: await this._getHeaders(),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(
        `❌ [Calendar] Error al listar eventos: ${response.status}`
      );
      throw new Error(errorText);
    }

    const data = await response.json();
    console.log(
      `✅ [Calendar] Eventos encontrados: ${data.items?.length || 0}`
    );

    return data;
  }

  /**
   * Crea un nuevo evento en el calendario.
   * @param {string} calendarId ID del calendario
   * @param {Object} eventData Datos del evento
   * @returns {Promise<Object>} Evento creado
   */
  async createEvent(calendarId, eventData) {
    const url = `${this.baseUrl}/calendars/${calendarId}/events`;

    console.log(`📅 [Calendar] Creando evento: ${eventData.summary}`);
    console.log(
      "📋 [Calendar DEBUG] Payload enviado:",
      JSON.stringify(eventData, null, 2)
    ); // ← AÑADIR ESTA LÍNEA

    const response = await fetch(url, {
      method: "POST",
      headers: await this._getHeaders(),
      body: JSON.stringify(eventData),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`❌ [Calendar] Error al crear evento: ${response.status}`);
      console.error(`❌ [Calendar] Respuesta completa:`, errorText); // ← AÑADIR ESTA LÍNEA
      throw new Error(errorText);
    }

    const data = await response.json();
    console.log(`✅ [Calendar] Evento creado con ID: ${data.id}`);

    return data;
  }

  /**
   * Actualiza un evento existente.
   * @param {string} calendarId ID del calendario
   * @param {string} eventId ID del evento a actualizar
   * @param {Object} eventData Nuevos datos del evento
   * @returns {Promise<Object>} Evento actualizado
   */
  async updateEvent(calendarId, eventId, eventData) {
    const url = `${this.baseUrl}/calendars/${calendarId}/events/${eventId}`;

    console.log(`📅 [Calendar] Actualizando evento: ${eventId}`);

    const response = await fetch(url, {
      method: "PATCH",
      headers: await this._getHeaders(),
      body: JSON.stringify(eventData),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(
        `❌ [Calendar] Error al actualizar evento: ${response.status}`
      );
      throw new Error(errorText);
    }

    const data = await response.json();
    console.log(`✅ [Calendar] Evento actualizado: ${eventId}`);

    return data;
  }

  /**
   * Elimina un evento del calendario.
   * @param {string} calendarId ID del calendario
   * @param {string} eventId ID del evento a eliminar
   * @returns {Promise<void>}
   */
  async deleteEvent(calendarId, eventId) {
    const url = `${this.baseUrl}/calendars/${calendarId}/events/${eventId}`;

    console.log(`📅 [Calendar] Eliminando evento: ${eventId}`);

    const response = await fetch(url, {
      method: "DELETE",
      headers: await this._getHeaders(),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(
        `❌ [Calendar] Error al eliminar evento: ${response.status}`
      );
      throw new Error(errorText);
    }

    console.log(`✅ [Calendar] Evento eliminado: ${eventId}`);
  }
}

// ----------------- EXPORT -----------------
export function getDrive() {
  return new GoogleDriveWrapper(generateGoogleClient());
}

export function getCalendar() {
  return new GoogleCalendarWrapper(generateGoogleClient());
}

export const bufferToStream = (buffer) => {
  const pt = new PassThrough();
  pt.end(buffer);
  return pt;
};

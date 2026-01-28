// backend/src/infrastructure/database/repositories/calendar.repository.js
// -----------------------------------------------------------------------------
// Repositorio para operaciones con Google Calendar.
// Encapsula toda la lógica de infraestructura de Google Calendar API.
// -----------------------------------------------------------------------------

import { getCalendar } from "../../web/middlewares/google.middleware.js";
import dotenv from "dotenv";

dotenv.config();

export class CalendarRepository {
  constructor() {
    this.calendar = getCalendar();
    this.calendarId = process.env.GOOGLE_CALENDAR_ID || "primary";
  }

  /**
   * Obtiene el ID del calendario configurado.
   * @returns {string} ID del calendario
   */
  getCalendarId() {
    return this.calendarId;
  }

  /**
   * Genera la fecha del día actual en formato YYYY-MM-DD (zona Madrid).
   * @returns {string} Fecha en formato YYYY-MM-DD
   */
  getCurrentDate() {
    return new Intl.DateTimeFormat("en-CA", {
      timeZone: "Europe/Madrid",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).format(new Date());
  }

  /**
   * Lista todos los comentarios en un rango de fechas.
   * @param {string} startDate Fecha inicio (YYYY-MM-DD)
   * @param {string} endDate Fecha fin (YYYY-MM-DD)
   * @returns {Promise<Array>} Array de comentarios transformados
   */
  async listComments(startDate, endDate) {
    // Convertir fechas a ISO con timezone UTC para cubrir todo el día
    const timeMin = `${startDate}T00:00:00Z`;
    const timeMax = `${endDate}T23:59:59Z`;

    const result = await this.calendar.listEvents(
      this.calendarId,
      timeMin,
      timeMax
    );

    // Transformar eventos de Google Calendar a nuestro formato
    return (result.items || []).map((event) =>
      this._transformEventToComment(event)
    );
  }

  /**
   * Crea un nuevo comentario en el calendario.
   * @param {Object} commentData Datos del comentario
   * @param {string} commentData.fecha Fecha del comentario (YYYY-MM-DD)
   * @param {string} commentData.titulo Título del comentario
   * @param {string} commentData.comentario Texto del comentario
   * @param {string} commentData.autorId ID del autor
   * @param {string} commentData.autorNombre Nombre completo del autor
   * @returns {Promise<Object>} Comentario creado
   */
  async createComment(commentData) {
    const eventData = this._transformCommentToEvent(commentData);

    const createdEvent = await this.calendar.createEvent(
      this.calendarId,
      eventData
    );

    return this._transformEventToComment(createdEvent);
  }

  /**
   * Actualiza un comentario existente.
   * @param {string} eventId ID del evento en Google Calendar
   * @param {Object} updateData Datos a actualizar
   * @param {string} updateData.titulo Nuevo título
   * @param {string} updateData.comentario Nuevo comentario
   * @returns {Promise<Object>} Comentario actualizado
   */
  async updateComment(eventId, updateData) {
    // Primero obtenemos el evento actual para preservar las propiedades existentes
    const currentEvents = await this.calendar.listEvents(
      this.calendarId,
      "2020-01-01T00:00:00Z",
      "2030-12-31T23:59:59Z"
    );

    const currentEvent = currentEvents.items?.find((e) => e.id === eventId);
    const currentProps = currentEvent?.extendedProperties?.private || {};

    const eventData = {
      summary: updateData.titulo,
      description: updateData.comentario,
      extendedProperties: {
        private: {
          ...currentProps,
          fechaModificacion: new Date().toISOString(),
        },
      },
    };

    const updatedEvent = await this.calendar.updateEvent(
      this.calendarId,
      eventId,
      eventData
    );

    return this._transformEventToComment(updatedEvent);
  }

  /**
   * Elimina un comentario del calendario.
   * @param {string} eventId ID del evento en Google Calendar
   * @returns {Promise<void>}
   */
  async deleteComment(eventId) {
    await this.calendar.deleteEvent(this.calendarId, eventId);
  }

  // ============================================
  // MÉTODOS PRIVADOS DE TRANSFORMACIÓN
  // ============================================

  /**
   * Transforma un comentario de nuestro formato al formato de evento de Google Calendar.
   * @private
   */
  _transformCommentToEvent(commentData) {
    const now = new Date().toISOString();

    return {
      summary: commentData.titulo,
      description: commentData.comentario,
      start: {
        date: commentData.fecha,
      },
      end: {
        date: commentData.fecha,
      },
      extendedProperties: {
        private: {
          autorId: commentData.autorId,
          autorNombre: commentData.autorNombre,
          fechaCreacion: now,
        },
      },
    };
  }

  /**
   * Transforma un evento de Google Calendar a nuestro formato de comentario.
   * @private
   */
  _transformEventToComment(event) {
    const props = event.extendedProperties?.private || {};

    return {
      id: event.id,
      fecha: event.start?.date || event.start?.dateTime?.split("T")[0],
      titulo: event.summary || "",
      comentario: event.description || "",
      autorId: props.autorId || "unknown",
      autorNombre: props.autorNombre || "Usuario Desconocido",
      fechaCreacion: props.fechaCreacion || event.created,
      fechaModificacion: props.fechaModificacion || event.updated,
    };
  }
}

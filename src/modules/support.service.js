import { query, withTransaction } from "../db/pool.js";
import { PROVIDER_STATUS } from "../config/constants.js";
import { AppError } from "../utils/AppError.js";
import { normalizePhone } from "../utils/phone.js";
import * as adminService from "./admin.service.js";
import { fetchProviderByPhone } from "./serializers.js";

function generateTicketNumber() {
  return `TKT-${Math.floor(100000 + Math.random() * 900000)}`;
}

export async function createProviderPhoneChangeRequest(provider, { requestedPhone, message }) {
  const newPhone = normalizePhone(requestedPhone);
  const text = (message || "").trim();
  if (!text) {
    throw new AppError(400, "Message is required", "MESSAGE_REQUIRED");
  }
  if (!newPhone) {
    throw new AppError(400, "Valid mobile number is required", "PHONE_REQUIRED");
  }

  const { rows: phoneInUse } = await query(`SELECT id FROM providers WHERE phone = $1`, [newPhone]);
  if (phoneInUse[0] && phoneInUse[0].id !== provider.id) {
    throw new AppError(409, "This phone number is already registered", "PHONE_IN_USE");
  }

  const ticketNumber = generateTicketNumber();
  const description = `Requested login number change to ${newPhone}\n\n${text}`;
  const { rows } = await query(
    `INSERT INTO support_tickets (
       ticket_number, category, description, customer_phone, customer_name,
       photos, source, status, ticket_type, provider_id, requested_phone
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, 'open', 'provider_phone_change', $8, $9)
     RETURNING *`,
    [
      ticketNumber,
      "Provider Login Phone Change",
      description,
      provider.phone,
      provider.name || "Provider",
      JSON.stringify([]),
      "provider_mobile",
      provider.id,
      newPhone,
    ],
  );
  return rows[0];
}

export async function getLatestPhoneChangeRequestForProvider(providerId) {
  const { rows } = await query(
    `SELECT id, ticket_number, status, requested_phone, description, created_at, updated_at
     FROM support_tickets
     WHERE provider_id = $1 AND ticket_type = 'provider_phone_change'
     ORDER BY created_at DESC
     LIMIT 1`,
    [providerId],
  );
  return rows[0] || null;
}

export async function acceptPhoneChangeTicket(ticketId, adminNotes) {
  return withTransaction(async (client) => {
    const { rows: ticketRows } = await client.query(
      `SELECT * FROM support_tickets WHERE id = $1 FOR UPDATE`,
      [ticketId],
    );
    const ticket = ticketRows[0];
    if (!ticket) {
      throw new AppError(404, "Ticket not found", "TICKET_NOT_FOUND");
    }
    if (ticket.ticket_type !== "provider_phone_change") {
      throw new AppError(400, "This action only applies to phone change requests", "INVALID_TICKET_TYPE");
    }
    if (!ticket.provider_id || !ticket.requested_phone) {
      throw new AppError(400, "Ticket is missing provider or requested phone", "TICKET_INCOMPLETE");
    }

    const newPhone = normalizePhone(ticket.requested_phone);
    const conflict = await fetchProviderByPhone(client, newPhone);
    if (conflict && conflict.id !== ticket.provider_id) {
      throw new AppError(409, "Requested phone is already in use", "PHONE_IN_USE");
    }

    await client.query(`UPDATE providers SET phone = $1, updated_at = now() WHERE id = $2`, [
      newPhone,
      ticket.provider_id,
    ]);

    const { rows: updated } = await client.query(
      `UPDATE support_tickets
       SET status = 'resolved',
           admin_notes = COALESCE($2, admin_notes),
           updated_at = now()
       WHERE id = $1
       RETURNING *`,
      [ticketId, adminNotes || null],
    );

    const { rows: prov } = await client.query(`SELECT phone FROM providers WHERE id = $1`, [
      ticket.provider_id,
    ]);

    return { ticket: updated[0], newPhone: prov[0]?.phone || newPhone };
  });
}

export async function deleteSupportTicket(ticketId) {
  const { rows } = await query(`SELECT id, ticket_type FROM support_tickets WHERE id = $1`, [ticketId]);
  if (!rows[0]) {
    throw new AppError(404, "Ticket not found", "TICKET_NOT_FOUND");
  }
  if (rows[0].ticket_type === "provider_phone_change") {
    const { rows: updated } = await query(
      `UPDATE support_tickets
       SET status = 'rejected',
           admin_notes = COALESCE(admin_notes, 'Rejected by admin'),
           updated_at = now()
       WHERE id = $1
       RETURNING *`,
      [ticketId],
    );
    return { deleted: true, ticket: updated[0] };
  }
  const { rowCount } = await query(`DELETE FROM support_tickets WHERE id = $1`, [ticketId]);
  if (!rowCount) {
    throw new AppError(404, "Ticket not found", "TICKET_NOT_FOUND");
  }
  return { deleted: true };
}

export async function blockProviderFromTicket(ticketId, admin, reason) {
  const { rows } = await query(`SELECT provider_id FROM support_tickets WHERE id = $1`, [ticketId]);
  const ticket = rows[0];
  if (!ticket?.provider_id) {
    throw new AppError(400, "No provider linked to this ticket", "NO_PROVIDER");
  }

  await adminService.blockProvider(ticket.provider_id, admin, reason || "Blocked via support ticket");

  const { rows: updated } = await query(
    `UPDATE support_tickets
     SET status = 'blocked', admin_notes = COALESCE($2, admin_notes), updated_at = now()
     WHERE id = $1
     RETURNING *`,
    [ticketId, reason || null],
  );

  return updated[0];
}
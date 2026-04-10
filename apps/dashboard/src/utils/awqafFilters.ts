import type { AuditEntry, MaintenanceTicket } from '../types';

/** Maintenance items tied to the Awqaf channel (priority flag or submitted as Awqaf). */
export function isAwqafChannelTicket(t: MaintenanceTicket): boolean {
  return t.highPriorityAwqaf || t.submittedByRole === 'awqaf';
}

/** Audit lines relevant to Awqaf / complaints / religious fines (demo heuristic). */
export function filterAwqafAudit(entries: AuditEntry[]): AuditEntry[] {
  const re = /awqaf|complaint|religious|priority|fine|routed/i;
  return entries.filter((e) => re.test(`${e.action} ${e.detail} ${e.actor}`));
}

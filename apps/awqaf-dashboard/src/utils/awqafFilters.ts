import type { AuditEntry } from '../types';

/** Audit lines relevant to Awqaf / complaints / religious fines (demo heuristic). */
export function filterAwqafAudit(entries: AuditEntry[]): AuditEntry[] {
  const re = /awqaf|complaint|religious|priority|fine|routed|janazah|ghusl|guidance|compliance|imam|mosque/i;
  return entries.filter((e) =>
    re.test(
      `${e.action} ${e.detail} ${e.actor} ${e.actionAr ?? ''} ${e.detailAr ?? ''} ${e.actorAr ?? ''}`,
    ),
  );
}

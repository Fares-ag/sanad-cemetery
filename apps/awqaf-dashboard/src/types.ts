export interface AuditEntry {
  id: string;
  timestamp: string;
  action: string;
  actionAr?: string;
  detail: string;
  detailAr?: string;
  actor: string;
  actorAr?: string;
}

/** Non–maintenance submissions (complaints & religious fines). */
export type AwqafCaseKind = 'complaint' | 'religious_fine';

export type AwqafCaseStatus = 'open' | 'in_review' | 'closed';

export interface AwqafCase {
  id: string;
  kind: AwqafCaseKind;
  summary: string;
  /** Arabic display (demo) — when set, shown instead of summary in AR locale */
  summaryAr?: string;
  status: AwqafCaseStatus;
  cemeteryHint?: string;
  cemeteryHintAr?: string;
  createdAt: string;
  updatedAt?: string;
}

/** Salat al-Janazah scheduling (Awqaf religious workflow — not cemetery maintenance). */
export type JanazahStatus = 'scheduled' | 'completed' | 'delayed';

export interface JanazahEntry {
  id: string;
  deceasedName: string;
  deceasedNameAr?: string;
  mosqueName: string;
  mosqueNameAr?: string;
  /** ISO date-time for planned funeral prayer */
  prayerAt: string;
  status: JanazahStatus;
  notes?: string;
  notesAr?: string;
}

/** Ghusl / washing & kafan preparation coordination. */
export type GhuslStatus = 'pending' | 'in_progress' | 'done';

export interface GhuslTask {
  id: string;
  deceasedName: string;
  deceasedNameAr?: string;
  facilityName: string;
  facilityNameAr?: string;
  scheduledAt: string;
  status: GhuslStatus;
}

/** Public guidance & special-case religious questions (demo). */
export type GuidanceStatus = 'new' | 'assigned' | 'answered';

export interface GuidanceRequest {
  id: string;
  topic: string;
  topicAr?: string;
  summary: string;
  summaryAr?: string;
  status: GuidanceStatus;
  createdAt: string;
  updatedAt?: string;
}

export const AWQAF_ACCOUNT_ROLES = ['staff', 'coordinator', 'inspector', 'admin', 'super_admin'] as const;

export type AwqafAccountRole = (typeof AWQAF_ACCOUNT_ROLES)[number];

/** Local demo account for the Awqaf dashboard (browser storage). Not production-safe. */
export interface AwqafUserAccount {
  id: string;
  email: string;
  displayName: string;
  role: AwqafAccountRole;
  password: string;
  createdAt: string;
}

export type TicketStatus = 'reported' | 'in_progress' | 'resolved';

export interface MaintenanceTicket {
  id: string;
  category: 'Sunken grave' | 'Damaged stone' | 'Overgrown grass' | 'Other';
  description: string;
  descriptionAr?: string;
  status: TicketStatus;
  highPriorityAwqaf: boolean;
  submittedByRole: string;
  cemeteryName: string;
  cemeteryNameAr?: string;
  graveId?: string;
  createdAt: string;
  updatedAt?: string;
}

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

export interface MinistryStats {
  deceasedToday: number;
  deceasedThisMonth: number;
  /** Last 6 months labels + counts for chart */
  monthlyTrend: { month: string; monthAr?: string; count: number }[];
  byCemetery: { name: string; nameAr?: string; burials: number }[];
}

export interface DeceasedRecord {
  id: string;
  fullName: string;
  fullNameAr?: string;
  section: string;
  plot: string;
  deathYear: number;
  isVeteran: boolean;
  branchOfService?: string;
  branchOfServiceAr?: string;
}

export const TICKET_CATEGORIES = ['Sunken grave', 'Damaged stone', 'Overgrown grass', 'Other'] as const;

export const DEMO_ROLES = [
  'visitor',
  'municipality_crew',
  'ministry_municipality',
  'awqaf',
  'admin',
  'super_admin',
] as const;

export type DashboardRole = (typeof DEMO_ROLES)[number];

/** Local demo account (browser storage). Not a secure credential store — replace with real auth. */
export interface DashboardUserAccount {
  id: string;
  email: string;
  displayName: string;
  role: DashboardRole;
  password: string;
  createdAt: string;
}

/** Non–maintenance submissions tracked in the Awqaf ministry dashboard (demo local storage). */
export type AwqafCaseKind = 'complaint' | 'religious_fine';

export type AwqafCaseStatus = 'open' | 'in_review' | 'closed';

export interface AwqafCase {
  id: string;
  kind: AwqafCaseKind;
  summary: string;
  summaryAr?: string;
  status: AwqafCaseStatus;
  cemeteryHint?: string;
  cemeteryHintAr?: string;
  createdAt: string;
  updatedAt?: string;
}

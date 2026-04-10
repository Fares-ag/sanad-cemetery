import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { useAuth } from './AuthContext';
import type {
  AuditEntry,
  AwqafCase,
  AwqafCaseStatus,
  DeceasedRecord,
  MaintenanceTicket,
  MinistryStats,
  TicketStatus,
} from '../types';
import { SEED_AUDIT, SEED_AWQAF_CASES, SEED_DECEASED, SEED_STATS, SEED_TICKETS } from '../data/seed';
import { newId } from '../utils/ids';
import { loadJson, saveJson } from '../utils/storage';
import { fetchPublicAppContent, pushMinistryHeadlineToApi } from '../api/contentApi';

const K_TICKETS = 'sanad_dash_tickets';
const K_AUDIT = 'sanad_dash_audit';
const K_STATS = 'sanad_dash_stats';
const K_AWQAF_CASES = 'sanad_dash_awqaf_cases';

interface DashboardValue {
  tickets: MaintenanceTicket[];
  auditLog: AuditEntry[];
  stats: MinistryStats;
  awqafCases: AwqafCase[];
  deceasedRecords: DeceasedRecord[];
  addTicket: (t: Omit<MaintenanceTicket, 'id' | 'createdAt'>) => void;
  updateTicketStatus: (id: string, status: TicketStatus) => void;
  updateTicket: (id: string, patch: Partial<MaintenanceTicket>) => void;
  deleteTicket: (id: string) => void;
  updateStats: (patch: Partial<MinistryStats>) => void;
  setMonthlyTrend: (trend: { month: string; count: number }[]) => void;
  logAction: (action: string, detail: string, actor?: string) => void;
  addAwqafCase: (c: { kind: AwqafCase['kind']; summary: string; cemeteryHint?: string }) => void;
  updateAwqafCaseStatus: (id: string, status: AwqafCaseStatus) => void;
  resetDemoData: () => void;
  /** Update local headline figures from the content API without pushing (used after admin saves app content). */
  hydrateHeadlineFromContentApi: (deceasedToday: number, deceasedThisMonth: number) => void;
  ticketCounts: {
    open: number;
    inProgress: number;
    resolved: number;
    awqafPriority: number;
  };
}

const DashboardContext = createContext<DashboardValue | null>(null);

function mergeInitial<T>(key: string, seed: T): T {
  const loaded = loadJson<T | null>(key, null);
  return loaded ?? seed;
}

export function DashboardProvider({ children }: { children: ReactNode }) {
  const { currentUser } = useAuth();
  const auditActor =
    currentUser != null ? `${currentUser.displayName} <${currentUser.email}>` : 'dashboard_user';

  const [tickets, setTickets] = useState<MaintenanceTicket[]>(() => mergeInitial(K_TICKETS, SEED_TICKETS));
  const [auditLog, setAuditLog] = useState<AuditEntry[]>(() => mergeInitial(K_AUDIT, SEED_AUDIT));
  const [stats, setStats] = useState<MinistryStats>(() => mergeInitial(K_STATS, SEED_STATS));
  const [awqafCases, setAwqafCases] = useState<AwqafCase[]>(() => mergeInitial(K_AWQAF_CASES, SEED_AWQAF_CASES));

  const deceasedRecords = SEED_DECEASED;

  const persistAwqafCases = useCallback((next: AwqafCase[]) => {
    setAwqafCases(next);
    saveJson(K_AWQAF_CASES, next);
  }, []);

  const persistTickets = useCallback((next: MaintenanceTicket[]) => {
    setTickets(next);
    saveJson(K_TICKETS, next);
  }, []);

  const persistStats = useCallback((next: MinistryStats) => {
    setStats(next);
    saveJson(K_STATS, next);
  }, []);

  const hydrateHeadlineFromContentApi = useCallback((deceasedToday: number, deceasedThisMonth: number) => {
    setStats((s) => {
      const next = { ...s, deceasedToday, deceasedThisMonth };
      saveJson(K_STATS, next);
      return next;
    });
  }, []);

  useEffect(() => {
    fetchPublicAppContent()
      .then((d) => {
        hydrateHeadlineFromContentApi(d.ministryStats.deceasedToday, d.ministryStats.deceasedThisMonth);
      })
      .catch(() => {
        /* API optional — keep localStorage stats */
      });
  }, [hydrateHeadlineFromContentApi]);

  const logAction = useCallback(
    (action: string, detail: string, actor?: string) => {
      const entry: AuditEntry = {
        id: newId('audit'),
        timestamp: new Date().toISOString(),
        action,
        detail,
        actor: actor ?? auditActor,
      };
      setAuditLog((prev) => {
        const next = [entry, ...prev].slice(0, 500);
        saveJson(K_AUDIT, next);
        return next;
      });
    },
    [auditActor],
  );

  const addTicket = useCallback(
    (t: Omit<MaintenanceTicket, 'id' | 'createdAt'>) => {
      const id = `T-${Date.now().toString().slice(-6)}`;
      const created: MaintenanceTicket = {
        ...t,
        id,
        createdAt: new Date().toISOString(),
      };
      persistTickets([created, ...tickets]);
      logAction('ticket_created', `${id} ${t.category} @ ${t.cemeteryName}`);
    },
    [tickets, persistTickets, logAction],
  );

  const updateTicketStatus = useCallback(
    (id: string, status: TicketStatus) => {
      const next = tickets.map((x) =>
        x.id === id
          ? { ...x, status, updatedAt: new Date().toISOString() }
          : x,
      );
      persistTickets(next);
      logAction('ticket_status', `${id} → ${status}`);
    },
    [tickets, persistTickets, logAction],
  );

  const updateTicket = useCallback(
    (id: string, patch: Partial<MaintenanceTicket>) => {
      const next = tickets.map((x) =>
        x.id === id ? { ...x, ...patch, updatedAt: new Date().toISOString() } : x,
      );
      persistTickets(next);
      logAction('ticket_update', `${id} ${JSON.stringify(patch)}`);
    },
    [tickets, persistTickets, logAction],
  );

  const deleteTicket = useCallback(
    (id: string) => {
      persistTickets(tickets.filter((x) => x.id !== id));
      logAction('ticket_deleted', id);
    },
    [tickets, persistTickets, logAction],
  );

  const updateStats = useCallback(
    (patch: Partial<MinistryStats>) => {
      const next = { ...stats, ...patch };
      persistStats(next);
      logAction('stats_update', JSON.stringify(patch));
      void pushMinistryHeadlineToApi(next.deceasedToday, next.deceasedThisMonth).catch(() => {});
    },
    [stats, persistStats, logAction],
  );

  const setMonthlyTrend = useCallback(
    (trend: { month: string; count: number }[]) => {
      persistStats({ ...stats, monthlyTrend: trend });
      logAction('stats_trend_edit', 'monthly trend updated');
    },
    [stats, persistStats, logAction],
  );

  const addAwqafCase = useCallback(
    (c: { kind: AwqafCase['kind']; summary: string; cemeteryHint?: string }) => {
      const id = `AC-${Date.now().toString().slice(-6)}`;
      const created: AwqafCase = {
        id,
        kind: c.kind,
        summary: c.summary,
        status: 'open',
        cemeteryHint: c.cemeteryHint,
        createdAt: new Date().toISOString(),
      };
      setAwqafCases((prev) => {
        const next = [created, ...prev];
        saveJson(K_AWQAF_CASES, next);
        return next;
      });
      logAction('awqaf_case_created', `${id} ${c.kind}`);
    },
    [logAction],
  );

  const updateAwqafCaseStatus = useCallback(
    (id: string, status: AwqafCaseStatus) => {
      setAwqafCases((prev) => {
        const next = prev.map((x) =>
          x.id === id ? { ...x, status, updatedAt: new Date().toISOString() } : x,
        );
        saveJson(K_AWQAF_CASES, next);
        return next;
      });
      logAction('awqaf_case_status', `${id} → ${status}`);
    },
    [logAction],
  );

  const resetDemoData = useCallback(() => {
    persistTickets([...SEED_TICKETS]);
    setAuditLog(() => {
      const next = [...SEED_AUDIT];
      saveJson(K_AUDIT, next);
      return next;
    });
    persistStats({ ...SEED_STATS });
    void pushMinistryHeadlineToApi(SEED_STATS.deceasedToday, SEED_STATS.deceasedThisMonth).catch(() => {});
    persistAwqafCases([...SEED_AWQAF_CASES]);
    logAction('reset', 'Demo data restored');
  }, [persistTickets, persistStats, persistAwqafCases, logAction]);

  const ticketCounts = useMemo(() => {
    const open = tickets.filter((t) => t.status === 'reported').length;
    const inProgress = tickets.filter((t) => t.status === 'in_progress').length;
    const resolved = tickets.filter((t) => t.status === 'resolved').length;
    const awqafPriority = tickets.filter((t) => t.highPriorityAwqaf && t.status !== 'resolved').length;
    return { open, inProgress, resolved, awqafPriority };
  }, [tickets]);

  const value = useMemo<DashboardValue>(
    () => ({
      tickets,
      auditLog,
      stats,
      awqafCases,
      deceasedRecords,
      addTicket,
      updateTicketStatus,
      updateTicket,
      deleteTicket,
      updateStats,
      setMonthlyTrend,
      logAction,
      addAwqafCase,
      updateAwqafCaseStatus,
      resetDemoData,
      hydrateHeadlineFromContentApi,
      ticketCounts,
    }),
    [
      tickets,
      auditLog,
      stats,
      awqafCases,
      deceasedRecords,
      addTicket,
      updateTicketStatus,
      updateTicket,
      deleteTicket,
      updateStats,
      setMonthlyTrend,
      logAction,
      addAwqafCase,
      updateAwqafCaseStatus,
      resetDemoData,
      hydrateHeadlineFromContentApi,
      ticketCounts,
    ],
  );

  return <DashboardContext.Provider value={value}>{children}</DashboardContext.Provider>;
}

export function useDashboard(): DashboardValue {
  const ctx = useContext(DashboardContext);
  if (!ctx) throw new Error('useDashboard must be used within DashboardProvider');
  return ctx;
}

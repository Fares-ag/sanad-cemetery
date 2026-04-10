import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { useAwqafAuth } from './AwqafAuthContext';
import type {
  AuditEntry,
  AwqafCase,
  AwqafCaseStatus,
  GhuslStatus,
  GhuslTask,
  GuidanceRequest,
  GuidanceStatus,
  JanazahEntry,
  JanazahStatus,
} from '../types';
import {
  SEED_AWQAF_AUDIT,
  SEED_COMPLIANCE,
  SEED_GHUSL,
  SEED_GUIDANCE,
  SEED_JANAZAH,
} from '../data/awqafSeed';
import { newId } from '../utils/ids';
import { loadJson, saveJson } from '../utils/storage';
import { filterAwqafAudit } from '../utils/awqafFilters';

const K_JANAZAH = 'sanad_awqaf_janazah';
const K_GHUSL = 'sanad_awqaf_ghusl';
const K_GUIDANCE = 'sanad_awqaf_guidance';
const K_COMPLIANCE = 'sanad_awqaf_compliance_cases';
const K_AUDIT = 'sanad_awqaf_audit_log';

export interface AwqafAppValue {
  janazah: JanazahEntry[];
  ghuslTasks: GhuslTask[];
  guidance: GuidanceRequest[];
  complianceCases: AwqafCase[];
  auditLog: AuditEntry[];
  updateJanazahStatus: (id: string, status: JanazahStatus) => void;
  updateGhuslStatus: (id: string, status: GhuslStatus) => void;
  updateGuidanceStatus: (id: string, status: GuidanceStatus) => void;
  addGuidance: (topic: string, summary: string) => void;
  addComplianceCase: (c: { kind: AwqafCase['kind']; summary: string; cemeteryHint?: string }) => void;
  updateComplianceStatus: (id: string, status: AwqafCaseStatus) => void;
  deleteJanazah: (id: string) => void;
  deleteGhuslTask: (id: string) => void;
  deleteGuidance: (id: string) => void;
  deleteComplianceCase: (id: string) => void;
  logAction: (action: string, detail: string, actor?: string) => void;
  /** Filtered view for religious-affairs page */
  filteredAudit: AuditEntry[];
}

const AwqafAppContext = createContext<AwqafAppValue | null>(null);

function mergeInitial<T>(key: string, seed: T): T {
  const loaded = loadJson<T | null>(key, null);
  return loaded ?? seed;
}

export function AwqafAppProvider({ children }: { children: ReactNode }) {
  const { currentUser } = useAwqafAuth();
  const auditActor =
    currentUser != null ? `${currentUser.displayName} <${currentUser.email}>` : 'awqaf_user';

  const [janazah, setJanazah] = useState<JanazahEntry[]>(() => mergeInitial(K_JANAZAH, SEED_JANAZAH));
  const [ghuslTasks, setGhuslTasks] = useState<GhuslTask[]>(() => mergeInitial(K_GHUSL, SEED_GHUSL));
  const [guidance, setGuidance] = useState<GuidanceRequest[]>(() => mergeInitial(K_GUIDANCE, SEED_GUIDANCE));
  const [complianceCases, setComplianceCases] = useState<AwqafCase[]>(() =>
    mergeInitial(K_COMPLIANCE, SEED_COMPLIANCE),
  );
  const [auditLog, setAuditLog] = useState<AuditEntry[]>(() => mergeInitial(K_AUDIT, SEED_AWQAF_AUDIT));

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

  const persistJanazah = useCallback((next: JanazahEntry[]) => {
    setJanazah(next);
    saveJson(K_JANAZAH, next);
  }, []);

  const persistGhusl = useCallback((next: GhuslTask[]) => {
    setGhuslTasks(next);
    saveJson(K_GHUSL, next);
  }, []);

  const persistGuidance = useCallback((next: GuidanceRequest[]) => {
    setGuidance(next);
    saveJson(K_GUIDANCE, next);
  }, []);

  const persistCompliance = useCallback((next: AwqafCase[]) => {
    setComplianceCases(next);
    saveJson(K_COMPLIANCE, next);
  }, []);

  const updateJanazahStatus = useCallback(
    (id: string, status: JanazahStatus) => {
      persistJanazah(janazah.map((j) => (j.id === id ? { ...j, status } : j)));
      logAction('janazah_status', `${id} → ${status}`);
    },
    [janazah, persistJanazah, logAction],
  );

  const updateGhuslStatus = useCallback(
    (id: string, status: GhuslStatus) => {
      persistGhusl(ghuslTasks.map((g) => (g.id === id ? { ...g, status } : g)));
      logAction('ghusl_status', `${id} → ${status}`);
    },
    [ghuslTasks, persistGhusl, logAction],
  );

  const updateGuidanceStatus = useCallback(
    (id: string, status: GuidanceStatus) => {
      persistGuidance(
        guidance.map((g) =>
          g.id === id ? { ...g, status, updatedAt: new Date().toISOString() } : g,
        ),
      );
      logAction('guidance_status', `${id} → ${status}`);
    },
    [guidance, persistGuidance, logAction],
  );

  const addGuidance = useCallback(
    (topic: string, summary: string) => {
      const id = `GD-${Date.now().toString().slice(-6)}`;
      const created: GuidanceRequest = {
        id,
        topic: topic.trim() || 'General',
        summary: summary.trim() || '—',
        status: 'new',
        createdAt: new Date().toISOString(),
      };
      persistGuidance([created, ...guidance]);
      logAction('guidance_created', id);
    },
    [guidance, persistGuidance, logAction],
  );

  const addComplianceCase = useCallback(
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
      persistCompliance([created, ...complianceCases]);
      logAction('compliance_case_created', `${id} ${c.kind}`);
    },
    [complianceCases, persistCompliance, logAction],
  );

  const updateComplianceStatus = useCallback(
    (id: string, status: AwqafCaseStatus) => {
      persistCompliance(
        complianceCases.map((x) =>
          x.id === id ? { ...x, status, updatedAt: new Date().toISOString() } : x,
        ),
      );
      logAction('compliance_status', `${id} → ${status}`);
    },
    [complianceCases, persistCompliance, logAction],
  );

  const deleteJanazah = useCallback(
    (id: string) => {
      persistJanazah(janazah.filter((j) => j.id !== id));
      logAction('janazah_deleted', id);
    },
    [janazah, persistJanazah, logAction],
  );

  const deleteGhuslTask = useCallback(
    (id: string) => {
      persistGhusl(ghuslTasks.filter((g) => g.id !== id));
      logAction('ghusl_deleted', id);
    },
    [ghuslTasks, persistGhusl, logAction],
  );

  const deleteGuidance = useCallback(
    (id: string) => {
      persistGuidance(guidance.filter((g) => g.id !== id));
      logAction('guidance_deleted', id);
    },
    [guidance, persistGuidance, logAction],
  );

  const deleteComplianceCase = useCallback(
    (id: string) => {
      persistCompliance(complianceCases.filter((c) => c.id !== id));
      logAction('compliance_case_deleted', id);
    },
    [complianceCases, persistCompliance, logAction],
  );

  const filteredAudit = useMemo(() => filterAwqafAudit(auditLog), [auditLog]);

  const value = useMemo<AwqafAppValue>(
    () => ({
      janazah,
      ghuslTasks,
      guidance,
      complianceCases,
      auditLog,
      updateJanazahStatus,
      updateGhuslStatus,
      updateGuidanceStatus,
      addGuidance,
      addComplianceCase,
      updateComplianceStatus,
      deleteJanazah,
      deleteGhuslTask,
      deleteGuidance,
      deleteComplianceCase,
      logAction,
      filteredAudit,
    }),
    [
      janazah,
      ghuslTasks,
      guidance,
      complianceCases,
      auditLog,
      updateJanazahStatus,
      updateGhuslStatus,
      updateGuidanceStatus,
      addGuidance,
      addComplianceCase,
      updateComplianceStatus,
      deleteJanazah,
      deleteGhuslTask,
      deleteGuidance,
      deleteComplianceCase,
      logAction,
      filteredAudit,
    ],
  );

  return <AwqafAppContext.Provider value={value}>{children}</AwqafAppContext.Provider>;
}

export function useAwqafApp(): AwqafAppValue {
  const ctx = useContext(AwqafAppContext);
  if (!ctx) throw new Error('useAwqafApp must be used within AwqafAppProvider');
  return ctx;
}

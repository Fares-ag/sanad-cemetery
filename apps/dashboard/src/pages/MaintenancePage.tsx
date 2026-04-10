import { useEffect, useMemo, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useDashboard } from '../context/DashboardContext';
import { Modal } from '../components/Modal';
import { useI18n, useLocalizedText } from '../i18n';
import type { DashKey } from '../i18n';
import type { MaintenanceTicket, TicketStatus } from '../types';
import { TICKET_CATEGORIES, DEMO_ROLES } from '../types';
import { formatDate } from '../utils/ids';

const STATUS_OPTIONS: TicketStatus[] = ['reported', 'in_progress', 'resolved'];

function catKey(c: string): DashKey {
  return `ticketCategory.${c}` as DashKey;
}

export function MaintenancePage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { tickets, addTicket, updateTicketStatus, deleteTicket } = useDashboard();

  const [q, setQ] = useState('');
  const [statusFilter, setStatusFilter] = useState<TicketStatus | 'all'>('all');
  const [catFilter, setCatFilter] = useState<string>('all');
  const [prioOnly, setPrioOnly] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);

  const filtered = useMemo(() => {
    return tickets.filter((x) => {
      if (statusFilter !== 'all' && x.status !== statusFilter) return false;
      if (catFilter !== 'all' && x.category !== catFilter) return false;
      if (prioOnly && !x.highPriorityAwqaf) return false;
      if (q.trim()) {
        const s = `${x.id} ${x.description} ${x.descriptionAr ?? ''} ${x.cemeteryName} ${x.cemeteryNameAr ?? ''} ${x.graveId ?? ''}`.toLowerCase();
        if (!s.includes(q.toLowerCase())) return false;
      }
      return true;
    });
  }, [tickets, q, statusFilter, catFilter, prioOnly]);

  function exportCsv() {
    const headers = ['id', 'category', 'status', 'cemetery', 'awqaf_priority', 'role', 'created'];
    const rows = filtered.map((x) =>
      [
        x.id,
        t(catKey(x.category)),
        statusLabel(x.status),
        loc(x.cemeteryName, x.cemeteryNameAr),
        x.highPriorityAwqaf ? 'yes' : 'no',
        roleLabel(x.submittedByRole),
        x.createdAt,
      ].join(','),
    );
    const blob = new Blob([[headers.join(','), ...rows].join('\n')], { type: 'text/csv;charset=utf-8' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `sanad-maintenance-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(a.href);
  }

  function statusLabel(s: TicketStatus) {
    return t(`ticketStatus.${s}` as DashKey);
  }

  function roleLabel(r: string) {
    return t(`role.${r}` as DashKey);
  }

  return (
    <div className="stack">
      <div className="toolbar">
        <div className="field">
          <label htmlFor="search">{t('maintenance.search')}</label>
          <input
            id="search"
            type="search"
            placeholder={t('maintenance.searchPh')}
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
        </div>
        <div className="field">
          <label htmlFor="st">{t('maintenance.status')}</label>
          <select id="st" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value as TicketStatus | 'all')}>
            <option value="all">{t('maintenance.statusAll')}</option>
            {STATUS_OPTIONS.map((s) => (
              <option key={s} value={s}>
                {statusLabel(s)}
              </option>
            ))}
          </select>
        </div>
        <div className="field">
          <label htmlFor="cat">{t('maintenance.category')}</label>
          <select id="cat" value={catFilter} onChange={(e) => setCatFilter(e.target.value)}>
            <option value="all">{t('maintenance.statusAll')}</option>
            {TICKET_CATEGORIES.map((c) => (
              <option key={c} value={c}>
                {t(catKey(c))}
              </option>
            ))}
          </select>
        </div>
        <label className="check">
          <input type="checkbox" checked={prioOnly} onChange={(e) => setPrioOnly(e.target.checked)} />
          {t('maintenance.awqafOnly')}
        </label>
        <div className="toolbar-actions">
          <button type="button" className="btn btn-secondary" onClick={exportCsv}>
            {t('maintenance.exportCsv')}
          </button>
          <button type="button" className="btn btn-primary" onClick={() => setModalOpen(true)}>
            {t('maintenance.newTicket')}
          </button>
        </div>
      </div>

      <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>{t('maintenance.th.id')}</th>
              <th>{t('maintenance.th.category')}</th>
              <th>{t('maintenance.th.cemetery')}</th>
              <th>{t('maintenance.th.status')}</th>
              <th>{t('maintenance.th.priority')}</th>
              <th>{t('maintenance.th.role')}</th>
              <th>{t('maintenance.th.created')}</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {filtered.map((x) => (
              <tr key={x.id}>
                <td className="mono">{x.id}</td>
                <td>{t(catKey(x.category))}</td>
                <td>{loc(x.cemeteryName, x.cemeteryNameAr)}</td>
                <td>
                  <select
                    className="select-inline"
                    value={x.status}
                    onChange={(e) => updateTicketStatus(x.id, e.target.value as TicketStatus)}
                    aria-label={`${t('maintenance.th.status')} ${x.id}`}
                  >
                    {STATUS_OPTIONS.map((s) => (
                      <option key={s} value={s}>
                        {statusLabel(s)}
                      </option>
                    ))}
                  </select>
                </td>
                <td>
                  {x.highPriorityAwqaf ? <span className="badge badge-awqaf">{t('badge.awqaf')}</span> : t('records.dash')}
                </td>
                <td className="muted small">{roleLabel(x.submittedByRole)}</td>
                <td className="muted small">{formatDate(x.createdAt)}</td>
                <td>
                  <button type="button" className="btn btn-ghost btn-sm" onClick={() => deleteTicket(x.id)}>
                    {t('maintenance.delete')}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <p className="empty">{t('maintenance.empty')}</p>}
      </div>

      <AddTicketModal open={modalOpen} onClose={() => setModalOpen(false)} addTicket={addTicket} />
    </div>
  );
}

function AddTicketModal({
  open,
  onClose,
  addTicket,
}: {
  open: boolean;
  onClose: () => void;
  addTicket: (x: Omit<MaintenanceTicket, 'id' | 'createdAt'>) => void;
}) {
  const { currentUser } = useAuth();
  const { t } = useI18n();
  const [category, setCategory] = useState<(typeof TICKET_CATEGORIES)[number]>('Sunken grave');
  const [description, setDescription] = useState('');
  const [cemeteryName, setCemeteryName] = useState('Al Rayyan Cemetery');
  const [graveId, setGraveId] = useState('');
  const [role, setRole] = useState<string>(currentUser?.role ?? 'municipality_crew');
  const [awqaf, setAwqaf] = useState(false);

  useEffect(() => {
    if (open && currentUser) setRole(currentUser.role);
  }, [open, currentUser]);

  function submit(e: React.FormEvent) {
    e.preventDefault();
    addTicket({
      category,
      description: description.trim() || '—',
      status: 'reported',
      highPriorityAwqaf: awqaf || role === 'awqaf',
      submittedByRole: role,
      cemeteryName: cemeteryName.trim() || 'Unknown',
      graveId: graveId.trim() || undefined,
    });
    setDescription('');
    setGraveId('');
    onClose();
  }

  function catKey(c: string): DashKey {
    return `ticketCategory.${c}` as DashKey;
  }

  function roleLabel(r: string) {
    return t(`role.${r}` as DashKey);
  }

  return (
    <Modal open={open} onClose={onClose} title={t('maintenance.modal.title')} closeAriaLabel={t('modal.close')}>
      <form onSubmit={submit} className="form-grid">
        <div className="field">
          <label htmlFor="cat">{t('maintenance.modal.category')}</label>
          <select id="cat" value={category} onChange={(e) => setCategory(e.target.value as (typeof TICKET_CATEGORIES)[number])}>
            {TICKET_CATEGORIES.map((c) => (
              <option key={c} value={c}>
                {t(catKey(c))}
              </option>
            ))}
          </select>
        </div>
        <div className="field full">
          <label htmlFor="desc">{t('maintenance.modal.description')}</label>
          <textarea id="desc" rows={3} value={description} onChange={(e) => setDescription(e.target.value)} required />
        </div>
        <div className="field">
          <label htmlFor="cem">{t('maintenance.modal.cemetery')}</label>
          <input id="cem" value={cemeteryName} onChange={(e) => setCemeteryName(e.target.value)} required />
        </div>
        <div className="field">
          <label htmlFor="grave">{t('maintenance.modal.grave')}</label>
          <input id="grave" value={graveId} onChange={(e) => setGraveId(e.target.value)} placeholder="grave-001" />
        </div>
        <div className="field">
          <label htmlFor="role">{t('maintenance.modal.role')}</label>
          <select id="role" value={role} onChange={(e) => setRole(e.target.value)}>
            {DEMO_ROLES.map((r) => (
              <option key={r} value={r}>
                {roleLabel(r)}
              </option>
            ))}
          </select>
        </div>
        <label className="check full">
          <input type="checkbox" checked={awqaf} onChange={(e) => setAwqaf(e.target.checked)} />
          {t('maintenance.modal.awqafChk')}
        </label>
        <div className="form-actions full">
          <button type="button" className="btn btn-secondary" onClick={onClose}>
            {t('maintenance.modal.cancel')}
          </button>
          <button type="submit" className="btn btn-primary">
            {t('maintenance.modal.create')}
          </button>
        </div>
      </form>
    </Modal>
  );
}

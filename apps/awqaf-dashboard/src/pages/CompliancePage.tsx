import { useMemo, useState, type FormEvent } from 'react';
import { useAwqafApp } from '../context/AwqafAppContext';
import { Modal } from '../components/Modal';
import { useI18n, useLocalizedText } from '../i18n';
import type { AwqafKey } from '../i18n';
import type { AwqafCaseKind, AwqafCaseStatus } from '../types';
import { formatDate } from '../utils/ids';

const STATUS_OPTS: AwqafCaseStatus[] = ['open', 'in_review', 'closed'];

export function CompliancePage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { complianceCases, addComplianceCase, updateComplianceStatus, deleteComplianceCase } = useAwqafApp();
  const [q, setQ] = useState('');
  const [modalOpen, setModalOpen] = useState(false);

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    if (!term) return complianceCases;
    return complianceCases.filter((c) => {
      const hay = `${c.id} ${c.summary} ${c.summaryAr ?? ''} ${c.cemeteryHint ?? ''} ${c.cemeteryHintAr ?? ''}`.toLowerCase();
      return hay.includes(term);
    });
  }, [complianceCases, q]);

  function statusLabel(s: AwqafCaseStatus) {
    return t(`complianceStatus.${s}` as AwqafKey);
  }

  function kindLabel(kind: AwqafCaseKind) {
    return kind === 'complaint' ? t('compliance.kind.complaint') : t('compliance.kind.fine');
  }

  return (
    <div className="stack">
      <p className="lead">{t('compliance.lead')}</p>
      <div className="toolbar">
        <div className="field grow">
          <label htmlFor="cq">{t('compliance.search')}</label>
          <input
            id="cq"
            type="search"
            placeholder={t('compliance.searchPh')}
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
        </div>
        <div className="toolbar-actions">
          <button type="button" className="btn btn-primary" onClick={() => setModalOpen(true)}>
            {t('compliance.newCase')}
          </button>
        </div>
      </div>

      <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>{t('compliance.th.id')}</th>
              <th>{t('compliance.th.kind')}</th>
              <th>{t('compliance.th.summary')}</th>
              <th>{t('compliance.th.cemetery')}</th>
              <th>{t('compliance.th.status')}</th>
              <th>{t('compliance.th.created')}</th>
              <th aria-label={t('janazah.th.actions')} />
            </tr>
          </thead>
          <tbody>
            {filtered.map((c) => (
              <tr key={c.id}>
                <td className="mono">{c.id}</td>
                <td>
                  <span className={'badge ' + (c.kind === 'complaint' ? 'badge-reported' : 'badge-in_progress')}>
                    {kindLabel(c.kind)}
                  </span>
                </td>
                <td className="detail-cell">{loc(c.summary, c.summaryAr)}</td>
                <td>
                  {c.cemeteryHint != null && c.cemeteryHint !== ''
                    ? loc(c.cemeteryHint, c.cemeteryHintAr)
                    : t('common.emDash')}
                </td>
                <td>
                  <select
                    className="select-inline"
                    value={c.status}
                    onChange={(e) => updateComplianceStatus(c.id, e.target.value as AwqafCaseStatus)}
                    aria-label={`${t('compliance.th.status')} ${c.id}`}
                  >
                    {STATUS_OPTS.map((s) => (
                      <option key={s} value={s}>
                        {statusLabel(s)}
                      </option>
                    ))}
                  </select>
                </td>
                <td className="muted small">{formatDate(c.createdAt)}</td>
                <td>
                  <button
                    type="button"
                    className="btn btn-ghost btn-sm"
                    onClick={() => {
                      if (!window.confirm(t('compliance.confirmDelete'))) return;
                      deleteComplianceCase(c.id);
                    }}
                  >
                    {t('compliance.delete')}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <p className="empty">{t('compliance.empty')}</p>}
      </div>

      <AddCaseModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        onAdd={(c) => {
          addComplianceCase(c);
          setModalOpen(false);
        }}
      />
    </div>
  );
}

function AddCaseModal({
  open,
  onClose,
  onAdd,
}: {
  open: boolean;
  onClose: () => void;
  onAdd: (c: { kind: AwqafCaseKind; summary: string; cemeteryHint?: string }) => void;
}) {
  const { t } = useI18n();
  const [kind, setKind] = useState<AwqafCaseKind>('complaint');
  const [summary, setSummary] = useState('');
  const [cemetery, setCemetery] = useState('');

  function submit(e: FormEvent) {
    e.preventDefault();
    onAdd({
      kind,
      summary: summary.trim() || t('common.emDash'),
      cemeteryHint: cemetery.trim() || undefined,
    });
    setSummary('');
    setCemetery('');
  }

  return (
    <Modal open={open} onClose={onClose} title={t('compliance.modal.title')} closeAriaLabel={t('modal.close')}>
      <form onSubmit={submit} className="form-grid">
        <div className="field">
          <label htmlFor="kind">{t('compliance.modal.kind')}</label>
          <select id="kind" value={kind} onChange={(e) => setKind(e.target.value as AwqafCaseKind)}>
            <option value="complaint">{t('compliance.kind.complaint')}</option>
            <option value="religious_fine">{t('compliance.kind.fine')}</option>
          </select>
        </div>
        <div className="field full">
          <label htmlFor="sum">{t('compliance.modal.summary')}</label>
          <textarea id="sum" rows={4} value={summary} onChange={(e) => setSummary(e.target.value)} required />
        </div>
        <div className="field full">
          <label htmlFor="cem">{t('compliance.modal.cemetery')}</label>
          <input
            id="cem"
            value={cemetery}
            onChange={(e) => setCemetery(e.target.value)}
            placeholder={t('compliance.modal.cemeteryPh')}
          />
        </div>
        <div className="form-actions full">
          <button type="button" className="btn btn-secondary" onClick={onClose}>
            {t('compliance.modal.cancel')}
          </button>
          <button type="submit" className="btn btn-primary">
            {t('compliance.modal.create')}
          </button>
        </div>
      </form>
    </Modal>
  );
}

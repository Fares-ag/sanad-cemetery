import { useMemo, useState, type FormEvent } from 'react';
import { useAwqafApp } from '../context/AwqafAppContext';
import { Modal } from '../components/Modal';
import { useI18n, useLocalizedText } from '../i18n';
import type { AwqafKey } from '../i18n';
import type { GuidanceStatus } from '../types';
import { formatDate } from '../utils/ids';

const STATUS_OPTS: GuidanceStatus[] = ['new', 'assigned', 'answered'];

export function GuidancePage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { guidance, updateGuidanceStatus, addGuidance, deleteGuidance } = useAwqafApp();
  const [q, setQ] = useState('');
  const [modalOpen, setModalOpen] = useState(false);

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    if (!term) return guidance;
    return guidance.filter((g) => {
      const hay = `${g.topic} ${g.topicAr ?? ''} ${g.summary} ${g.summaryAr ?? ''} ${g.id}`.toLowerCase();
      return hay.includes(term);
    });
  }, [guidance, q]);

  function statusLabel(s: GuidanceStatus) {
    return t(`guidanceStatus.${s}` as AwqafKey);
  }

  return (
    <div className="stack">
      <p className="lead">{t('guidance.lead')}</p>
      <div className="toolbar">
        <div className="field grow">
          <label htmlFor="gq">{t('guidance.search')}</label>
          <input
            id="gq"
            type="search"
            placeholder={t('guidance.searchPh')}
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
        </div>
        <div className="toolbar-actions">
          <button type="button" className="btn btn-primary" onClick={() => setModalOpen(true)}>
            {t('guidance.newRequest')}
          </button>
        </div>
      </div>
      <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>{t('guidance.th.id')}</th>
              <th>{t('guidance.th.topic')}</th>
              <th>{t('guidance.th.summary')}</th>
              <th>{t('guidance.th.status')}</th>
              <th>{t('guidance.th.created')}</th>
              <th aria-label={t('janazah.th.actions')} />
            </tr>
          </thead>
          <tbody>
            {filtered.map((g) => (
              <tr key={g.id}>
                <td className="mono">{g.id}</td>
                <td>{loc(g.topic, g.topicAr)}</td>
                <td className="detail-cell">{loc(g.summary, g.summaryAr)}</td>
                <td>
                  <select
                    className="select-inline"
                    value={g.status}
                    onChange={(e) => updateGuidanceStatus(g.id, e.target.value as GuidanceStatus)}
                    aria-label={`${t('guidance.th.status')} ${g.id}`}
                  >
                    {STATUS_OPTS.map((s) => (
                      <option key={s} value={s}>
                        {statusLabel(s)}
                      </option>
                    ))}
                  </select>
                </td>
                <td className="muted small">{formatDate(g.createdAt)}</td>
                <td>
                  <button
                    type="button"
                    className="btn btn-ghost btn-sm"
                    onClick={() => {
                      if (!window.confirm(t('guidance.confirmDelete'))) return;
                      deleteGuidance(g.id);
                    }}
                  >
                    {t('guidance.delete')}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <p className="empty">{t('guidance.empty')}</p>}
      </div>

      <GuidanceModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        onAdd={(topic, summary) => {
          addGuidance(topic, summary);
          setModalOpen(false);
        }}
      />
    </div>
  );
}

function GuidanceModal({
  open,
  onClose,
  onAdd,
}: {
  open: boolean;
  onClose: () => void;
  onAdd: (topic: string, summary: string) => void;
}) {
  const { t } = useI18n();
  const [topic, setTopic] = useState('');
  const [summary, setSummary] = useState('');

  function submit(e: FormEvent) {
    e.preventDefault();
    onAdd(topic, summary);
    setTopic('');
    setSummary('');
  }

  return (
    <Modal open={open} onClose={onClose} title={t('guidance.modal.title')} closeAriaLabel={t('modal.close')}>
      <form onSubmit={submit} className="form-grid">
        <div className="field full">
          <label htmlFor="gt">{t('guidance.modal.topic')}</label>
          <input
            id="gt"
            value={topic}
            onChange={(e) => setTopic(e.target.value)}
            required
            placeholder={t('guidance.modal.topicPh')}
          />
        </div>
        <div className="field full">
          <label htmlFor="gs">{t('guidance.modal.summary')}</label>
          <textarea id="gs" rows={4} value={summary} onChange={(e) => setSummary(e.target.value)} required />
        </div>
        <div className="form-actions full">
          <button type="button" className="btn btn-secondary" onClick={onClose}>
            {t('guidance.modal.cancel')}
          </button>
          <button type="submit" className="btn btn-primary">
            {t('guidance.modal.submit')}
          </button>
        </div>
      </form>
    </Modal>
  );
}

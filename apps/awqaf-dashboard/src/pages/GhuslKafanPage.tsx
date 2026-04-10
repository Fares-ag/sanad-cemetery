import { useMemo, useState } from 'react';
import { useAwqafApp } from '../context/AwqafAppContext';
import { useI18n, useLocalizedText } from '../i18n';
import type { AwqafKey } from '../i18n';
import type { GhuslStatus } from '../types';
import { formatDate } from '../utils/ids';

const STATUS_OPTS: GhuslStatus[] = ['pending', 'in_progress', 'done'];

export function GhuslKafanPage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { ghuslTasks, updateGhuslStatus, deleteGhuslTask } = useAwqafApp();
  const [q, setQ] = useState('');

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    if (!term) return ghuslTasks;
    return ghuslTasks.filter((g) => {
      const hay = `${g.deceasedName} ${g.deceasedNameAr ?? ''} ${g.facilityName} ${g.facilityNameAr ?? ''} ${g.id}`.toLowerCase();
      return hay.includes(term);
    });
  }, [ghuslTasks, q]);

  function statusLabel(s: GhuslStatus) {
    return t(`ghuslStatus.${s}` as AwqafKey);
  }

  return (
    <div className="stack">
      <p className="lead">{t('ghusl.lead')}</p>
      <div className="toolbar">
        <div className="field grow">
          <label htmlFor="gq">{t('ghusl.search')}</label>
          <input
            id="gq"
            type="search"
            placeholder={t('ghusl.searchPh')}
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
        </div>
      </div>
      <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>{t('ghusl.th.id')}</th>
              <th>{t('ghusl.th.deceased')}</th>
              <th>{t('ghusl.th.facility')}</th>
              <th>{t('ghusl.th.scheduled')}</th>
              <th>{t('ghusl.th.status')}</th>
              <th aria-label={t('janazah.th.actions')} />
            </tr>
          </thead>
          <tbody>
            {filtered.map((g) => (
              <tr key={g.id}>
                <td className="mono">{g.id}</td>
                <td>{loc(g.deceasedName, g.deceasedNameAr)}</td>
                <td>{loc(g.facilityName, g.facilityNameAr)}</td>
                <td className="muted small">{formatDate(g.scheduledAt)}</td>
                <td>
                  <select
                    className="select-inline"
                    value={g.status}
                    onChange={(e) => updateGhuslStatus(g.id, e.target.value as GhuslStatus)}
                    aria-label={`${t('ghusl.th.status')} ${g.id}`}
                  >
                    {STATUS_OPTS.map((s) => (
                      <option key={s} value={s}>
                        {statusLabel(s)}
                      </option>
                    ))}
                  </select>
                </td>
                <td>
                  <button
                    type="button"
                    className="btn btn-ghost btn-sm"
                    onClick={() => {
                      if (!window.confirm(t('ghusl.confirmDelete'))) return;
                      deleteGhuslTask(g.id);
                    }}
                  >
                    {t('ghusl.delete')}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <p className="empty">{t('ghusl.empty')}</p>}
      </div>
    </div>
  );
}

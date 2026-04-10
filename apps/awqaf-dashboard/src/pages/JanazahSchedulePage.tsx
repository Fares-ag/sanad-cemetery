import { useMemo, useState } from 'react';
import { useAwqafApp } from '../context/AwqafAppContext';
import { useI18n, useLocalizedText } from '../i18n';
import type { AwqafKey } from '../i18n';
import type { JanazahStatus } from '../types';
import { formatDate } from '../utils/ids';

const STATUS_OPTS: JanazahStatus[] = ['scheduled', 'completed', 'delayed'];

export function JanazahSchedulePage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { janazah, updateJanazahStatus, deleteJanazah } = useAwqafApp();
  const [q, setQ] = useState('');

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    if (!term) return janazah;
    return janazah.filter((j) => {
      const hay = `${j.deceasedName} ${j.deceasedNameAr ?? ''} ${j.mosqueName} ${j.mosqueNameAr ?? ''} ${j.notes ?? ''} ${j.notesAr ?? ''} ${j.id}`.toLowerCase();
      return hay.includes(term);
    });
  }, [janazah, q]);

  function statusLabel(s: JanazahStatus) {
    return t(`janazahStatus.${s}` as AwqafKey);
  }

  return (
    <div className="stack">
      <p className="lead">{t('janazah.lead')}</p>
      <div className="toolbar">
        <div className="field grow">
          <label htmlFor="jq">{t('janazah.search')}</label>
          <input
            id="jq"
            type="search"
            placeholder={t('janazah.searchPh')}
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
        </div>
      </div>
      <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>{t('janazah.th.id')}</th>
              <th>{t('janazah.th.deceased')}</th>
              <th>{t('janazah.th.mosque')}</th>
              <th>{t('janazah.th.prayer')}</th>
              <th>{t('janazah.th.status')}</th>
              <th>{t('janazah.th.notes')}</th>
              <th aria-label={t('janazah.th.actions')} />
            </tr>
          </thead>
          <tbody>
            {filtered.map((j) => (
              <tr key={j.id}>
                <td className="mono">{j.id}</td>
                <td>{loc(j.deceasedName, j.deceasedNameAr)}</td>
                <td>{loc(j.mosqueName, j.mosqueNameAr)}</td>
                <td className="muted small">{formatDate(j.prayerAt)}</td>
                <td>
                  <select
                    className="select-inline"
                    value={j.status}
                    onChange={(e) => updateJanazahStatus(j.id, e.target.value as JanazahStatus)}
                    aria-label={`${t('janazah.th.status')} ${j.id}`}
                  >
                    {STATUS_OPTS.map((s) => (
                      <option key={s} value={s}>
                        {statusLabel(s)}
                      </option>
                    ))}
                  </select>
                </td>
                <td className="detail-cell small">
                  {j.notes != null && j.notes !== '' ? loc(j.notes, j.notesAr) : t('common.emDash')}
                </td>
                <td>
                  <button
                    type="button"
                    className="btn btn-ghost btn-sm"
                    onClick={() => {
                      if (!window.confirm(t('janazah.confirmDelete'))) return;
                      deleteJanazah(j.id);
                    }}
                  >
                    {t('janazah.delete')}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <p className="empty">{t('janazah.empty')}</p>}
      </div>
    </div>
  );
}

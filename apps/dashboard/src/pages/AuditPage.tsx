import { useMemo, useState } from 'react';
import { useDashboard } from '../context/DashboardContext';
import { useI18n, useLocalizedText } from '../i18n';
import { formatDate } from '../utils/ids';

export function AuditPage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { auditLog } = useDashboard();
  const [q, setQ] = useState('');

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    if (!term) return auditLog;
    return auditLog.filter((a) => {
      const hay = `${a.action} ${a.actionAr ?? ''} ${a.detail} ${a.detailAr ?? ''} ${a.actor} ${a.actorAr ?? ''}`.toLowerCase();
      return hay.includes(term);
    });
  }, [auditLog, q]);

  return (
    <div className="stack">
      <p className="lead">{t('audit.lead')}</p>
      <div className="toolbar">
        <div className="field grow">
          <label htmlFor="aq">{t('audit.filter')}</label>
          <input
            id="aq"
            type="search"
            placeholder={t('audit.filterPh')}
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
        </div>
      </div>
      <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>{t('audit.th.timestamp')}</th>
              <th>{t('audit.th.action')}</th>
              <th>{t('audit.th.detail')}</th>
              <th>{t('audit.th.actor')}</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((a) => (
              <tr key={a.id}>
                <td className="mono muted small">{formatDate(a.timestamp)}</td>
                <td>{loc(a.action, a.actionAr)}</td>
                <td className="detail-cell">{loc(a.detail, a.detailAr)}</td>
                <td className="muted">{loc(a.actor, a.actorAr)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <p className="empty">{t('audit.empty')}</p>}
      </div>
    </div>
  );
}

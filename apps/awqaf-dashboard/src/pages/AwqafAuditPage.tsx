import { useMemo, useState } from 'react';
import { useAwqafApp } from '../context/AwqafAppContext';
import { useI18n, useLocalizedText } from '../i18n';
import { formatDate } from '../utils/ids';

const OPS_AUDIT_URL = `${import.meta.env.VITE_OPS_DASHBOARD_URL ?? 'http://localhost:5173'}/audit`;

export function AwqafAuditPage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { filteredAudit } = useAwqafApp();
  const [q, setQ] = useState('');

  const rows = useMemo(() => {
    const term = q.trim().toLowerCase();
    if (!term) return filteredAudit;
    return filteredAudit.filter((a) => {
      const hay = `${a.action} ${a.actionAr ?? ''} ${a.detail} ${a.detailAr ?? ''} ${a.actor} ${a.actorAr ?? ''}`.toLowerCase();
      return hay.includes(term);
    });
  }, [filteredAudit, q]);

  return (
    <div className="stack">
      <p className="lead">
        {t('audit.leadBefore')}
        <a href={OPS_AUDIT_URL}>{t('audit.lead.link')}</a>
        {t('audit.leadAfter')}
      </p>
      <div className="toolbar">
        <div className="field grow">
          <label htmlFor="af">{t('audit.filter')}</label>
          <input
            id="af"
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
              <th>{t('audit.th.time')}</th>
              <th>{t('audit.th.action')}</th>
              <th>{t('audit.th.detail')}</th>
              <th>{t('audit.th.actor')}</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((a) => (
              <tr key={a.id}>
                <td className="mono muted small">{formatDate(a.timestamp)}</td>
                <td>{loc(a.action, a.actionAr)}</td>
                <td className="detail-cell">{loc(a.detail, a.detailAr)}</td>
                <td className="muted">{loc(a.actor, a.actorAr)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {rows.length === 0 && <p className="empty">{t('audit.empty')}</p>}
      </div>
    </div>
  );
}

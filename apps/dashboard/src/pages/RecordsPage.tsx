import { useMemo, useState } from 'react';
import { useDashboard } from '../context/DashboardContext';
import { useI18n, useLocalizedText } from '../i18n';

export function RecordsPage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { deceasedRecords } = useDashboard();
  const [q, setQ] = useState('');

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    if (!term) return deceasedRecords;
    return deceasedRecords.filter((d) => {
      const hay = `${d.fullName} ${d.fullNameAr ?? ''} ${d.id} ${d.section} ${d.plot} ${d.branchOfService ?? ''} ${d.branchOfServiceAr ?? ''}`.toLowerCase();
      return hay.includes(term);
    });
  }, [deceasedRecords, q]);

  return (
    <div className="stack">
      <p className="lead">{t('records.lead')}</p>
      <div className="toolbar">
        <div className="field grow">
          <label htmlFor="rq">{t('records.search')}</label>
          <input
            id="rq"
            type="search"
            placeholder={t('records.searchPh')}
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
        </div>
      </div>
      <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>{t('records.th.id')}</th>
              <th>{t('records.th.name')}</th>
              <th>{t('records.th.section')}</th>
              <th>{t('records.th.plot')}</th>
              <th>{t('records.th.deathYear')}</th>
              <th>{t('records.th.veteran')}</th>
              <th>{t('records.th.branch')}</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((d) => (
              <tr key={d.id}>
                <td className="mono">{d.id}</td>
                <td>{loc(d.fullName, d.fullNameAr)}</td>
                <td>{d.section}</td>
                <td>{d.plot}</td>
                <td>{d.deathYear}</td>
                <td>{d.isVeteran ? t('records.yes') : t('records.dash')}</td>
                <td className="muted small">
                  {d.branchOfService != null && d.branchOfService !== ''
                    ? loc(d.branchOfService, d.branchOfServiceAr)
                    : t('records.dash')}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <p className="empty">{t('records.empty')}</p>}
      </div>
    </div>
  );
}

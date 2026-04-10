import { Link } from 'react-router-dom';
import { useDashboard } from '../context/DashboardContext';
import { useI18n, useLocalizedText } from '../i18n';
import type { DashKey } from '../i18n';
import { formatDate } from '../utils/ids';

const AWQAF_APP_URL = import.meta.env.VITE_AWQAF_DASHBOARD_URL ?? 'http://localhost:5174';

function catKey(c: string): DashKey {
  return `ticketCategory.${c}` as DashKey;
}

export function OverviewPage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { ticketCounts, stats, auditLog, tickets } = useDashboard();

  const recentTickets = tickets.slice(0, 5);
  const recentAudit = auditLog.slice(0, 6);

  function statusLabel(status: string) {
    const key = `ticketStatus.${status}` as DashKey;
    return t(key);
  }

  return (
    <div className="stack">
      <p className="lead">{t('overview.lead')}</p>

      <div className="kpi-grid">
        <div className="kpi-card">
          <div className="kpi-label">{t('overview.kpi.open')}</div>
          <div className="kpi-value">{ticketCounts.open}</div>
          <Link to="/maintenance" className="kpi-link">
            {t('overview.viewQueue')} →
          </Link>
        </div>
        <div className="kpi-card">
          <div className="kpi-label">{t('overview.kpi.progress')}</div>
          <div className="kpi-value">{ticketCounts.inProgress}</div>
        </div>
        <div className="kpi-card">
          <div className="kpi-label">{t('overview.kpi.resolved')}</div>
          <div className="kpi-value">{ticketCounts.resolved}</div>
        </div>
        <div className="kpi-card kpi-accent">
          <div className="kpi-label">{t('overview.kpi.awqaf')}</div>
          <div className="kpi-value">{ticketCounts.awqafPriority}</div>
          <span className="kpi-hint">{t('overview.kpi.awqafHint')}</span>
          <a href={AWQAF_APP_URL} className="kpi-link" target="_blank" rel="noreferrer">
            {t('overview.openAwqaf')} →
          </a>
        </div>
      </div>

      <div className="two-col">
        <section className="panel">
          <h3 className="panel-title">{t('overview.metricsTitle')}</h3>
          <div className="metric-row">
            <span>{t('overview.recordedToday')}</span>
            <strong>{stats.deceasedToday}</strong>
          </div>
          <div className="metric-row">
            <span>{t('overview.thisMonth')}</span>
            <strong>{stats.deceasedThisMonth}</strong>
          </div>
          <Link to="/stats" className="btn btn-sm btn-primary" style={{ marginTop: 12 }}>
            {t('overview.openStats')}
          </Link>
        </section>

        <section className="panel">
          <h3 className="panel-title">{t('overview.recentMaint')}</h3>
          <ul className="mini-list">
            {recentTickets.map((x) => (
              <li key={x.id}>
                <span className="mono">{x.id}</span>
                <span>{t(catKey(x.category))}</span>
                <span className={`badge badge-${x.status}`}>{statusLabel(x.status)}</span>
                {x.highPriorityAwqaf && <span className="badge badge-awqaf">{t('badge.awqaf')}</span>}
              </li>
            ))}
          </ul>
          <Link to="/maintenance" className="btn btn-sm btn-secondary" style={{ marginTop: 8 }}>
            {t('overview.fullMaint')}
          </Link>
        </section>
      </div>

      <section className="panel">
        <h3 className="panel-title">{t('overview.recentAudit')}</h3>
        <table className="table compact">
          <thead>
            <tr>
              <th>{t('overview.th.time')}</th>
              <th>{t('overview.th.action')}</th>
              <th>{t('overview.th.detail')}</th>
              <th>{t('overview.th.actor')}</th>
            </tr>
          </thead>
          <tbody>
            {recentAudit.map((a) => (
              <tr key={a.id}>
                <td className="mono muted">{formatDate(a.timestamp)}</td>
                <td>{loc(a.action, a.actionAr)}</td>
                <td>{loc(a.detail, a.detailAr)}</td>
                <td className="muted">{loc(a.actor, a.actorAr)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <Link to="/audit" className="btn btn-sm btn-secondary" style={{ marginTop: 12 }}>
          {t('overview.fullAudit')}
        </Link>
      </section>
    </div>
  );
}

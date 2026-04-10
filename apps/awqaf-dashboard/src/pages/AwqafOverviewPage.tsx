import { Link } from 'react-router-dom';
import { useAwqafApp } from '../context/AwqafAppContext';
import { useI18n } from '../i18n';

const OPS = import.meta.env.VITE_OPS_DASHBOARD_URL ?? 'http://localhost:5173';

export function AwqafOverviewPage() {
  const { t } = useI18n();
  const { janazah, ghuslTasks, guidance, complianceCases } = useAwqafApp();

  const upcomingJanazah = janazah.filter((j) => j.status === 'scheduled').length;
  const activeGhusl = ghuslTasks.filter((g) => g.status !== 'done').length;
  const openGuidance = guidance.filter((g) => g.status !== 'answered').length;
  const openCompliance = complianceCases.filter((c) => c.status !== 'closed').length;

  return (
    <div className="stack">
      <p className="lead">
        {t('overview.leadBeforeLink')}
        <a href={OPS} target="_blank" rel="noreferrer">
          {t('overview.lead.ops')}
        </a>
        {t('overview.leadAfterLink')}
      </p>

      <div className="kpi-grid">
        <div className="kpi-card kpi-accent">
          <div className="kpi-label">{t('overview.kpi.janazah')}</div>
          <div className="kpi-value">{upcomingJanazah}</div>
          <Link to="/janazah" className="kpi-link">
            {t('overview.link.janazah')} →
          </Link>
        </div>
        <div className="kpi-card">
          <div className="kpi-label">{t('overview.kpi.ghusl')}</div>
          <div className="kpi-value">{activeGhusl}</div>
          <Link to="/ghusl" className="kpi-link">
            {t('overview.link.ghusl')} →
          </Link>
        </div>
        <div className="kpi-card">
          <div className="kpi-label">{t('overview.kpi.guidance')}</div>
          <div className="kpi-value">{openGuidance}</div>
          <Link to="/guidance" className="kpi-link">
            {t('overview.link.guidance')} →
          </Link>
        </div>
        <div className="kpi-card">
          <div className="kpi-label">{t('overview.kpi.compliance')}</div>
          <div className="kpi-value">{openCompliance}</div>
          <Link to="/compliance" className="kpi-link">
            {t('overview.link.compliance')} →
          </Link>
        </div>
      </div>

      <section className="panel">
        <h3 className="panel-title">{t('overview.diffTitle')}</h3>
        <ul className="bullets">
          <li>{t('overview.diff1')}</li>
          <li>{t('overview.diff2')}</li>
        </ul>
      </section>
    </div>
  );
}

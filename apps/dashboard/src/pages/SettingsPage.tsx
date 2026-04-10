import { useDashboard } from '../context/DashboardContext';
import { useI18n } from '../i18n';

export function SettingsPage() {
  const { t } = useI18n();
  const { resetDemoData, tickets, auditLog, stats, awqafCases } = useDashboard();

  function downloadBackup() {
    const payload = {
      exportedAt: new Date().toISOString(),
      tickets,
      auditLog,
      stats,
      awqafCases,
    };
    const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `sanad-dashboard-backup-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(a.href);
  }

  return (
    <div className="stack">
      <section className="panel">
        <h3 className="panel-title">{t('settings.dataTitle')}</h3>
        <p className="muted">{t('settings.dataBody')}</p>
        <div className="btn-row" style={{ marginTop: 16 }}>
          <button type="button" className="btn btn-secondary" onClick={downloadBackup}>
            {t('settings.backup')}
          </button>
          <button
            type="button"
            className="btn btn-danger"
            onClick={() => {
              if (window.confirm(t('settings.resetConfirm'))) resetDemoData();
            }}
          >
            {t('settings.reset')}
          </button>
        </div>
      </section>

      <section className="panel">
        <h3 className="panel-title">{t('settings.nextTitle')}</h3>
        <ul className="bullets">
          <li>{t('settings.next1')}</li>
          <li>{t('settings.next2')}</li>
          <li>{t('settings.next3')}</li>
          <li>{t('settings.next4')}</li>
        </ul>
      </section>
    </div>
  );
}

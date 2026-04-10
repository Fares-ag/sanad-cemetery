import { useMemo } from 'react';
import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { useAwqafAuth } from '../context/AwqafAuthContext';
import { LanguageToggle, useI18n } from '../i18n';
import type { AwqafKey } from '../i18n';

const OPS_DASHBOARD_URL = import.meta.env.VITE_OPS_DASHBOARD_URL ?? 'http://localhost:5173';

const baseDefs: Array<{ to: string; labelKey: AwqafKey; end?: boolean }> = [
  { to: '/', labelKey: 'nav.overview', end: true },
  { to: '/janazah', labelKey: 'nav.janazah' },
  { to: '/ghusl', labelKey: 'nav.ghusl' },
  { to: '/guidance', labelKey: 'nav.guidance' },
  { to: '/compliance', labelKey: 'nav.compliance' },
  { to: '/audit', labelKey: 'nav.audit' },
];

export function AwqafLayout() {
  const { logout, currentUser, canManageUsers } = useAwqafAuth();
  const { t, isRtl } = useI18n();

  const links = useMemo(() => {
    const withUsers = canManageUsers
      ? [...baseDefs.slice(0, -1), { to: '/users', labelKey: 'nav.users' as const }, baseDefs[baseDefs.length - 1]]
      : baseDefs;
    return withUsers.map((l) => ({ ...l, label: t(l.labelKey) }));
  }, [canManageUsers, t]);

  const loc = useLocation();
  const title =
    links.find((l) =>
      l.end ? loc.pathname === '/' : loc.pathname === l.to || loc.pathname.startsWith(`${l.to}/`),
    )?.label ?? t('nav.overview');

  return (
    <div className="dash-shell awqaf-dash" dir={isRtl ? 'rtl' : 'ltr'}>
      <aside className="dash-sidebar awqaf-sidebar">
        <div className="dash-brand">
          <div className="dash-brand-mark awqaf-brand-mark">A</div>
          <div>
            <div className="dash-brand-title">{t('brand.title')}</div>
            <div className="dash-brand-sub">{t('brand.sub')}</div>
          </div>
        </div>
        <nav className="dash-nav">
          {links.map((l) => (
            <NavLink
              key={l.to}
              to={l.to}
              end={l.end}
              className={({ isActive }) => 'dash-nav-link' + (isActive ? ' active' : '')}
            >
              {l.label}
            </NavLink>
          ))}
        </nav>
        <div className="dash-sidebar-foot">
          <a href={OPS_DASHBOARD_URL} className="awqaf-back-link">
            {t('layout.opsLink')}
          </a>
          <span className="dash-muted">{t('layout.demoFoot')}</span>
          {currentUser ? (
            <span className="dash-muted" style={{ fontSize: '0.72rem' }}>
              {t('layout.signedIn')} {currentUser.displayName}
            </span>
          ) : null}
        </div>
      </aside>
      <div className="dash-content">
        <header
          className="dash-topbar awqaf-topbar"
          style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '1rem', flexWrap: 'wrap' }}
        >
          <h2 className="dash-page-title" style={{ margin: 0 }}>
            {title}
          </h2>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', flexWrap: 'wrap' }}>
            <LanguageToggle />
            <button type="button" className="btn btn-secondary btn-sm" onClick={() => logout()}>
              {t('layout.signOut')}
            </button>
          </div>
        </header>
        <div className="dash-page">
          <Outlet />
        </div>
      </div>
    </div>
  );
}

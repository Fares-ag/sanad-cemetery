import { useMemo } from 'react';
import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { LanguageToggle, useI18n } from '../i18n';
import type { DashKey } from '../i18n';

const AWQAF_APP_URL = import.meta.env.VITE_AWQAF_DASHBOARD_URL ?? 'http://localhost:5174';

export function Layout() {
  const { logout, currentUser, canManageUsers } = useAuth();
  const { t, isRtl } = useI18n();

  const links = useMemo(() => {
    const base: Array<{ to: string; labelKey: DashKey; end?: boolean }> = [
      { to: '/', labelKey: 'nav.overview', end: true },
      { to: '/maintenance', labelKey: 'nav.maintenance' },
      { to: '/stats', labelKey: 'nav.statistics' },
      { to: '/records', labelKey: 'nav.records' },
      { to: '/content', labelKey: 'nav.content' },
      { to: '/audit', labelKey: 'nav.audit' },
      { to: '/settings', labelKey: 'nav.settings' },
    ];
    const withUsers = canManageUsers
      ? [...base.slice(0, -1), { to: '/users', labelKey: 'nav.users' as const }, base[base.length - 1]]
      : base;
    return withUsers.map((l) => ({ ...l, label: t(l.labelKey) }));
  }, [canManageUsers, t]);

  const loc = useLocation();
  const title =
    links.find((l) =>
      l.end ? loc.pathname === '/' : loc.pathname === l.to || loc.pathname.startsWith(`${l.to}/`),
    )?.label ?? t('nav.overview');

  return (
    <div className="dash-shell" dir={isRtl ? 'rtl' : 'ltr'}>
      <aside className="dash-sidebar">
        <div className="dash-brand">
          <div className="dash-brand-mark">S</div>
          <div>
            <div className="dash-brand-title">{t('brand.title')}</div>
            <div className="dash-brand-sub">{t('brand.sub')}</div>
          </div>
        </div>
        <nav className="dash-nav">
          {links.map((l) => (
            <NavLink key={l.to} to={l.to} end={l.end} className={({ isActive }) => 'dash-nav-link' + (isActive ? ' active' : '')}>
              {l.label}
            </NavLink>
          ))}
        </nav>
        <div className="dash-sidebar-foot">
          <a href={AWQAF_APP_URL} className="awqaf-portal-link" target="_blank" rel="noreferrer">
            {t('layout.awqafLink')}
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
          className="dash-topbar"
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

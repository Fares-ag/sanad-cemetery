import { useState } from 'react';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { LanguageToggle, useI18n } from '../i18n';

export function LoginPage() {
  const { login, currentUser } = useAuth();
  const { t } = useI18n();
  const navigate = useNavigate();
  const loc = useLocation();
  const from = (loc.state as { from?: string } | null)?.from ?? '/';

  const [email, setEmail] = useState('admin@sanad.local');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  if (currentUser) {
    return <Navigate to={from === '/login' ? '/' : from} replace />;
  }

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    const ok = login(email.trim(), password);
    if (!ok) {
      setError(t('login.error'));
      return;
    }
    navigate(from === '/login' ? '/' : from, { replace: true });
  }

  return (
    <div className="dash-shell" style={{ minHeight: '100vh' }}>
      <div className="dash-content" style={{ justifyContent: 'center' }}>
        <div className="dash-page" style={{ maxWidth: 440, margin: '0 auto', paddingTop: '4rem' }}>
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '0.75rem' }}>
            <LanguageToggle />
          </div>
          <div className="panel">
            <h1 className="panel-title" style={{ marginTop: 0 }}>
              {t('login.title')}
            </h1>
            <p className="lead" style={{ marginBottom: '1.25rem' }}>
              {t('login.lead')}
            </p>
            <form onSubmit={onSubmit} className="stack" style={{ gap: '1rem' }}>
              {error ? (
                <p className="small" style={{ color: '#b91c1c', margin: 0 }}>
                  {error}
                </p>
              ) : null}
              <div className="field">
                <label htmlFor="email">{t('login.email')}</label>
                <input
                  id="email"
                  type="email"
                  autoComplete="username"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label htmlFor="pw">{t('login.password')}</label>
                <input
                  id="pw"
                  type="password"
                  autoComplete="current-password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
              <div className="form-actions" style={{ justifyContent: 'stretch' }}>
                <button type="submit" className="btn btn-primary" style={{ width: '100%' }}>
                  {t('login.submit')}
                </button>
              </div>
            </form>
            <p className="small muted" style={{ marginTop: '1.25rem', marginBottom: 0 }}>
              {t('login.hint')}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

import { useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { DEMO_ROLES, type DashboardRole } from '../types';
import { useI18n } from '../i18n';
import type { DashKey } from '../i18n';
import { formatDate } from '../utils/ids';

export function UsersPage() {
  const { t } = useI18n();
  const { currentUser, canManageUsers, users, createUser, deleteUser, updateUser } = useAuth();

  const [email, setEmail] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [role, setRole] = useState<DashboardRole>('municipality_crew');
  const [password, setPassword] = useState('');
  const [msgKey, setMsgKey] = useState<DashKey | null>(null);

  if (!currentUser || !canManageUsers) {
    return <Navigate to="/" replace />;
  }

  function roleLabel(r: string) {
    return t(`role.${r}` as DashKey);
  }

  function add(e: React.FormEvent) {
    e.preventDefault();
    setMsgKey(null);
    const ok = createUser({
      email,
      displayName,
      role,
      password,
    });
    if (!ok) {
      setMsgKey('users.msg.duplicate');
      return;
    }
    setEmail('');
    setDisplayName('');
    setPassword('');
    setRole('municipality_crew');
    setMsgKey('users.msg.created');
  }

  return (
    <div className="stack">
      <p className="lead">{t('users.lead')}</p>

      {msgKey ? (
        <p className="small" style={{ margin: 0 }}>
          {t(msgKey)}
        </p>
      ) : null}

      <section className="panel">
        <h3 className="panel-title">{t('users.addTitle')}</h3>
        <form onSubmit={add} className="form-grid">
          <div className="field">
            <label htmlFor="nu-email">{t('users.email')}</label>
            <input id="nu-email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          </div>
          <div className="field">
            <label htmlFor="nu-name">{t('users.displayName')}</label>
            <input id="nu-name" value={displayName} onChange={(e) => setDisplayName(e.target.value)} required />
          </div>
          <div className="field">
            <label htmlFor="nu-role">{t('users.role')}</label>
            <select id="nu-role" value={role} onChange={(e) => setRole(e.target.value as DashboardRole)}>
              {DEMO_ROLES.map((r) => (
                <option key={r} value={r}>
                  {roleLabel(r)}
                </option>
              ))}
            </select>
          </div>
          <div className="field">
            <label htmlFor="nu-pw">{t('users.password')}</label>
            <input
              id="nu-pw"
              type="password"
              autoComplete="new-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <div className="form-actions full">
            <button type="submit" className="btn btn-primary">
              {t('users.create')}
            </button>
          </div>
        </form>
      </section>

      <section className="panel">
        <h3 className="panel-title">
          {t('users.accounts')} ({users.length})
        </h3>
        <div className="table-wrap">
          <table className="table compact">
            <thead>
              <tr>
                <th>{t('users.th.email')}</th>
                <th>{t('users.th.name')}</th>
                <th>{t('users.th.role')}</th>
                <th>{t('users.th.created')}</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {users.map((u) => (
                <tr key={u.id}>
                  <td className="mono small">{u.email}</td>
                  <td>{u.displayName}</td>
                  <td>
                    <select
                      className="select-inline"
                      value={u.role}
                      onChange={(e) => updateUser(u.id, { role: e.target.value as DashboardRole })}
                      aria-label={`${t('users.role')}: ${u.email}`}
                    >
                      {DEMO_ROLES.map((r) => (
                        <option key={r} value={r}>
                          {roleLabel(r)}
                        </option>
                      ))}
                    </select>
                  </td>
                  <td className="muted small">{formatDate(u.createdAt)}</td>
                  <td>
                    <button
                      type="button"
                      className="btn btn-ghost btn-sm"
                      disabled={u.id === currentUser.id}
                      onClick={() => {
                        if (window.confirm(`${t('users.remove')} ${u.email}?`)) deleteUser(u.id);
                      }}
                    >
                      {t('users.remove')}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

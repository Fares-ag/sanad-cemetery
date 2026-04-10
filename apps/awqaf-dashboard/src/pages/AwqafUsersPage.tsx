import { useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useAwqafAuth } from '../context/AwqafAuthContext';
import { AWQAF_ACCOUNT_ROLES, type AwqafAccountRole } from '../types';
import { useI18n } from '../i18n';
import type { AwqafKey } from '../i18n';
import { formatDate } from '../utils/ids';

export function AwqafUsersPage() {
  const { t } = useI18n();
  const { currentUser, canManageUsers, users, createUser, deleteUser, updateUser } = useAwqafAuth();

  const [email, setEmail] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [role, setRole] = useState<AwqafAccountRole>('staff');
  const [password, setPassword] = useState('');
  const [msgKey, setMsgKey] = useState<AwqafKey | null>(null);

  if (!currentUser || !canManageUsers) {
    return <Navigate to="/" replace />;
  }

  function roleLabel(r: string) {
    return t(`awqafRole.${r}` as AwqafKey);
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
    setRole('staff');
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
            <label htmlFor="a-email">{t('users.email')}</label>
            <input id="a-email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          </div>
          <div className="field">
            <label htmlFor="a-name">{t('users.displayName')}</label>
            <input id="a-name" value={displayName} onChange={(e) => setDisplayName(e.target.value)} required />
          </div>
          <div className="field">
            <label htmlFor="a-role">{t('users.role')}</label>
            <select id="a-role" value={role} onChange={(e) => setRole(e.target.value as AwqafAccountRole)}>
              {AWQAF_ACCOUNT_ROLES.map((r) => (
                <option key={r} value={r}>
                  {roleLabel(r)}
                </option>
              ))}
            </select>
          </div>
          <div className="field">
            <label htmlFor="a-pw">{t('users.password')}</label>
            <input
              id="a-pw"
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
                      onChange={(e) => updateUser(u.id, { role: e.target.value as AwqafAccountRole })}
                      aria-label={`${t('users.role')}: ${u.email}`}
                    >
                      {AWQAF_ACCOUNT_ROLES.map((r) => (
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

import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import type { DashboardRole, DashboardUserAccount } from '../types';
import { newId } from '../utils/ids';
import { loadJson, saveJson } from '../utils/storage';

const K_USERS = 'sanad_dash_user_accounts';
const K_SESSION = 'sanad_dash_session_user_id';

const MANAGER_ROLES: DashboardRole[] = ['admin', 'super_admin'];

function seedUsers(): DashboardUserAccount[] {
  return [
    {
      id: 'usr_seed_1',
      email: 'admin@sanad.local',
      displayName: 'System administrator',
      role: 'super_admin',
      password: 'admin',
      createdAt: new Date().toISOString(),
    },
  ];
}

function loadUsersInitial(): DashboardUserAccount[] {
  const u = loadJson<DashboardUserAccount[] | null>(K_USERS, null);
  if (!u || u.length === 0) {
    const seed = seedUsers();
    saveJson(K_USERS, seed);
    return seed;
  }
  return u;
}

export interface AuthValue {
  users: DashboardUserAccount[];
  currentUser: DashboardUserAccount | null;
  login: (email: string, password: string) => boolean;
  logout: () => void;
  createUser: (input: {
    email: string;
    displayName: string;
    role: DashboardRole;
    password: string;
  }) => boolean;
  deleteUser: (id: string) => void;
  updateUser: (
    id: string,
    patch: Partial<Pick<DashboardUserAccount, 'displayName' | 'role' | 'password'>>,
  ) => void;
  canManageUsers: boolean;
}

const AuthContext = createContext<AuthValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [users, setUsers] = useState<DashboardUserAccount[]>(() => loadUsersInitial());
  const [sessionUserId, setSessionUserId] = useState<string | null>(() =>
    typeof window !== 'undefined' ? localStorage.getItem(K_SESSION) : null,
  );

  const persistUsers = useCallback((next: DashboardUserAccount[]) => {
    setUsers(next);
    saveJson(K_USERS, next);
  }, []);

  const currentUser = useMemo(
    () => (sessionUserId ? users.find((u) => u.id === sessionUserId) ?? null : null),
    [users, sessionUserId],
  );

  const login = useCallback(
    (email: string, password: string) => {
      const e = email.trim().toLowerCase();
      const u = users.find((x) => x.email.toLowerCase() === e);
      if (!u || u.password !== password) return false;
      setSessionUserId(u.id);
      localStorage.setItem(K_SESSION, u.id);
      return true;
    },
    [users],
  );

  const logout = useCallback(() => {
    setSessionUserId(null);
    localStorage.removeItem(K_SESSION);
  }, []);

  const createUser = useCallback(
    (input: {
      email: string;
      displayName: string;
      role: DashboardRole;
      password: string;
    }) => {
      const email = input.email.trim().toLowerCase();
      if (users.some((x) => x.email.toLowerCase() === email)) return false;
      const nu: DashboardUserAccount = {
        id: newId('usr'),
        email,
        displayName: input.displayName.trim() || email,
        role: input.role,
        password: input.password,
        createdAt: new Date().toISOString(),
      };
      persistUsers([...users, nu]);
      return true;
    },
    [users, persistUsers],
  );

  const deleteUser = useCallback(
    (id: string) => {
      if (id === sessionUserId) return;
      const next = users.filter((u) => u.id !== id);
      if (next.length === 0) return;
      persistUsers(next);
    },
    [users, persistUsers, sessionUserId],
  );

  const updateUser = useCallback(
    (id: string, patch: Partial<Pick<DashboardUserAccount, 'displayName' | 'role' | 'password'>>) => {
      persistUsers(
        users.map((u) => {
          if (u.id !== id) return u;
          const { password: pw, ...rest } = patch;
          return {
            ...u,
            ...rest,
            ...(pw !== undefined && pw !== '' ? { password: pw } : {}),
          };
        }),
      );
    },
    [users, persistUsers],
  );

  const canManageUsers = useMemo(
    () => !!currentUser && MANAGER_ROLES.includes(currentUser.role),
    [currentUser],
  );

  const value = useMemo<AuthValue>(
    () => ({
      users,
      currentUser,
      login,
      logout,
      createUser,
      deleteUser,
      updateUser,
      canManageUsers,
    }),
    [users, currentUser, login, logout, createUser, deleteUser, updateUser, canManageUsers],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}

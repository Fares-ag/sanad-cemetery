import { Navigate, useLocation } from 'react-router-dom';
import { useAwqafAuth } from '../context/AwqafAuthContext';

export function RequireAwqafAuth({ children }: { children: React.ReactNode }) {
  const { currentUser } = useAwqafAuth();
  const loc = useLocation();

  if (!currentUser) {
    return <Navigate to="/login" replace state={{ from: loc.pathname }} />;
  }

  return <>{children}</>;
}

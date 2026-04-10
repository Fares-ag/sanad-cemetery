import { Route, Routes } from 'react-router-dom';
import { Layout } from './components/Layout';
import { RequireAuth } from './components/RequireAuth';
import { OverviewPage } from './pages/OverviewPage';
import { MaintenancePage } from './pages/MaintenancePage';
import { StatisticsPage } from './pages/StatisticsPage';
import { RecordsPage } from './pages/RecordsPage';
import { AuditPage } from './pages/AuditPage';
import { SettingsPage } from './pages/SettingsPage';
import { LoginPage } from './pages/LoginPage';
import { UsersPage } from './pages/UsersPage';
import { ContentPage } from './pages/ContentPage';

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        element={
          <RequireAuth>
            <Layout />
          </RequireAuth>
        }
      >
        <Route path="/" element={<OverviewPage />} />
        <Route path="/maintenance" element={<MaintenancePage />} />
        <Route path="/stats" element={<StatisticsPage />} />
        <Route path="/records" element={<RecordsPage />} />
        <Route path="/content" element={<ContentPage />} />
        <Route path="/audit" element={<AuditPage />} />
        <Route path="/users" element={<UsersPage />} />
        <Route path="/settings" element={<SettingsPage />} />
      </Route>
    </Routes>
  );
}

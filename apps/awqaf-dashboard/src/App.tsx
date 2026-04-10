import { Route, Routes } from 'react-router-dom';
import { AwqafLayout } from './components/AwqafLayout';
import { RequireAwqafAuth } from './components/RequireAwqafAuth';
import { AwqafAuditPage } from './pages/AwqafAuditPage';
import { AwqafOverviewPage } from './pages/AwqafOverviewPage';
import { AwqafLoginPage } from './pages/AwqafLoginPage';
import { AwqafUsersPage } from './pages/AwqafUsersPage';
import { CompliancePage } from './pages/CompliancePage';
import { GhuslKafanPage } from './pages/GhuslKafanPage';
import { GuidancePage } from './pages/GuidancePage';
import { JanazahSchedulePage } from './pages/JanazahSchedulePage';

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<AwqafLoginPage />} />
      <Route
        path="/"
        element={
          <RequireAwqafAuth>
            <AwqafLayout />
          </RequireAwqafAuth>
        }
      >
        <Route index element={<AwqafOverviewPage />} />
        <Route path="janazah" element={<JanazahSchedulePage />} />
        <Route path="ghusl" element={<GhuslKafanPage />} />
        <Route path="guidance" element={<GuidancePage />} />
        <Route path="compliance" element={<CompliancePage />} />
        <Route path="users" element={<AwqafUsersPage />} />
        <Route path="audit" element={<AwqafAuditPage />} />
      </Route>
    </Routes>
  );
}

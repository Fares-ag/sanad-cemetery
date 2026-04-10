import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { AwqafAuthProvider } from './context/AwqafAuthContext';
import { AwqafAppProvider } from './context/AwqafAppContext';
import { I18nProvider } from './i18n';
import App from './App';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <I18nProvider>
        <AwqafAuthProvider>
          <AwqafAppProvider>
            <App />
          </AwqafAppProvider>
        </AwqafAuthProvider>
      </I18nProvider>
    </BrowserRouter>
  </StrictMode>,
);

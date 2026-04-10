/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Awqaf web app origin when split from ops dashboard (e.g. http://localhost:5174) */
  readonly VITE_AWQAF_DASHBOARD_URL: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
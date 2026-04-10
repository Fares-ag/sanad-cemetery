/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Municipality / operations dashboard origin (e.g. http://localhost:5173) */
  readonly VITE_OPS_DASHBOARD_URL: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

# Sanad — Ministry of Awqaf dashboard

Standalone app for **religious burial workflows** (not municipality cemetery operations).

## Features (demo data, local storage)

| Area | Purpose |
|------|---------|
| **Janazah & prayer** | Schedule funeral prayers, mosque, status — coordinates with burial timing (grave assignment is municipality). |
| **Ghusl & kafan** | Washing / shrouding facility tasks and status. |
| **Guidance** | Public questions on Islamic burial practice; add and triage requests. |
| **Compliance** | Complaints and religious-fine cases for Awqaf follow-up. |
| **Activity log** | Actions recorded in this app; link to full ops audit on the municipality dashboard. (Audit rows are append-only — no delete.) |

**CRUD:** Create + read + update + **delete** (with confirm) on Janazah, Ghusl, Guidance, and Compliance rows. Deletes are logged to the activity log.

Storage keys are **`sanad_awqaf_*`** (separate from the operations dashboard). Each dev port has its own browser storage.

## Scripts

```bash
npm install
npm run dev    # http://localhost:5174
npm run build
```

## Environment

```env
VITE_OPS_DASHBOARD_URL=http://localhost:5173
```

Run **municipality operations** on **5173** and this app on **5174**.

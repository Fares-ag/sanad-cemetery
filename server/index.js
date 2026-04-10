/**
 * Sanad public app content API — announcements + ministry headline stats for the mobile app.
 * Municipality dashboard reads/writes the same store (JSON file).
 */
import express from 'express';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { randomUUID } from 'crypto';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DATA_PATH = path.join(__dirname, 'data', 'app-content.json');

const SEED = {
  ministryStats: {
    deceasedToday: 3,
    deceasedThisMonth: 42,
    feedNote:
      'Figures below are published from the municipality dashboard (demo API). Replace this API with your production backend.',
    feedNoteAr:
      'الأرقام أدناه تُنشر من لوحة البلدية (واجهة تجريبية). استبدل هذه الواجهة بخادم الإنتاج.',
  },
  announcements: [
    {
      id: 'ann-001',
      name: 'Ahmed Khan',
      nameAr: 'أحمد خان',
      passedAwayDate: '2026-09-25',
      serviceType: 'funeral_prayers',
      serviceDateTime: '2026-09-28T11:00:00.000Z',
      burialLocation: 'Section B — Plot 14 · 25.1960, 51.4873',
      burialLocationAr: 'القطعة ب — قبر ١٤',
      iconKey: 'prayer',
      status: 'approved',
    },
    {
      id: 'ann-002',
      name: 'Mirza Khan',
      nameAr: 'ميرزا خان',
      passedAwayDate: '2026-09-20',
      serviceType: 'burial',
      serviceDateTime: '2026-09-22T13:00:00.000Z',
      burialLocation: 'Section A — Plot 22 · 25.1962, 51.4875',
      burialLocationAr: 'القطعة أ — قبر ٢٢',
      iconKey: 'burial',
      status: 'approved',
    },
  ],
  siteInfo: {
    openingHours: 'Sun–Thu 6:00–20:00 · Fri 12:00–20:00 · Sat 6:00–18:00',
    openingHoursAr: 'الأحد–الخميس ٦:٠٠–٢٠:٠٠ · الجمعة ١٢:٠٠–٢٠:٠٠ · السبت ٦:٠٠–١٨:٠٠',
    phone: '+974 0000 0000',
    website: 'https://www.gco.gov.qa',
  },
  /** Mobile app home hero: image URL (optional) + carousel lines + primary CTA labels */
  homeHero: {
    imageUrl: '',
    slides: [
      {
        text: 'Report visible issues at the cemetery',
        textAr: 'الإبلاغ عن مشاكل مرئية في المقبرة',
      },
      {
        text: 'Search cemetery and burial records',
        textAr: 'البحث في سجلات المقبرة والدفن',
      },
      {
        text: 'Navigate to a grave location',
        textAr: 'التوجيه إلى موقع قبر',
      },
      {
        text: 'Report sunken grave, damaged stone, or overgrown grass',
        textAr: 'الإبلاغ عن قبر هابط أو حجر تالف أو عشب متضخم',
      },
    ],
    reportCtaEn: 'Report a cemetery issue',
    reportCtaAr: 'إبلاغ عن مشكلة في المقبرة',
  },
};

function readStore() {
  if (!fs.existsSync(DATA_PATH)) {
    fs.mkdirSync(path.dirname(DATA_PATH), { recursive: true });
    fs.writeFileSync(DATA_PATH, JSON.stringify(SEED, null, 2), 'utf8');
  }
  const raw = fs.readFileSync(DATA_PATH, 'utf8');
  try {
    return JSON.parse(raw);
  } catch {
    fs.writeFileSync(DATA_PATH, JSON.stringify(SEED, null, 2), 'utf8');
    return structuredClone(SEED);
  }
}

function writeStore(data) {
  fs.mkdirSync(path.dirname(DATA_PATH), { recursive: true });
  fs.writeFileSync(DATA_PATH, JSON.stringify(data, null, 2), 'utf8');
}

/** Funeral prayers (janazah) vs burial time — legacy `funeral`/`memorial` are migrated here. */
function normalizeServiceType(raw) {
  const s = String(raw ?? 'funeral_prayers').toLowerCase();
  if (s === 'memorial' || s === 'burial') return 'burial';
  if (s === 'funeral' || s === 'funeral_prayers') return 'funeral_prayers';
  return 'funeral_prayers';
}

/** List icon — legacy `flower`/`celebration` migrated to `burial`/`prayer`. */
function normalizeIconKey(raw) {
  const s = String(raw ?? 'burial').toLowerCase();
  if (s === 'celebration' || s === 'prayer') return 'prayer';
  if (s === 'flower' || s === 'burial') return 'burial';
  return 'burial';
}

function resolveAnnouncementStatus(body, options) {
  if (options.statusOverride !== undefined) return options.statusOverride;
  if (body?.status === 'pending') return 'pending';
  if (body?.status === 'approved') return 'approved';
  return 'approved';
}

function normalizeAnnouncement(body, options = {}) {
  return {
    id: String(body?.id ?? randomUUID()),
    name: String(body?.name ?? '').trim() || '—',
    nameAr: body?.nameAr != null ? String(body.nameAr).trim() : undefined,
    passedAwayDate: String(body?.passedAwayDate ?? '').slice(0, 10),
    serviceType: normalizeServiceType(body?.serviceType),
    serviceDateTime: String(body?.serviceDateTime ?? new Date().toISOString()),
    burialLocation: String(body?.burialLocation ?? '').trim() || '—',
    burialLocationAr: body?.burialLocationAr != null ? String(body.burialLocationAr).trim() : undefined,
    iconKey: normalizeIconKey(body?.iconKey),
    status: resolveAnnouncementStatus(body, options),
  };
}

function announcementForPublic(a) {
  const n = normalizeAnnouncement({ ...a, status: a.status ?? 'approved' });
  if (n.status === 'pending') return null;
  const { status, ...rest } = n;
  return rest;
}

const app = express();
app.use(cors({ origin: true }));
app.use(express.json({ limit: '512kb' }));

app.get('/api/public/app-content', (_req, res) => {
  const store = readStore();
  const raw = store.announcements ?? [];
  const announcements = raw.map(announcementForPublic).filter(Boolean);
  res.json({
    ministryStats: store.ministryStats,
    announcements,
    siteInfo: store.siteInfo ?? {},
    homeHero: store.homeHero ?? SEED.homeHero,
  });
});

/** Full store including pending user submissions — municipality dashboard only. */
app.get('/api/content/managed-app-content', (_req, res) => {
  const store = readStore();
  const announcements = (store.announcements ?? []).map((a) =>
    normalizeAnnouncement({ ...a, status: a.status ?? 'approved' }),
  );
  res.json({
    ministryStats: store.ministryStats,
    announcements,
    siteInfo: store.siteInfo ?? {},
    homeHero: store.homeHero ?? SEED.homeHero,
  });
});

/** Mobile app: user-submitted announcement — pending until municipality approves in dashboard. */
app.post('/api/public/announcement-submissions', (req, res) => {
  const store = readStore();
  const ann = normalizeAnnouncement({ ...req.body, id: randomUUID() }, { statusOverride: 'pending' });
  store.announcements = [ann, ...(store.announcements ?? [])];
  writeStore(store);
  res.status(201).json({ ok: true, id: ann.id });
});

function normalizeHomeHero(body) {
  const slidesIn = Array.isArray(body?.slides) ? body.slides : [];
  const slides = slidesIn
    .slice(0, 8)
    .map((s) => ({
      text: String(s?.text ?? '').trim(),
      textAr: s?.textAr != null ? String(s.textAr).trim() : undefined,
    }))
    .filter((s) => s.text.length > 0);
  const rEn = typeof body?.reportCtaEn === 'string' ? body.reportCtaEn.trim() : '';
  const rAr = typeof body?.reportCtaAr === 'string' ? body.reportCtaAr.trim() : '';
  return {
    imageUrl: typeof body?.imageUrl === 'string' ? body.imageUrl.trim() : '',
    slides: slides.length > 0 ? slides : SEED.homeHero.slides,
    reportCtaEn: rEn || SEED.homeHero.reportCtaEn,
    reportCtaAr: rAr || SEED.homeHero.reportCtaAr,
  };
}

app.put('/api/content/home-hero', (req, res) => {
  const store = readStore();
  store.homeHero = normalizeHomeHero(req.body ?? {});
  writeStore(store);
  res.json({ ok: true, homeHero: store.homeHero });
});

app.put('/api/content/site-info', (req, res) => {
  const store = readStore();
  const b = req.body ?? {};
  store.siteInfo = {
    ...(store.siteInfo ?? {}),
    ...(typeof b.openingHours === 'string' ? { openingHours: b.openingHours } : {}),
    ...(typeof b.openingHoursAr === 'string' ? { openingHoursAr: b.openingHoursAr } : {}),
    ...(typeof b.phone === 'string' ? { phone: b.phone } : {}),
    ...(typeof b.website === 'string' ? { website: b.website } : {}),
  };
  writeStore(store);
  res.json({ ok: true, siteInfo: store.siteInfo });
});

app.put('/api/content/ministry-stats', (req, res) => {
  const store = readStore();
  const m = req.body ?? {};
  store.ministryStats = {
    ...store.ministryStats,
    ...(typeof m.deceasedToday === 'number' ? { deceasedToday: Math.max(0, Math.floor(m.deceasedToday)) } : {}),
    ...(typeof m.deceasedThisMonth === 'number'
      ? { deceasedThisMonth: Math.max(0, Math.floor(m.deceasedThisMonth)) }
      : {}),
    ...(typeof m.feedNote === 'string' ? { feedNote: m.feedNote } : {}),
    ...(typeof m.feedNoteAr === 'string' ? { feedNoteAr: m.feedNoteAr } : {}),
  };
  writeStore(store);
  res.json({ ok: true, ministryStats: store.ministryStats });
});

app.post('/api/content/announcements', (req, res) => {
  const store = readStore();
  const ann = normalizeAnnouncement({ ...req.body, id: randomUUID() }, { statusOverride: 'approved' });
  store.announcements = [ann, ...(store.announcements ?? [])];
  writeStore(store);
  res.status(201).json(ann);
});

app.patch('/api/content/announcements/:id', (req, res) => {
  const store = readStore();
  const i = (store.announcements ?? []).findIndex((a) => a.id === req.params.id);
  if (i < 0) return res.status(404).json({ error: 'not_found' });
  const merged = normalizeAnnouncement({ ...store.announcements[i], ...req.body, id: req.params.id });
  store.announcements[i] = merged;
  writeStore(store);
  res.json(merged);
});

app.delete('/api/content/announcements/:id', (req, res) => {
  const store = readStore();
  const before = (store.announcements ?? []).length;
  store.announcements = (store.announcements ?? []).filter((a) => a.id !== req.params.id);
  writeStore(store);
  res.json({ ok: true, deleted: before - (store.announcements ?? []).length });
});

app.get('/api/health', (_req, res) => {
  res.json({ ok: true, service: 'sanad-content-api' });
});

const PORT = Number(process.env.PORT ?? 3333);
app.listen(PORT, () => {
  console.log(`Sanad content API listening on http://127.0.0.1:${PORT}`);
});

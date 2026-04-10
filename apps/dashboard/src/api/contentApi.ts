/** Shared with server JSON shape — burial announcements + ministry headline for the mobile app. */

export type AnnouncementServiceType = 'funeral_prayers' | 'burial';
export type AnnouncementIconKey = 'prayer' | 'burial';
export type AnnouncementStatus = 'pending' | 'approved';

export interface AppAnnouncement {
  id: string;
  name: string;
  nameAr?: string;
  passedAwayDate: string;
  serviceType: AnnouncementServiceType | 'funeral' | 'memorial';
  serviceDateTime: string;
  burialLocation: string;
  burialLocationAr?: string;
  iconKey?: AnnouncementIconKey | 'celebration' | 'flower';
  status?: AnnouncementStatus;
}

export interface MinistryPublicStats {
  deceasedToday: number;
  deceasedThisMonth: number;
  feedNote?: string;
  feedNoteAr?: string;
}

export interface SiteInfo {
  openingHours?: string;
  openingHoursAr?: string;
  phone?: string;
  website?: string;
}

export interface HomeHeroSlide {
  text: string;
  textAr?: string;
}

export interface HomeHeroConfig {
  imageUrl: string;
  slides: HomeHeroSlide[];
  reportCtaEn: string;
  reportCtaAr: string;
}

export interface AppContentPayload {
  ministryStats: MinistryPublicStats;
  announcements: AppAnnouncement[];
  siteInfo?: SiteInfo;
  homeHero?: HomeHeroConfig;
}

async function parseJson(res: Response) {
  if (!res.ok) throw new Error(`http_${res.status}`);
  return res.json();
}

export async function fetchPublicAppContent(): Promise<AppContentPayload> {
  const r = await fetch('/api/public/app-content');
  return parseJson(r) as Promise<AppContentPayload>;
}

/** Municipality dashboard: includes pending user submissions (not shown in the mobile app until approved). */
export async function fetchManagedAppContent(): Promise<AppContentPayload> {
  const r = await fetch('/api/content/managed-app-content');
  return parseJson(r) as Promise<AppContentPayload>;
}

export async function postPublicAnnouncementSubmission(
  body: Omit<AppAnnouncement, 'id' | 'status'>,
): Promise<{ ok: boolean; id: string }> {
  const r = await fetch('/api/public/announcement-submissions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!r.ok) throw new Error(`http_${r.status}`);
  return parseJson(r) as Promise<{ ok: boolean; id: string }>;
}

/** Sync headline figures to the content API (called from Statistics save and dashboard reset). */
export async function pushMinistryHeadlineToApi(deceasedToday: number, deceasedThisMonth: number): Promise<void> {
  await putMinistryStats({ deceasedToday, deceasedThisMonth });
}

export async function putMinistryStats(patch: Partial<MinistryPublicStats>): Promise<MinistryPublicStats> {
  const r = await fetch('/api/content/ministry-stats', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(patch),
  });
  const j = (await parseJson(r)) as { ministryStats: MinistryPublicStats };
  return j.ministryStats;
}

export async function postAnnouncement(
  body: Omit<AppAnnouncement, 'id'>,
): Promise<AppAnnouncement> {
  const r = await fetch('/api/content/announcements', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  return parseJson(r) as Promise<AppAnnouncement>;
}

export async function patchAnnouncement(id: string, body: Partial<AppAnnouncement>): Promise<AppAnnouncement> {
  const r = await fetch(`/api/content/announcements/${encodeURIComponent(id)}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  return parseJson(r) as Promise<AppAnnouncement>;
}

export async function deleteAnnouncement(id: string): Promise<void> {
  const r = await fetch(`/api/content/announcements/${encodeURIComponent(id)}`, {
    method: 'DELETE',
  });
  if (!r.ok) throw new Error(`http_${r.status}`);
}

export async function putSiteInfo(patch: Partial<SiteInfo>): Promise<SiteInfo> {
  const r = await fetch('/api/content/site-info', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(patch),
  });
  const j = (await parseJson(r)) as { siteInfo: SiteInfo };
  return j.siteInfo;
}

export async function putHomeHero(body: HomeHeroConfig): Promise<HomeHeroConfig> {
  const r = await fetch('/api/content/home-hero', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const j = (await parseJson(r)) as { homeHero: HomeHeroConfig };
  return j.homeHero;
}

import { useCallback, useEffect, useState } from 'react';
import { useDashboard } from '../context/DashboardContext';
import { Modal } from '../components/Modal';
import { useI18n } from '../i18n';
import type {
  AppAnnouncement,
  AppContentPayload,
  HomeHeroConfig,
} from '../api/contentApi';
import {
  deleteAnnouncement,
  fetchManagedAppContent,
  patchAnnouncement,
  postAnnouncement,
  putHomeHero,
  putMinistryStats,
  putSiteInfo,
} from '../api/contentApi';

function isoToDatetimeLocal(iso: string): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function datetimeLocalToIso(s: string): string {
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? new Date().toISOString() : d.toISOString();
}

function formServiceTypeFromStored(a: AppAnnouncement): 'funeral_prayers' | 'burial' {
  const s = a.serviceType;
  if (s === 'memorial' || s === 'burial') return 'burial';
  return 'funeral_prayers';
}

function formIconKeyFromStored(a: AppAnnouncement): 'prayer' | 'burial' {
  const k = a.iconKey ?? 'burial';
  if (k === 'celebration' || k === 'prayer') return 'prayer';
  return 'burial';
}

function emptyForm(): Omit<AppAnnouncement, 'id'> {
  return {
    name: '',
    nameAr: '',
    passedAwayDate: new Date().toISOString().slice(0, 10),
    serviceType: 'funeral_prayers',
    serviceDateTime: new Date().toISOString(),
    burialLocation: '',
    burialLocationAr: '',
    iconKey: 'burial',
  };
}

export function ContentPage() {
  const { t } = useI18n();
  const { hydrateHeadlineFromContentApi } = useDashboard();
  const [loading, setLoading] = useState(true);
  const [apiDown, setApiDown] = useState(false);
  const [ministry, setMinistry] = useState({
    deceasedToday: 3,
    deceasedThisMonth: 42,
    feedNote: '',
    feedNoteAr: '',
  });
  const [announcements, setAnnouncements] = useState<AppAnnouncement[]>([]);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState<Omit<AppAnnouncement, 'id'>>(emptyForm);
  const [savingMinistry, setSavingMinistry] = useState(false);
  const [site, setSite] = useState({
    openingHours: '',
    openingHoursAr: '',
    phone: '',
    website: '',
  });
  const [savingSite, setSavingSite] = useState(false);
  const [homeHero, setHomeHero] = useState<HomeHeroConfig>({
    imageUrl: '',
    slides: [{ text: '', textAr: '' }],
    reportCtaEn: '',
    reportCtaAr: '',
  });
  const [savingHero, setSavingHero] = useState(false);

  const applyPayload = useCallback(
    (data: AppContentPayload) => {
      setMinistry({
        deceasedToday: data.ministryStats.deceasedToday,
        deceasedThisMonth: data.ministryStats.deceasedThisMonth,
        feedNote: data.ministryStats.feedNote ?? '',
        feedNoteAr: data.ministryStats.feedNoteAr ?? '',
      });
      setAnnouncements(data.announcements);
      const si = data.siteInfo;
      setSite({
        openingHours: si?.openingHours ?? '',
        openingHoursAr: si?.openingHoursAr ?? '',
        phone: si?.phone ?? '',
        website: si?.website ?? '',
      });
      if (data.homeHero) {
        const slides = data.homeHero.slides?.length
          ? data.homeHero.slides.map((s) => ({ text: s.text ?? '', textAr: s.textAr ?? '' }))
          : [{ text: '', textAr: '' }];
        setHomeHero({
          imageUrl: data.homeHero.imageUrl ?? '',
          slides,
          reportCtaEn: data.homeHero.reportCtaEn ?? '',
          reportCtaAr: data.homeHero.reportCtaAr ?? '',
        });
      }
      hydrateHeadlineFromContentApi(data.ministryStats.deceasedToday, data.ministryStats.deceasedThisMonth);
    },
    [hydrateHeadlineFromContentApi],
  );

  const load = useCallback(async () => {
    setLoading(true);
    setApiDown(false);
    try {
      const data = await fetchManagedAppContent();
      applyPayload(data);
    } catch {
      setApiDown(true);
    } finally {
      setLoading(false);
    }
  }, [applyPayload]);

  useEffect(() => {
    void load();
  }, [load]);

  async function saveMinistry(e: React.FormEvent) {
    e.preventDefault();
    setSavingMinistry(true);
    try {
      await putMinistryStats({
        deceasedToday: ministry.deceasedToday,
        deceasedThisMonth: ministry.deceasedThisMonth,
        feedNote: ministry.feedNote,
        feedNoteAr: ministry.feedNoteAr,
      });
      hydrateHeadlineFromContentApi(ministry.deceasedToday, ministry.deceasedThisMonth);
    } catch {
      setApiDown(true);
    } finally {
      setSavingMinistry(false);
    }
  }

  async function saveSiteInfo(e: React.FormEvent) {
    e.preventDefault();
    setSavingSite(true);
    try {
      await putSiteInfo({
        openingHours: site.openingHours,
        openingHoursAr: site.openingHoursAr,
        phone: site.phone,
        website: site.website,
      });
    } catch {
      setApiDown(true);
    } finally {
      setSavingSite(false);
    }
  }

  async function saveHomeHero(e: React.FormEvent) {
    e.preventDefault();
    setSavingHero(true);
    try {
      const slides = homeHero.slides
        .map((s) => ({ text: s.text.trim(), textAr: s.textAr?.trim() }))
        .filter((s) => s.text.length > 0);
      await putHomeHero({
        imageUrl: homeHero.imageUrl.trim(),
        slides: slides.length > 0 ? slides : [{ text: '—', textAr: '' }],
        reportCtaEn: homeHero.reportCtaEn.trim(),
        reportCtaAr: homeHero.reportCtaAr.trim(),
      });
      await load();
    } catch {
      setApiDown(true);
    } finally {
      setSavingHero(false);
    }
  }

  function openAdd() {
    setEditingId(null);
    setForm(emptyForm());
    setModalOpen(true);
  }

  function openEdit(a: AppAnnouncement) {
    setEditingId(a.id);
    setForm({
      name: a.name,
      nameAr: a.nameAr ?? '',
      passedAwayDate: a.passedAwayDate,
      serviceType: formServiceTypeFromStored(a),
      serviceDateTime: a.serviceDateTime,
      burialLocation: a.burialLocation,
      burialLocationAr: a.burialLocationAr ?? '',
      iconKey: formIconKeyFromStored(a),
    });
    setModalOpen(true);
  }

  async function saveAnnouncement(e: React.FormEvent) {
    e.preventDefault();
    try {
      if (editingId) {
        const updated = await patchAnnouncement(editingId, form);
        setAnnouncements((prev) => prev.map((x) => (x.id === editingId ? updated : x)));
      } else {
        const created = await postAnnouncement(form);
        setAnnouncements((prev) => [created, ...prev]);
      }
      setModalOpen(false);
    } catch {
      setApiDown(true);
    }
  }

  async function remove(id: string) {
    if (!window.confirm(t('content.confirmDelete'))) return;
    try {
      await deleteAnnouncement(id);
      setAnnouncements((prev) => prev.filter((x) => x.id !== id));
    } catch {
      setApiDown(true);
    }
  }

  async function approveAnnouncement(id: string) {
    try {
      await patchAnnouncement(id, { status: 'approved' });
      await load();
    } catch {
      setApiDown(true);
    }
  }

  const pendingAnnouncements = announcements.filter((a) => a.status === 'pending');
  const publishedAnnouncements = announcements.filter((a) => a.status !== 'pending');

  if (loading) {
    return (
      <div className="stack">
        <p className="lead">{t('content.loading')}</p>
      </div>
    );
  }

  return (
    <div className="stack">
      <p className="lead">{t('content.lead')}</p>
      {apiDown && <p className="panel" style={{ borderColor: 'var(--warn, #b45309)', color: '#92400e' }}>{t('content.apiOffline')}</p>}

      <section className="panel">
        <h3 className="panel-title">{t('content.homeHeroTitle')}</h3>
        <p className="small muted" style={{ marginTop: 0, marginBottom: 12 }}>
          {t('content.homeHeroLead')}
        </p>
        <form onSubmit={saveHomeHero} className="stack" style={{ gap: '0.75rem' }}>
          <div className="field full">
            <label htmlFor="heroImg">{t('content.homeHeroImageUrl')}</label>
            <input
              id="heroImg"
              type="url"
              placeholder="https://…"
              value={homeHero.imageUrl}
              onChange={(e) => setHomeHero((h) => ({ ...h, imageUrl: e.target.value }))}
            />
          </div>
          {homeHero.slides.map((s, idx) => (
            <div key={idx} className="form-grid" style={{ borderBottom: '1px solid var(--divider)', paddingBottom: 12 }}>
              <div className="field full">
                <label htmlFor={`slide${idx}en`}>{t('content.homeHeroSlideEn')}</label>
                <textarea
                  id={`slide${idx}en`}
                  rows={2}
                  value={s.text}
                  onChange={(e) => {
                    const next = [...homeHero.slides];
                    next[idx] = { ...next[idx], text: e.target.value };
                    setHomeHero((h) => ({ ...h, slides: next }));
                  }}
                />
              </div>
              <div className="field full">
                <label htmlFor={`slide${idx}ar`}>{t('content.homeHeroSlideAr')}</label>
                <textarea
                  id={`slide${idx}ar`}
                  rows={2}
                  dir="rtl"
                  value={s.textAr}
                  onChange={(e) => {
                    const next = [...homeHero.slides];
                    next[idx] = { ...next[idx], textAr: e.target.value };
                    setHomeHero((h) => ({ ...h, slides: next }));
                  }}
                />
              </div>
              <div className="full">
                <button
                  type="button"
                  className="btn btn-ghost btn-sm"
                  onClick={() =>
                    setHomeHero((h) => ({
                      ...h,
                      slides: h.slides.filter((_, i) => i !== idx),
                    }))
                  }
                >
                  {t('content.homeHeroRemoveSlide')}
                </button>
              </div>
            </div>
          ))}
          <button
            type="button"
            className="btn btn-secondary btn-sm"
            onClick={() => setHomeHero((h) => ({ ...h, slides: [...h.slides, { text: '', textAr: '' }] }))}
          >
            {t('content.homeHeroAddSlide')}
          </button>
          <div className="field">
            <label htmlFor="rEn">{t('content.homeHeroReportCtaEn')}</label>
            <input
              id="rEn"
              value={homeHero.reportCtaEn}
              onChange={(e) => setHomeHero((h) => ({ ...h, reportCtaEn: e.target.value }))}
            />
          </div>
          <div className="field">
            <label htmlFor="rAr">{t('content.homeHeroReportCtaAr')}</label>
            <input id="rAr" dir="rtl" value={homeHero.reportCtaAr} onChange={(e) => setHomeHero((h) => ({ ...h, reportCtaAr: e.target.value }))} />
          </div>
          <div className="form-actions">
            <button type="submit" className="btn btn-primary" disabled={savingHero}>
              {t('content.saveHomeHero')}
            </button>
          </div>
        </form>
      </section>

      <section className="panel">
        <h3 className="panel-title">{t('content.ministryTitle')}</h3>
        <form onSubmit={saveMinistry} className="form-grid">
          <div className="field">
            <label htmlFor="dt">{t('content.deceasedToday')}</label>
            <input
              id="dt"
              type="number"
              min={0}
              value={ministry.deceasedToday}
              onChange={(e) => setMinistry((m) => ({ ...m, deceasedToday: Math.max(0, parseInt(e.target.value, 10) || 0) }))}
            />
          </div>
          <div className="field">
            <label htmlFor="dm">{t('content.deceasedThisMonth')}</label>
            <input
              id="dm"
              type="number"
              min={0}
              value={ministry.deceasedThisMonth}
              onChange={(e) =>
                setMinistry((m) => ({ ...m, deceasedThisMonth: Math.max(0, parseInt(e.target.value, 10) || 0) }))
              }
            />
          </div>
          <div className="field full">
            <label htmlFor="fn">{t('content.feedNote')}</label>
            <textarea
              id="fn"
              rows={2}
              value={ministry.feedNote}
              onChange={(e) => setMinistry((m) => ({ ...m, feedNote: e.target.value }))}
            />
          </div>
          <div className="field full">
            <label htmlFor="fa">{t('content.feedNoteAr')}</label>
            <textarea
              id="fa"
              rows={2}
              dir="rtl"
              value={ministry.feedNoteAr}
              onChange={(e) => setMinistry((m) => ({ ...m, feedNoteAr: e.target.value }))}
            />
          </div>
          <div className="form-actions full">
            <button type="submit" className="btn btn-primary" disabled={savingMinistry}>
              {t('content.saveMinistry')}
            </button>
            <button type="button" className="btn btn-secondary" onClick={() => void load()}>
              {t('content.reload')}
            </button>
          </div>
        </form>
      </section>

      <section className="panel">
        <h3 className="panel-title">{t('content.siteTitle')}</h3>
        <form onSubmit={saveSiteInfo} className="form-grid">
          <div className="field full">
            <label htmlFor="sh">{t('content.siteHours')}</label>
            <textarea
              id="sh"
              rows={2}
              value={site.openingHours}
              onChange={(e) => setSite((s) => ({ ...s, openingHours: e.target.value }))}
            />
          </div>
          <div className="field full">
            <label htmlFor="sha">{t('content.siteHoursAr')}</label>
            <textarea
              id="sha"
              rows={2}
              dir="rtl"
              value={site.openingHoursAr}
              onChange={(e) => setSite((s) => ({ ...s, openingHoursAr: e.target.value }))}
            />
          </div>
          <div className="field">
            <label htmlFor="sp">{t('content.sitePhone')}</label>
            <input id="sp" value={site.phone} onChange={(e) => setSite((s) => ({ ...s, phone: e.target.value }))} />
          </div>
          <div className="field full">
            <label htmlFor="sw">{t('content.siteWebsite')}</label>
            <input id="sw" value={site.website} onChange={(e) => setSite((s) => ({ ...s, website: e.target.value }))} />
          </div>
          <div className="form-actions full">
            <button type="submit" className="btn btn-primary" disabled={savingSite}>
              {t('content.saveSite')}
            </button>
          </div>
        </form>
      </section>

      <section className="panel">
        <h3 className="panel-title">{t('content.pendingAnnouncementsTitle')}</h3>
        <p className="small muted" style={{ marginTop: 0, marginBottom: 12 }}>
          {t('content.pendingAnnouncementsLead')}
        </p>
        <div className="table-wrap">
          <table className="table">
            <thead>
              <tr>
                <th>{t('content.th.name')}</th>
                <th>{t('content.th.passed')}</th>
                <th>{t('content.th.service')}</th>
                <th>{t('content.th.when')}</th>
                <th>{t('content.th.location')}</th>
                <th>{t('content.actions')}</th>
              </tr>
            </thead>
            <tbody>
              {pendingAnnouncements.length === 0 && (
                <tr>
                  <td colSpan={6} className="muted">
                    {t('content.pendingEmpty')}
                  </td>
                </tr>
              )}
              {pendingAnnouncements.map((a) => (
                <tr key={a.id}>
                  <td>{a.name}</td>
                  <td className="mono small">{a.passedAwayDate}</td>
                  <td>
                    {a.serviceType === 'memorial' || a.serviceType === 'burial'
                      ? t('content.serviceBurial')
                      : t('content.serviceFuneralPrayers')}
                  </td>
                  <td className="mono small">{new Date(a.serviceDateTime).toLocaleString()}</td>
                  <td className="detail-cell small">{a.burialLocation}</td>
                  <td>
                    <button type="button" className="btn btn-primary btn-sm" onClick={() => void approveAnnouncement(a.id)}>
                      {t('content.approveAnnouncement')}
                    </button>{' '}
                    <button type="button" className="btn btn-ghost btn-sm" onClick={() => void openEdit(a)}>
                      {t('content.edit')}
                    </button>{' '}
                    <button type="button" className="btn btn-ghost btn-sm" onClick={() => void remove(a.id)}>
                      {t('content.reject')}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="panel">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '1rem', flexWrap: 'wrap' }}>
          <h3 className="panel-title" style={{ margin: 0 }}>
            {t('content.announcementsTitle')}
          </h3>
          <button type="button" className="btn btn-primary" onClick={openAdd}>
            {t('content.add')}
          </button>
        </div>
        <div className="table-wrap" style={{ marginTop: 12 }}>
          <table className="table">
            <thead>
              <tr>
                <th>{t('content.th.name')}</th>
                <th>{t('content.th.passed')}</th>
                <th>{t('content.th.service')}</th>
                <th>{t('content.th.when')}</th>
                <th>{t('content.th.location')}</th>
                <th>{t('content.actions')}</th>
              </tr>
            </thead>
            <tbody>
              {publishedAnnouncements.length === 0 && (
                <tr>
                  <td colSpan={6} className="muted">
                    {t('content.empty')}
                  </td>
                </tr>
              )}
              {publishedAnnouncements.map((a) => (
                <tr key={a.id}>
                  <td>{a.name}</td>
                  <td className="mono small">{a.passedAwayDate}</td>
                  <td>
                    {a.serviceType === 'memorial' || a.serviceType === 'burial'
                      ? t('content.serviceBurial')
                      : t('content.serviceFuneralPrayers')}
                  </td>
                  <td className="mono small">{new Date(a.serviceDateTime).toLocaleString()}</td>
                  <td className="detail-cell small">{a.burialLocation}</td>
                  <td>
                    <button type="button" className="btn btn-ghost btn-sm" onClick={() => openEdit(a)}>
                      {t('content.edit')}
                    </button>{' '}
                    <button type="button" className="btn btn-ghost btn-sm" onClick={() => void remove(a.id)}>
                      {t('content.delete')}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <Modal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editingId ? t('content.modal.editTitle') : t('content.modal.addTitle')}
        closeAriaLabel={t('modal.close')}
      >
        <form onSubmit={saveAnnouncement} className="form-grid">
          <div className="field full">
            <label htmlFor="cn">{t('content.name')}</label>
            <input id="cn" value={form.name} onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))} required />
          </div>
          <div className="field full">
            <label htmlFor="ca">{t('content.nameAr')}</label>
            <input id="ca" dir="rtl" value={form.nameAr} onChange={(e) => setForm((f) => ({ ...f, nameAr: e.target.value }))} />
          </div>
          <div className="field">
            <label htmlFor="pd">{t('content.passedAwayDate')}</label>
            <input
              id="pd"
              type="date"
              value={form.passedAwayDate}
              onChange={(e) => setForm((f) => ({ ...f, passedAwayDate: e.target.value }))}
              required
            />
          </div>
          <div className="field">
            <label htmlFor="st">{t('content.serviceType')}</label>
            <select
              id="st"
              value={form.serviceType === 'burial' ? 'burial' : 'funeral_prayers'}
              onChange={(e) =>
                setForm((f) => ({
                  ...f,
                  serviceType: e.target.value === 'burial' ? 'burial' : 'funeral_prayers',
                }))
              }
            >
              <option value="funeral_prayers">{t('content.serviceFuneralPrayers')}</option>
              <option value="burial">{t('content.serviceBurial')}</option>
            </select>
          </div>
          <div className="field full">
            <label htmlFor="sv">{t('content.serviceAt')}</label>
            <input
              id="sv"
              type="datetime-local"
              value={isoToDatetimeLocal(form.serviceDateTime)}
              onChange={(e) => setForm((f) => ({ ...f, serviceDateTime: datetimeLocalToIso(e.target.value) }))}
              required
            />
          </div>
          <div className="field full">
            <label htmlFor="bl">{t('content.burialLocation')}</label>
            <input
              id="bl"
              value={form.burialLocation}
              onChange={(e) => setForm((f) => ({ ...f, burialLocation: e.target.value }))}
              required
            />
          </div>
          <div className="field full">
            <label htmlFor="bla">{t('content.burialLocationAr')}</label>
            <input
              id="bla"
              dir="rtl"
              value={form.burialLocationAr}
              onChange={(e) => setForm((f) => ({ ...f, burialLocationAr: e.target.value }))}
            />
          </div>
          <div className="field">
            <label htmlFor="ic">{t('content.iconKey')}</label>
            <select
              id="ic"
              value={form.iconKey === 'prayer' ? 'prayer' : 'burial'}
              onChange={(e) =>
                setForm((f) => ({ ...f, iconKey: e.target.value === 'prayer' ? 'prayer' : 'burial' }))
              }
            >
              <option value="prayer">{t('content.iconPrayer')}</option>
              <option value="burial">{t('content.iconBurial')}</option>
            </select>
          </div>
          <div className="form-actions full">
            <button type="button" className="btn btn-secondary" onClick={() => setModalOpen(false)}>
              {t('content.cancel')}
            </button>
            <button type="submit" className="btn btn-primary">
              {t('content.save')}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}

import { useEffect, useMemo, useState } from 'react';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  AreaChart,
  Area,
} from 'recharts';
import { useDashboard } from '../context/DashboardContext';
import { useI18n, useLocalizedText } from '../i18n';

export function StatisticsPage() {
  const { t } = useI18n();
  const loc = useLocalizedText();
  const { stats, updateStats } = useDashboard();
  const [today, setToday] = useState(String(stats.deceasedToday));
  const [month, setMonth] = useState(String(stats.deceasedThisMonth));

  useEffect(() => {
    setToday(String(stats.deceasedToday));
    setMonth(String(stats.deceasedThisMonth));
  }, [stats.deceasedToday, stats.deceasedThisMonth]);

  function saveHeadline(e: React.FormEvent) {
    e.preventDefault();
    updateStats({
      deceasedToday: Math.max(0, parseInt(today, 10) || 0),
      deceasedThisMonth: Math.max(0, parseInt(month, 10) || 0),
    });
  }

  const trendData = useMemo(
    () => stats.monthlyTrend.map((m) => ({ ...m, monthLabel: loc(m.month, m.monthAr) })),
    [stats.monthlyTrend, loc],
  );
  const cemeteryData = useMemo(
    () => stats.byCemetery.map((c) => ({ ...c, nameLabel: loc(c.name, c.nameAr) })),
    [stats.byCemetery, loc],
  );

  return (
    <div className="stack">
      <p className="lead">{t('stats.lead')}</p>

      <form onSubmit={saveHeadline} className="panel inline-form">
        <div className="field">
          <label htmlFor="dt">{t('stats.today')}</label>
          <input id="dt" type="number" min={0} value={today} onChange={(e) => setToday(e.target.value)} />
        </div>
        <div className="field">
          <label htmlFor="dm">{t('stats.month')}</label>
          <input id="dm" type="number" min={0} value={month} onChange={(e) => setMonth(e.target.value)} />
        </div>
        <button type="submit" className="btn btn-primary">
          {t('stats.save')}
        </button>
      </form>

      <div className="two-col">
        <section className="panel chart-panel">
          <h3 className="panel-title">{t('stats.chart.trend')}</h3>
          <div className="chart-box">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={trendData} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorCnt" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="var(--maroon, #8e1737)" stopOpacity={0.35} />
                    <stop offset="95%" stopColor="var(--maroon, #8e1737)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.06)" />
                <XAxis dataKey="monthLabel" tick={{ fontSize: 12 }} />
                <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                <Tooltip />
                <Area
                  type="monotone"
                  dataKey="count"
                  stroke="var(--maroon, #8e1737)"
                  fillOpacity={1}
                  fill="url(#colorCnt)"
                  name={t('stats.chart.count')}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </section>

        <section className="panel chart-panel">
          <h3 className="panel-title">{t('stats.chart.cemetery')}</h3>
          <div className="chart-box">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={cemeteryData} layout="vertical" margin={{ top: 8, right: 16, left: 8, bottom: 8 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.06)" />
                <XAxis type="number" allowDecimals={false} />
                <YAxis type="category" dataKey="nameLabel" width={120} tick={{ fontSize: 11 }} />
                <Tooltip />
                <Bar dataKey="burials" fill="var(--maroon, #8e1737)" name={t('stats.chart.burials')} radius={[0, 6, 6, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </section>
      </div>
    </div>
  );
}

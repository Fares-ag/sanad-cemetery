import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { ar, en, type DashKey } from './dictionary';

const STORAGE_KEY = 'sanad_dash_locale';

export type Locale = 'en' | 'ar';

export interface I18nValue {
  locale: Locale;
  setLocale: (l: Locale) => void;
  t: (key: DashKey) => string;
  isRtl: boolean;
}

const I18nContext = createContext<I18nValue | null>(null);

function readLocale(): Locale {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw === 'ar' || raw === 'en') return raw;
  } catch {
    /* ignore */
  }
  return 'en';
}

export function I18nProvider({ children }: { children: ReactNode }) {
  const [locale, setLocaleState] = useState<Locale>(() =>
    typeof window !== 'undefined' ? readLocale() : 'en',
  );

  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, locale);
    } catch {
      /* ignore */
    }
    document.documentElement.lang = locale === 'ar' ? 'ar' : 'en';
    document.documentElement.dir = locale === 'ar' ? 'rtl' : 'ltr';
  }, [locale]);

  const setLocale = useCallback((l: Locale) => setLocaleState(l), []);

  const t = useCallback(
    (key: DashKey) => {
      const dict = locale === 'ar' ? ar : en;
      return dict[key] ?? en[key] ?? String(key);
    },
    [locale],
  );

  const isRtl = locale === 'ar';

  const value = useMemo<I18nValue>(
    () => ({ locale, setLocale, t, isRtl }),
    [locale, setLocale, t, isRtl],
  );

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n(): I18nValue {
  const ctx = useContext(I18nContext);
  if (!ctx) throw new Error('useI18n must be used within I18nProvider');
  return ctx;
}

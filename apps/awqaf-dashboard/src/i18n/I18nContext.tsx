import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { ar, en, type AwqafKey } from './dictionary';

const STORAGE_KEY = 'sanad_awqaf_locale';

export type Locale = 'en' | 'ar';

export interface AwqafI18nValue {
  locale: Locale;
  setLocale: (l: Locale) => void;
  t: (key: AwqafKey) => string;
  isRtl: boolean;
}

const AwqafI18nContext = createContext<AwqafI18nValue | null>(null);

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
    (key: AwqafKey) => {
      const dict = locale === 'ar' ? ar : en;
      return dict[key] ?? en[key] ?? String(key);
    },
    [locale],
  );

  const isRtl = locale === 'ar';

  const value = useMemo<AwqafI18nValue>(
    () => ({ locale, setLocale, t, isRtl }),
    [locale, setLocale, t, isRtl],
  );

  return <AwqafI18nContext.Provider value={value}>{children}</AwqafI18nContext.Provider>;
}

export function useI18n(): AwqafI18nValue {
  const ctx = useContext(AwqafI18nContext);
  if (!ctx) throw new Error('useI18n must be used within I18nProvider');
  return ctx;
}

import { useCallback } from 'react';
import { useI18n } from './I18nContext';

/** Pick Arabic when locale is AR and an Arabic string exists; otherwise English. */
export function useLocalizedText() {
  const { locale } = useI18n();
  return useCallback((en: string, ar?: string) => {
    if (locale === 'ar' && ar != null && ar.trim() !== '') return ar;
    return en;
  }, [locale]);
}

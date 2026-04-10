import { useI18n } from './I18nContext';
import type { Locale } from './I18nContext';

export function LanguageToggle() {
  const { locale, setLocale, t } = useI18n();

  function pick(next: Locale) {
    setLocale(next);
  }

  return (
    <div className="lang-toggle" role="group" aria-label={t('lang.group')}>
      <button
        type="button"
        className={'lang-toggle-btn' + (locale === 'en' ? ' is-active' : '')}
        onClick={() => pick('en')}
      >
        {t('lang.en')}
      </button>
      <button
        type="button"
        className={'lang-toggle-btn' + (locale === 'ar' ? ' is-active' : '')}
        onClick={() => pick('ar')}
      >
        {t('lang.ar')}
      </button>
    </div>
  );
}

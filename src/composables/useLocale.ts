import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useUIStore } from '@/stores/useUIStore'
import type { Locale } from '@/types'

// ─── useLocale ────────────────────────────────────────────────────────────

export function useLocale() {
  const { locale, t, n, d } = useI18n()
  const uiStore = useUIStore()

  const isRTL  = computed(() => locale.value === 'ar')
  const dir    = computed(() => isRTL.value ? 'rtl' : 'ltr')
  const lang   = computed(() => locale.value as Locale)

  function switchLocale(newLocale: Locale) {
    locale.value = newLocale
    uiStore.locale = newLocale
    document.documentElement.dir  = newLocale === 'ar' ? 'rtl' : 'ltr'
    document.documentElement.lang = newLocale
    localStorage.setItem('kewan-locale', newLocale)
  }

  function localizedValue<T extends { en: string; ar: string }>(obj: T): string {
    return obj[locale.value as Locale] ?? obj.en
  }

  return { locale: lang, isRTL, dir, t, n, d, switchLocale, localizedValue }
}

// ─── Bootstrap helper (call before app mount) ─────────────────────────────

export function initLocale(): Locale {
  const stored = localStorage.getItem('kewan-locale') as Locale | null
  const locale: Locale = stored ?? 'ar'
  document.documentElement.dir  = locale === 'ar' ? 'rtl' : 'ltr'
  document.documentElement.lang = locale
  return locale
}

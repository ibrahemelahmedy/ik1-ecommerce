import { createI18n } from 'vue-i18n'

const messages = {
  en: {
    welcome: 'Welcome',
  },
  ar: {
    welcome: 'مرحبا',
  },
}

export const i18n = createI18n({
  legacy: false,
  locale: 'en',
  fallbackLocale: 'en',
  messages,
})

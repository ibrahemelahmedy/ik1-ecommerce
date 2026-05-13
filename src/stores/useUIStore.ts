import { defineStore } from 'pinia'
import type { Theme, Locale, Toast } from '@/types'

// ─── UI Store ─────────────────────────────────────────────────────────────

interface UIState {
  theme: Theme
  locale: Locale
  sidebarOpen: boolean
  mobileMenuOpen: boolean
  toasts: Toast[]
}

export const useUIStore = defineStore('ui', {
  state: (): UIState => ({
    theme: 'light',
    locale: 'ar',
    sidebarOpen: false,
    mobileMenuOpen: false,
    toasts: [],
  }),

  actions: {
    setTheme(theme: Theme) {
      this.theme = theme
    },
    setLocale(locale: Locale) {
      this.locale = locale
    },
    toggleSidebar() {
      this.sidebarOpen = !this.sidebarOpen
    },
    toggleMobileMenu() {
      this.mobileMenuOpen = !this.mobileMenuOpen
    },
    closeMobileMenu() {
      this.mobileMenuOpen = false
    },
    addToast(toast: Omit<Toast, 'id'>) {
      const id = `toast-${Date.now()}-${Math.random().toString(36).slice(2)}`
      this.toasts.push({ ...toast, id })
      if ((toast.duration ?? 4000) > 0) {
        setTimeout(() => this.removeToast(id), toast.duration ?? 4000)
      }
    },
    removeToast(id: string) {
      this.toasts = this.toasts.filter(t => t.id !== id)
    },
  },
})

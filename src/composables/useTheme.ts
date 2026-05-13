import { computed } from 'vue'
import { useUIStore } from '@/stores/useUIStore'
import type { Theme } from '@/types'

// ─── useTheme ─────────────────────────────────────────────────────────────

export function useTheme() {
  const uiStore = useUIStore()

  const theme = computed(() => uiStore.theme)
  const isDark = computed(() => uiStore.theme === 'dark')

  function setTheme(value: Theme) {
    uiStore.theme = value
    document.documentElement.classList.toggle('dark', value === 'dark')
    localStorage.setItem('kewan-theme', value)
  }

  function toggleTheme() {
    setTheme(isDark.value ? 'light' : 'dark')
  }

  return { theme, isDark, setTheme, toggleTheme }
}

// ─── Bootstrap helper (call before app mount) ─────────────────────────────

export function initTheme(): Theme {
  const stored = localStorage.getItem('kewan-theme') as Theme | null
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
  const theme: Theme = stored ?? (prefersDark ? 'dark' : 'light')
  document.documentElement.classList.toggle('dark', theme === 'dark')
  return theme
}

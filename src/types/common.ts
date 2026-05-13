// ─── Shared Primitive Types ────────────────────────────────────────────────

export type Locale = 'ar' | 'en'
export type Theme = 'light' | 'dark'
export type Direction = 'ltr' | 'rtl'
export type Currency = 'SAR' | 'USD' | 'EUR' | 'AED'

export interface LocalizedString {
  en: string
  ar: string
}

export interface Price {
  amount: number
  currency: Currency
  formatted: string           // Pre-formatted for display: "SAR 249.00"
  originalAmount?: number     // Before discount
  discountPercent?: number    // 0–100
}

export interface PaginationMeta {
  total: number
  page: number
  limit: number
  totalPages: number
  hasNextPage: boolean
  hasPrevPage: boolean
}

export interface SelectOption<T = string> {
  label: string
  value: T
  disabled?: boolean
  description?: string
}

export interface Breadcrumb {
  label: string
  href?: string
  current?: boolean
}

// ─── Async State Machine ───────────────────────────────────────────────────
// Use this for all store state and component data fetching

export type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string }

export interface Toast {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message?: string
  duration?: number  // ms — 0 = persistent
}

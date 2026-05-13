import { defineStore } from 'pinia'
import { authService } from '@/services'
import type { AuthUser, LoginCredentials, RegisterPayload, Permission } from '@/types'

// ─── Auth Store ────────────────────────────────────────────────────────────

type AuthStatus = 'idle' | 'loading' | 'authenticated' | 'error'

interface AuthState {
  user: AuthUser | null
  token: string | null
  status: AuthStatus
  error: string | null
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    token: localStorage.getItem('kewan-token'),
    status: 'idle',
    error: null,
  }),

  getters: {
    isAuthenticated: (state): boolean => state.status === 'authenticated' && !!state.user,
    isVendor:        (state): boolean => state.user?.role === 'vendor',
    isAdmin:         (state): boolean => state.user?.role === 'admin',
    hasPermission:   (state) => (permission: Permission): boolean =>
      state.user?.permissions?.includes(permission) ?? false,
  },

  actions: {
    async login(credentials: LoginCredentials) {
      this.status = 'loading'
      this.error = null
      try {
        const { data } = await authService.login(credentials)
        this.user = data.user
        this.token = data.tokens.accessToken
        localStorage.setItem('kewan-token', data.tokens.accessToken)
        this.status = 'authenticated'
      } catch (err) {
        this.error = err instanceof Error ? err.message : 'Login failed'
        this.status = 'error'
        throw err
      }
    },

    async register(payload: RegisterPayload) {
      this.status = 'loading'
      this.error = null
      try {
        const { data } = await authService.register(payload)
        this.user = data.user
        this.token = data.tokens.accessToken
        localStorage.setItem('kewan-token', data.tokens.accessToken)
        this.status = 'authenticated'
      } catch (err) {
        this.error = err instanceof Error ? err.message : 'Registration failed'
        this.status = 'error'
        throw err
      }
    },

    async logout() {
      await authService.logout()
      this.user = null
      this.token = null
      this.status = 'idle'
      this.error = null
      localStorage.removeItem('kewan-token')
    },

    async checkAuth() {
      if (!this.token) return
      this.status = 'loading'
      try {
        const { data } = await authService.getProfile()
        this.user = data
        this.status = 'authenticated'
      } catch {
        this.user = null
        this.token = null
        this.status = 'idle'
        localStorage.removeItem('kewan-token')
      }
    },
  },
})

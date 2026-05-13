import { http } from './http'
import type {
  AuthUser,
  AuthTokens,
  LoginCredentials,
  RegisterPayload,
  ApiResponse,
} from '@/types'

// ─── Auth Service ─────────────────────────────────────────────────────────

export const authService = {
  async login(credentials: LoginCredentials): Promise<ApiResponse<{ user: AuthUser; tokens: AuthTokens }>> {
    return http.post('/auth/login', credentials)
  },

  async register(payload: RegisterPayload): Promise<ApiResponse<{ user: AuthUser; tokens: AuthTokens }>> {
    return http.post('/auth/register', payload)
  },

  async logout(): Promise<void> {
    await http.post('/auth/logout', {}).catch(() => {
      // Best-effort — always clear local state
    })
  },

  async refreshToken(): Promise<ApiResponse<AuthTokens>> {
    return http.post('/auth/refresh', {})
  },

  async getProfile(): Promise<ApiResponse<AuthUser>> {
    return http.get('/auth/me')
  },

  async forgotPassword(email: string): Promise<ApiResponse<void>> {
    return http.post('/auth/forgot-password', { email })
  },

  async resetPassword(token: string, password: string): Promise<ApiResponse<void>> {
    return http.post('/auth/reset-password', { token, password })
  },
}

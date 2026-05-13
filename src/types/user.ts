import type { LocalizedString } from './common'

// ─── Auth & User Types ─────────────────────────────────────────────────────

export type UserRole = 'customer' | 'vendor' | 'admin'

export type Permission =
  | 'product:read' | 'product:write' | 'product:delete'
  | 'order:read'   | 'order:write'   | 'order:manage'
  | 'vendor:read'  | 'vendor:write'  | 'vendor:approve'
  | 'admin:access' | 'platform:manage'
  | 'review:write' | 'review:delete'

export interface AuthUser {
  id: string
  email: string
  name: string
  avatar?: string
  role: UserRole
  permissions: Permission[]
  vendorId?: string   // only for vendor role
  createdAt: string
}

export interface CustomerProfile extends AuthUser {
  role: 'customer'
  phone?: string
  addresses: UserAddress[]
  defaultAddressId?: string
  wishlistCount: number
  orderCount: number
}

export interface UserAddress {
  id: string
  label: LocalizedString     // "Home", "Work"
  recipientName: string
  phone: string
  addressLine1: string
  addressLine2?: string
  city: LocalizedString
  region?: LocalizedString
  country: string            // ISO 3166-1 alpha-2
  postalCode?: string
  isDefault: boolean
}

// ─── Auth Payloads ────────────────────────────────────────────────────────

export interface LoginCredentials {
  email: string
  password: string
  rememberMe?: boolean
}

export interface RegisterPayload {
  name: string
  email: string
  password: string
  phone?: string
  locale: 'ar' | 'en'
}

export interface AuthTokens {
  accessToken: string
  expiresIn: number   // seconds
}

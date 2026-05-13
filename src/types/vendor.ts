import type { LocalizedString, Price, PaginationMeta } from './common'

// ─── Vendor Types ─────────────────────────────────────────────────────────

export type VendorStatus = 'pending' | 'approved' | 'suspended' | 'rejected'

export interface VendorRef {
  id: string
  slug: string
  name: LocalizedString
  logo?: string
  rating: number
  isVerified: boolean
}

export interface VendorProfile {
  id: string
  slug: string
  name: LocalizedString
  description: LocalizedString
  logo?: string
  banner?: string
  status: VendorStatus
  rating: {
    average: number
    count: number
  }
  isVerified: boolean
  categories: string[]
  productCount: number
  followerCount: number
  policies: {
    returnPolicy: LocalizedString
    shippingInfo: LocalizedString
  }
  contact: {
    email?: string
    phone?: string
    website?: string
  }
  socialLinks?: {
    instagram?: string
    twitter?: string
    facebook?: string
  }
  joinedAt: string
}

// ─── Vendor Dashboard ─────────────────────────────────────────────────────

export interface VendorStats {
  totalRevenue: Price
  totalOrders: number
  pendingOrders: number
  totalProducts: number
  activeProducts: number
  averageRating: number
  reviewCount: number
  period: 'today' | 'week' | 'month' | 'year'
}

export interface VendorOrderSummary {
  id: string
  orderId: string
  customerName: string
  itemCount: number
  total: Price
  status: 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled' | 'refunded'
  createdAt: string
}

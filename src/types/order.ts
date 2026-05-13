import type { Price, PaginationMeta } from './common'
import type { VendorRef } from './vendor'
import type { UserAddress } from './user'

// ─── Order Types ───────────────────────────────────────────────────────────

export type OrderStatus =
  | 'pending'
  | 'payment_pending'
  | 'confirmed'
  | 'processing'
  | 'shipped'
  | 'out_for_delivery'
  | 'delivered'
  | 'cancelled'
  | 'refund_requested'
  | 'refunded'

export type PaymentStatus = 'pending' | 'paid' | 'failed' | 'refunded'
export type PaymentMethod = 'card' | 'apple_pay' | 'stc_pay' | 'cod' | 'bank_transfer'

export interface OrderItem {
  id: string
  productId: string
  productSlug: string
  productName: string         // Snapshot at time of order
  productImage: string
  vendorId: string
  vendorName: string
  sku: string
  variantLabel?: string       // "Color: Red, Size: XL"
  quantity: number
  unitPrice: Price
  totalPrice: Price
}

export interface OrderVendorGroup {
  vendor: VendorRef
  items: OrderItem[]
  subtotal: Price
  status: OrderStatus
  trackingNumber?: string
  estimatedDelivery?: string
}

export interface Order {
  id: string
  orderNumber: string
  customerId: string
  status: OrderStatus
  paymentStatus: PaymentStatus
  paymentMethod: PaymentMethod
  vendorGroups: OrderVendorGroup[]
  shippingAddress: UserAddress
  pricing: {
    subtotal: Price
    shipping: Price
    discount?: Price
    tax?: Price
    total: Price
  }
  notes?: string
  timeline: OrderTimelineEvent[]
  createdAt: string
  updatedAt: string
}

export interface OrderTimelineEvent {
  status: OrderStatus
  timestamp: string
  note?: string
}

// ─── Cart Types ────────────────────────────────────────────────────────────

export interface CartItem {
  productId: string
  productSlug: string
  productName: string
  productImage: string
  vendorId: string
  vendorName: string
  sku: string
  variantId?: string
  variantLabel?: string
  quantity: number
  price: Price
  maxQuantity: number
}

export interface AddCartItemPayload {
  productId: string
  productSlug: string
  productName: string
  productImage: string
  vendorId: string
  vendorName: string
  sku: string
  variantId?: string
  variantLabel?: string
  price: Price
  maxQuantity: number
}

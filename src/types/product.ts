import type { LocalizedString, Price, PaginationMeta } from './common'
import type { VendorRef } from './vendor'

// ─── Product Domain Types ──────────────────────────────────────────────────

export type ProductStatus = 'active' | 'draft' | 'archived' | 'out_of_stock'

export type ProductCondition = 'new' | 'used' | 'refurbished'

export interface ProductImage {
  id: string
  url: string
  alt: LocalizedString
  width: number
  height: number
  isPrimary: boolean
  sortOrder: number
}

export interface ProductAttribute {
  key: string
  label: LocalizedString
  value: LocalizedString
}

export interface ProductVariantOption {
  name: LocalizedString  // e.g., "Color"
  values: LocalizedString[]
}

export interface ProductVariant {
  id: string
  sku: string
  options: Record<string, string>  // { color: 'red', size: 'XL' }
  price: Price
  stock: number
  images?: ProductImage[]
}

export interface ProductCategory {
  id: string
  slug: string
  name: LocalizedString
  parentId?: string
  parentName?: LocalizedString
  icon?: string
}

export interface ProductRating {
  average: number   // 0–5
  count: number
  distribution: Record<1 | 2 | 3 | 4 | 5, number>
}

export interface Product {
  id: string
  slug: string
  name: LocalizedString
  description: LocalizedString
  shortDescription?: LocalizedString
  price: Price
  images: ProductImage[]
  category: ProductCategory
  vendor: VendorRef
  rating: ProductRating
  variants: ProductVariant[]
  attributes: ProductAttribute[]
  tags: string[]
  status: ProductStatus
  condition: ProductCondition
  isFeatured: boolean
  isNew: boolean
  stock: number
  sku: string
  createdAt: string
  updatedAt: string
}

// ─── List / Search ────────────────────────────────────────────────────────

export type ProductSortKey =
  | 'price_asc'
  | 'price_desc'
  | 'rating_desc'
  | 'newest'
  | 'popular'
  | 'name_asc'

export interface ProductFilters {
  categoryId?: string
  vendorId?: string
  priceMin?: number
  priceMax?: number
  rating?: number
  condition?: ProductCondition
  inStockOnly?: boolean
  tags?: string[]
}

export interface ProductListParams extends ProductFilters {
  page?: number
  limit?: number
  sort?: ProductSortKey
  search?: string
}

export interface ProductListResult {
  products: Product[]
  meta: PaginationMeta
  filters: {
    priceRange: { min: number; max: number }
    availableCategories: ProductCategory[]
    availableVendors: VendorRef[]
  }
}

// ─── Reviews ──────────────────────────────────────────────────────────────

export interface ProductReview {
  id: string
  productId: string
  author: {
    id: string
    name: string
    avatar?: string
    isVerifiedPurchase: boolean
  }
  rating: 1 | 2 | 3 | 4 | 5
  title: string
  body: string
  images?: string[]
  helpfulCount: number
  createdAt: string
}

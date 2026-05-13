import { http } from './http'
import type {
  Product,
  ProductListParams,
  ProductListResult,
  ProductReview,
  ApiResponse,
  PaginationMeta,
} from '@/types'

// ─── Product Service ──────────────────────────────────────────────────────

export const productService = {
  async list(params?: ProductListParams): Promise<ApiResponse<Product[]>> {
    // TODO: replace mock with → return http.get('/products', { params })
    const { default: data } = await import('@/data/products.json')
    return {
      data: data as unknown as Product[],
      meta: { total: (data as unknown[]).length, page: 1, limit: 20, totalPages: 1, hasNextPage: false, hasPrevPage: false },
    }
  },

  async getBySlug(slug: string): Promise<ApiResponse<Product>> {
    // TODO: return http.get(`/products/${slug}`)
    const { default: data } = await import('@/data/products.json')
    const product = (data as unknown as Product[]).find(p => p.slug === slug)
    if (!product) throw new Error(`Product not found: ${slug}`)
    return { data: product }
  },

  async search(query: string, params?: ProductListParams): Promise<ApiResponse<Product[]>> {
    // TODO: return http.get('/products/search', { params: { q: query, ...params } })
    const { default: data } = await import('@/data/products.json')
    const results = (data as unknown as Product[]).filter(
      p => p.name.en.toLowerCase().includes(query.toLowerCase())
        || p.name.ar.includes(query)
    )
    return { data: results, meta: { total: results.length, page: 1, limit: 20, totalPages: 1, hasNextPage: false, hasPrevPage: false } }
  },

  async getReviews(productId: string, page = 1): Promise<ApiResponse<ProductReview[]>> {
    // TODO: return http.get(`/products/${productId}/reviews`, { params: { page } })
    return { data: [], meta: { total: 0, page, limit: 10, totalPages: 0, hasNextPage: false, hasPrevPage: false } }
  },

  async getFeatured(): Promise<ApiResponse<Product[]>> {
    // TODO: return http.get('/products/featured')
    const { default: data } = await import('@/data/products.json')
    const featured = (data as unknown as Product[]).filter(p => p.isFeatured)
    return { data: featured }
  },
}

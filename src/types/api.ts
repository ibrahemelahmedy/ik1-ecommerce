import type { PaginationMeta } from './common'

// ─── API Contract Types ────────────────────────────────────────────────────

export interface ApiResponse<T> {
  data: T
  meta?: PaginationMeta
  message?: string
}

export interface ApiError {
  code: string        // Machine-readable: 'PRODUCT_NOT_FOUND', 'UNAUTHORIZED'
  message: string     // Human-readable error message
  field?: string      // For validation errors: which field failed
  statusCode: number
  details?: unknown
}

export type ApiResult<T> =
  | { ok: true; data: T; meta?: PaginationMeta }
  | { ok: false; error: ApiError }

export interface RequestConfig {
  params?: Record<string, string | number | boolean | undefined>
  headers?: Record<string, string>
  signal?: AbortSignal
}

// ─── HTTP Client Interface ────────────────────────────────────────────────

export interface HttpClient {
  get<T>(path: string, config?: RequestConfig): Promise<ApiResponse<T>>
  post<T>(path: string, body: unknown, config?: RequestConfig): Promise<ApiResponse<T>>
  put<T>(path: string, body: unknown, config?: RequestConfig): Promise<ApiResponse<T>>
  patch<T>(path: string, body: unknown, config?: RequestConfig): Promise<ApiResponse<T>>
  delete<T>(path: string, config?: RequestConfig): Promise<ApiResponse<T>>
}

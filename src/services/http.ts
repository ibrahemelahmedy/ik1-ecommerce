import type { ApiResponse, ApiError, RequestConfig } from '@/types'

// ─── HTTP Client ───────────────────────────────────────────────────────────

const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? ''

function normalizeError(err: unknown): ApiError {
  if (err instanceof ApiException) return err.error
  if (err instanceof Error) {
    return { code: 'NETWORK_ERROR', message: err.message, statusCode: 0 }
  }
  return { code: 'UNKNOWN_ERROR', message: 'An unexpected error occurred', statusCode: 0 }
}

export class ApiException extends Error {
  constructor(public error: ApiError) {
    super(error.message)
    this.name = 'ApiException'
  }
}

function buildUrl(path: string, params?: RequestConfig['params']): string {
  const url = new URL(`${BASE_URL}${path}`, window.location.origin)
  if (params) {
    for (const [key, value] of Object.entries(params)) {
      if (value !== undefined) url.searchParams.set(key, String(value))
    }
  }
  return url.toString()
}

function getAuthHeader(): Record<string, string> {
  // Dynamically import to avoid circular deps (store imports http)
  const token = localStorage.getItem('kewan-token')
  return token ? { Authorization: `Bearer ${token}` } : {}
}

async function request<T>(
  method: string,
  path: string,
  body?: unknown,
  config?: RequestConfig
): Promise<ApiResponse<T>> {
  const url = buildUrl(path, config?.params)

  const response = await fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'Accept-Language': localStorage.getItem('kewan-locale') ?? 'ar',
      ...getAuthHeader(),
      ...config?.headers,
    },
    body: body !== undefined ? JSON.stringify(body) : undefined,
    signal: config?.signal,
  })

  const json = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new ApiException({
      code: json?.code ?? 'HTTP_ERROR',
      message: json?.message ?? response.statusText,
      field: json?.field,
      statusCode: response.status,
      details: json?.details,
    })
  }

  return json as ApiResponse<T>
}

export const http = {
  get<T>(path: string, config?: RequestConfig) {
    return request<T>('GET', path, undefined, config)
  },
  post<T>(path: string, body: unknown, config?: RequestConfig) {
    return request<T>('POST', path, body, config)
  },
  put<T>(path: string, body: unknown, config?: RequestConfig) {
    return request<T>('PUT', path, body, config)
  },
  patch<T>(path: string, body: unknown, config?: RequestConfig) {
    return request<T>('PATCH', path, body, config)
  },
  delete<T>(path: string, config?: RequestConfig) {
    return request<T>('DELETE', path, undefined, config)
  },
}

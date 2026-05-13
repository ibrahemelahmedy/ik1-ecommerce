import { defineStore } from 'pinia'
import type { CartItem, AddCartItemPayload } from '@/types'

// ─── Cart Store ────────────────────────────────────────────────────────────

interface CartState {
  items: CartItem[]
}

const CART_KEY = 'kewan-cart'

function persistCart(items: CartItem[]) {
  localStorage.setItem(CART_KEY, JSON.stringify(items))
}

function loadCart(): CartItem[] {
  try {
    const raw = localStorage.getItem(CART_KEY)
    return raw ? (JSON.parse(raw) as CartItem[]) : []
  } catch {
    return []
  }
}

export const useCartStore = defineStore('cart', {
  state: (): CartState => ({
    items: loadCart(),
  }),

  getters: {
    cartCount: (state): number =>
      state.items.reduce((sum, item) => sum + item.quantity, 0),

    cartTotal: (state): number =>
      state.items.reduce((sum, item) => sum + item.price.amount * item.quantity, 0),

    itemsByVendor: (state): Record<string, CartItem[]> =>
      state.items.reduce<Record<string, CartItem[]>>((groups, item) => {
        if (!groups[item.vendorId]) groups[item.vendorId] = []
        groups[item.vendorId].push(item)
        return groups
      }, {}),

    isInCart: (state) => (productId: string, variantId?: string): boolean =>
      state.items.some(i =>
        i.productId === productId && (!variantId || i.variantId === variantId)
      ),
  },

  actions: {
    addItem(payload: AddCartItemPayload) {
      const existing = this.items.find(
        i => i.productId === payload.productId && i.variantId === payload.variantId
      )
      if (existing) {
        existing.quantity = Math.min(existing.quantity + 1, payload.maxQuantity)
      } else {
        this.items.push({ ...payload, quantity: 1 })
      }
      persistCart(this.items)
    },

    updateQuantity(productId: string, variantId: string | undefined, quantity: number) {
      const item = this.items.find(
        i => i.productId === productId && i.variantId === variantId
      )
      if (!item) return
      if (quantity <= 0) {
        this.removeItem(productId, variantId)
      } else {
        item.quantity = Math.min(quantity, item.maxQuantity)
        persistCart(this.items)
      }
    },

    removeItem(productId: string, variantId?: string) {
      this.items = this.items.filter(
        i => !(i.productId === productId && i.variantId === variantId)
      )
      persistCart(this.items)
    },

    clearCart() {
      this.items = []
      localStorage.removeItem(CART_KEY)
    },
  },
})

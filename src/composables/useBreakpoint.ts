import { ref, onMounted, onUnmounted } from 'vue'

// ─── Breakpoint tokens (must match Tailwind config) ───────────────────────
const BREAKPOINTS = {
  sm:  640,
  md:  768,
  lg:  1024,
  xl:  1280,
  '2xl': 1536,
} as const

type Breakpoint = keyof typeof BREAKPOINTS

// ─── useBreakpoint ────────────────────────────────────────────────────────

export function useBreakpoint() {
  const width = ref(typeof window !== 'undefined' ? window.innerWidth : 1280)

  function onResize() {
    width.value = window.innerWidth
  }

  onMounted(() => window.addEventListener('resize', onResize, { passive: true }))
  onUnmounted(() => window.removeEventListener('resize', onResize))

  function gte(bp: Breakpoint) {
    return width.value >= BREAKPOINTS[bp]
  }

  function lt(bp: Breakpoint) {
    return width.value < BREAKPOINTS[bp]
  }

  return {
    width,
    isMobile:  { get value() { return width.value < BREAKPOINTS.md } },
    isTablet:  { get value() { return width.value >= BREAKPOINTS.md && width.value < BREAKPOINTS.lg } },
    isDesktop: { get value() { return width.value >= BREAKPOINTS.lg } },
    gte,
    lt,
  }
}

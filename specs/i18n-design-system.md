# i18n & Design System — Kewan (k1)

## Language Configuration

| Property | English (en) | Arabic (ar) |
|---|---|---|
| Direction | LTR | RTL |
| Font Family | Inter (Google Fonts) | Cairo (Google Fonts) |
| `dir` attribute | `ltr` | `rtl` |
| `lang` attribute | `en` | `ar` |
| Text alignment default | left | right |

---

## i18n Setup (vue-i18n v11)

```ts
// src/i18n/index.ts
import { createI18n } from 'vue-i18n'
import en from './locales/en.json'
import ar from './locales/ar.json'

export const i18n = createI18n({
  legacy: false,           // Composition API mode
  locale: 'ar',           // Default locale
  fallbackLocale: 'en',
  messages: { en, ar },
})
```

### Locale Switching Rule
When locale changes, two things MUST happen atomically:
1. `i18n.global.locale.value = newLocale`
2. `document.documentElement.setAttribute('dir', newLocale === 'ar' ? 'rtl' : 'ltr')`
3. `document.documentElement.setAttribute('lang', newLocale)`

Persist the selection to `localStorage` key `kewan-locale`.

### Composable Pattern
```ts
// src/composables/useLocale.ts
export function useLocale() {
  const { locale } = useI18n()
  const isRTL = computed(() => locale.value === 'ar')

  function switchLocale(lang: 'ar' | 'en') {
    locale.value = lang
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr'
    document.documentElement.lang = lang
    localStorage.setItem('kewan-locale', lang)
  }

  return { locale, isRTL, switchLocale }
}
```

---

## Font Loading

Load both fonts via `<link>` in `index.html`:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
```

### Font Application via CSS
```css
/* Applied in base.css */
body {
  font-family: var(--font-sans);   /* Inter default */
}

/* RTL override — applied when html[dir="rtl"] */
[dir="rtl"] body {
  font-family: var(--font-arabic); /* Cairo for Arabic */
}
```

---

## CSS Variable Design System

### Token Architecture (3-layer)

```
Layer 1: Primitive values   (#16A38F, #0F172A …)
Layer 2: Semantic tokens    (--color-brand, --color-page …) ← :root / .dark
Layer 3: Tailwind utilities (bg-bg-page, text-text-main …) ← @theme inline
```

### Color Tokens

#### Light Mode (`:root`)
| Token | Value | Usage |
|---|---|---|
| `--color-brand` | `#16A38F` | Primary CTA, links, focus rings |
| `--color-brand-hover` | `#138D7E` | Hover state for brand elements |
| `--color-page` | `#F8F9FA` | Page/body background |
| `--color-surface` | `#FFFFFF` | Card, modal, popover backgrounds |
| `--color-content` | `#1A1C1E` | Primary text |
| `--color-muted` | `#6B7280` | Secondary text, placeholders |
| `--color-border-ui` | `#E5E7EB` | Borders, dividers |

#### Dark Mode (`.dark`)
| Token | Value | Usage |
|---|---|---|
| `--color-brand` | `#16A38F` | Same — brand identity unchanged |
| `--color-brand-hover` | `#2DD4BF` | Brightened for dark backgrounds |
| `--color-page` | `#0F172A` | Deep navy page background (Slate 950) |
| `--color-surface` | `#1E293B` | Card backgrounds (Slate 800) |
| `--color-content` | `#F3F4F6` | Near-white primary text |
| `--color-muted` | `#9CA3AF` | Gray-400 secondary text |
| `--color-border-ui` | `#334155` | Slate-700 borders |

### Theme Switching Rules

1. Dark mode is toggled by adding/removing class `.dark` on `<html>`
2. `useUIStore.theme` holds `'light' | 'dark'`
3. On mount, read `localStorage.getItem('kewan-theme')` to restore preference
4. Respect `prefers-color-scheme` media query as initial default when no stored preference

```ts
// src/composables/useTheme.ts
export function useTheme() {
  const uiStore = useUIStore()

  function toggleTheme() {
    uiStore.theme = uiStore.theme === 'light' ? 'dark' : 'light'
    document.documentElement.classList.toggle('dark', uiStore.theme === 'dark')
    localStorage.setItem('kewan-theme', uiStore.theme)
  }

  return { theme: computed(() => uiStore.theme), toggleTheme }
}
```

---

## RTL-Specific Component Rules

### Spacing & Layout
- Use `ms-*` / `me-*` (margin-start/end) over `ml-*`/`mr-*` — Tailwind v4 respects logical properties
- Use `ps-*` / `pe-*` (padding-start/end) for directional padding
- Use `start-*` / `end-*` for `left/right` positioning

### Icons & Arrows
- Directional icons (chevrons, arrows) must be flipped in RTL: apply `rtl:rotate-180` or use `scale-x-[-1]` via `[dir="rtl"]`
- Non-directional icons (cart, heart, star) never flip

### Text Alignment
```css
/* Always use logical alignment */
.text-start { text-align: start; } /* left in LTR, right in RTL */
.text-end   { text-align: end; }
```

### Number & Currency Formatting
- Use `Intl.NumberFormat` with the active locale
- Arabic locale: `ar-SA` — displays Eastern Arabic numerals
- English locale: `en-US`
- Currency: always `SAR` (or `USD`) with appropriate symbol position

```ts
export function formatPrice(amount: number, locale: string): string {
  return new Intl.NumberFormat(locale === 'ar' ? 'ar-SA' : 'en-US', {
    style: 'currency',
    currency: 'SAR',
  }).format(amount)
}
```

---

## Translation Key Conventions

```json
{
  "nav": { "home": "…", "products": "…", "cart": "…" },
  "product": {
    "addToCart": "…",
    "outOfStock": "…",
    "price": "…",
    "originalPrice": "…"
  },
  "common": {
    "loading": "…",
    "error": "…",
    "retry": "…",
    "close": "…",
    "save": "…",
    "cancel": "…"
  },
  "aria": {
    "openMenu": "…",
    "closeMenu": "…",
    "toggleTheme": "…"
  }
}
```

- Keys are always `camelCase`
- Nested max 2 levels deep
- `aria.*` namespace for all screen-reader strings
- Pluralization via vue-i18n's `{count}` + plural rules

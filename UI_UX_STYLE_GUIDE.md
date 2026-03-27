# UI/UX Style Guide (Gebeya)

This document describes the **current UI/UX patterns, colors, fonts, and styling system** used in the Gebeya frontend.

## 1) Tech stack (UI layer)

- **Framework**: Next.js App Router (`frontend/src/app/*`)
- **Styling**: Tailwind CSS v4 (CSS-first) via `@import "tailwindcss";` in `frontend/src/app/globals.css`
- **Component system**: shadcn/ui (New York style) + Radix UI primitives (`frontend/components.json`)
- **Icons**: `lucide-react`
- **Toasts**: `sonner` (wrapped in `frontend/src/components/ui/sonner.tsx`)
- **Data fetching UI states**: `@tanstack/react-query` + skeleton loaders

## 2) Typography (fonts + scale)

- **Primary font (sans)**: Geist (`--font-geist-sans`)
- **Monospace font**: Geist Mono (`--font-geist-mono`)
- **Where configured**: `frontend/src/app/layout.tsx`
  - Adds font variables to `<body>` and uses `antialiased`.

### Common heading + text patterns (as implemented)

- **Page title**: `text-3xl font-bold`
- **Section title**: often `text-sm font-medium` (card headers, metric cards)
- **Helper / secondary text**: `text-muted-foreground` (usually `text-sm`)

## 3) Color system (tokens + brand accents)

### 3.1 Token-based colors (shadcn + CSS variables)

The base palette is token-driven using CSS variables in `frontend/src/app/globals.css` (OKLCH color space).

**Core tokens**
- `--background`, `--foreground`
- `--card`, `--card-foreground`
- `--popover`, `--popover-foreground`
- `--primary`, `--primary-foreground`
- `--secondary`, `--secondary-foreground`
- `--muted`, `--muted-foreground`
- `--accent`, `--accent-foreground`
- `--destructive`
- `--border`, `--input`, `--ring`

**Charts**
- `--chart-1` .. `--chart-5`

**Sidebar tokens**
- `--sidebar`, `--sidebar-foreground`
- `--sidebar-primary`, `--sidebar-primary-foreground`
- `--sidebar-accent`, `--sidebar-accent-foreground`
- `--sidebar-border`, `--sidebar-ring`

These are exposed to Tailwind via `@theme inline` mappings (e.g. `--color-background: var(--background)`), so utilities like `bg-background`, `text-foreground`, etc. resolve to the token values.

### 3.2 Brand accents (hard-coded Tailwind colors)

Beyond neutral tokens, Gebeya uses a consistent “brand gradient” for identity and key surfaces:

- **Primary brand gradient**: `from-purple-600 to-blue-600`
  - Sidebar header: `bg-gradient-to-r from-purple-600 to-blue-600`
  - Auth/logo mark: rounded circle with `bg-gradient-to-br from-purple-600 to-blue-600`
  - Some feature icons/avatars: `from-purple-500 to-blue-500`

**Page background gradients**
- Auth + error shells: `bg-gradient-to-br from-purple-50 to-blue-50` (login adds `via-blue-50 to-indigo-50`)
- Main app content area: `bg-gradient-to-br from-slate-50 to-blue-50/30`

### 3.3 Dark mode (current status)

- The token set defines a `.dark { ... }` theme in `globals.css`.
- The codebase includes `next-themes` usage in the toast component (`useTheme` in `frontend/src/components/ui/sonner.tsx`).
- **However**: there is currently **no ThemeProvider wiring** in `frontend/src/app/layout.tsx`, and there is no UI theme toggle. Dark mode tokens exist, but enabling/toggling dark mode is not implemented in the app shell.

## 4) Layout & spacing patterns

### 4.1 App shell layout

- **Main shell**: `MainLayout` (`frontend/src/components/layout/main-layout.tsx`)
  - Full-height: `h-screen`
  - Sidebar + content in a horizontal flex row.
  - Content wrapper: `container mx-auto p-4 lg:p-6 max-w-7xl`
  - Mobile:
    - Sidebar slides in/out with `transform transition-transform duration-300 ease-in-out`
    - Backdrop overlay: `bg-black/50`

### 4.2 Sidebar patterns

- Sidebar container: fixed width `w-64`, gradient background `from-white to-slate-50`, `shadow-lg`.
- Active nav item styling:
  - `bg-purple-50 text-purple-700`
  - Dark variants exist in classnames (e.g. `dark:bg-purple-950`) even if dark mode isn’t enabled yet.
- Section navigation:
  - Collapsible groups with `ChevronDown/ChevronRight`.
  - Nested children indented (`ml-4`) and smaller text.
- Badges:
  - Low stock indicator badge: orange pill (`bg-orange-500 text-white`) with `"99+"` cap.

### 4.3 Page composition pattern

Most pages follow:

- Outer container: `div.space-y-6`
- Header row:
  - Left: title + subtitle (`text-muted-foreground`)
  - Right: actions (buttons)
- Primary content: shadcn `Card` components stacking sections.
- Tables: shadcn `Table` with row hover highlighting.

## 4.4 Auth (login/signup) screen patterns

The authentication screens use a consistent “centered card on soft gradient” layout:

- **Background**
  - `bg-gradient-to-br from-purple-50 to-blue-50`
  - Login page adds extra depth: `from-purple-50 via-blue-50 to-indigo-50`
- **Card container**
  - Centered, `max-w-md` (login) and `max-w-2xl` (merchant registration)
  - Modern look: `shadow-xl` and minimal borders (login uses `border-0`)
- **Brand mark**
  - Circular logo with brand gradient: `bg-gradient-to-br from-purple-600 to-blue-600`
  - White “G” lettermark inside
- **Typography**
  - Primary headline often uses gradient text:
    - `bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent`
- **Primary CTA**
  - Full-width primary button (`Button` default variant)
- **Secondary navigation**
  - Text link to signup/login (`Link` with brand tint, e.g. `text-purple-600`)
- **Form spacing**
  - `space-y-4` within forms; labels on top of inputs.

## 5) Components & interaction styles (shadcn)

### 5.1 Buttons

- File: `frontend/src/components/ui/button.tsx`
- Variants:
  - `default`: `bg-primary text-primary-foreground hover:bg-primary/90`
  - `destructive`: `bg-destructive text-white ...`
  - `outline`: `border bg-background shadow-xs hover:bg-accent ...`
  - `secondary`, `ghost`, `link`
- Sizes:
  - `default`, `sm`, `lg`, `icon`, `icon-sm`, `icon-lg`
- Accessibility:
  - Focus ring: `focus-visible:ring-[3px] focus-visible:ring-ring/50`
  - Invalid state support: `aria-invalid:*`

### 5.2 Cards

- File: `frontend/src/components/ui/card.tsx`
- Visual defaults:
  - `rounded-xl border shadow-sm`
  - Internal spacing uses `px-6` and `py-6` conventions.

### 5.3 Inputs

- File: `frontend/src/components/ui/input.tsx`
- Patterns:
  - `h-9 rounded-md border ... shadow-xs`
  - Focus ring via `focus-visible:ring-[3px]`
  - Invalid state styling via `aria-invalid:*`

### 5.4 Tables

- File: `frontend/src/components/ui/table.tsx`
- Patterns:
  - Horizontal scroll wrapper: `overflow-x-auto`
  - Row hover: `hover:bg-muted/50`
  - Selected row: `data-[state=selected]:bg-muted`

### 5.5 Dialogs / modals

- File: `frontend/src/components/ui/dialog.tsx`
- Patterns:
  - Overlay: `fixed inset-0 bg-black/50`
  - Content: centered, `rounded-lg border p-6 shadow-lg`
  - Animations: `animate-in/animate-out`, `fade`, `zoom`, `slide` (via `tw-animate-css`)

### 5.6 Selects

- File: `frontend/src/components/ui/select.tsx`
- Patterns:
  - Trigger: border + focus ring, consistent height `h-9` default.
  - Content: `rounded-md border shadow-md` with open/close animations.

### 5.7 Badges

- File: `frontend/src/components/ui/badge.tsx`
- Variants:
  - `default`, `secondary`, `destructive`, `outline`
- Used heavily for:
  - Status states (Active/Inactive, Stock level, Subscription status, etc.)
  - Inline labels (SKU, flags like Discount/Over Price, etc.)

### 5.8 Alerts + error messaging

- Alert component: `frontend/src/components/ui/alert.tsx` (default + destructive)
- Subscription-related UX:
  - Global sticky banner: `frontend/src/components/subscription/subscription-banner.tsx`
  - Per-page error panels: `frontend/src/components/subscription/subscription-error-message.tsx` (used on many merchant pages)

### 5.9 Loading states

- Skeletons: `frontend/src/components/ui/skeleton.tsx` (`animate-pulse bg-accent rounded-md`)
- Common page loading pattern: card grid of skeleton blocks.

## 6) UX patterns (behavior)

### 6.1 Notifications (toasts)

- Provider: `frontend/src/lib/providers.tsx` mounts `<Toaster />` globally.
- Toaster component: `frontend/src/components/ui/sonner.tsx`
- Usage pattern:
  - `toast.success(...)` on successful mutations
  - `toast.error(...)` on validation/API errors
  - `toast.info(...)` for “coming soon” and extra info (e.g. temporary password)

### 6.2 Filtering & date ranges

- Date filter component: `frontend/src/components/filters/date-filter.tsx`
  - Preset buttons use `Button` variants (`default` when active, `outline` otherwise).
  - Custom range uses `DateRangePicker` and the `react-day-picker` styling overrides in `globals.css`.

### 6.3 Error pages

- Not found: `frontend/src/app/not-found.tsx`
- Unauthorized: `frontend/src/app/unauthorized/page.tsx`
- Pattern: centered card on `bg-gradient-to-br from-purple-50 to-blue-50` with an icon badge circle.

## 7) Radius, shadows, motion

- **Radius**
  - Base radius: `--radius: 0.625rem` (10px)
  - Derived radii: `--radius-sm`, `--radius-md`, `--radius-lg`, `--radius-xl`
- **Shadows**
  - Cards: `shadow-sm`
  - Sidebar: `shadow-lg`
  - Buttons/inputs often use `shadow-xs`
- **Motion**
  - Radix open/close transitions rely on `tw-animate-css` + data-state classes.
  - Sidebar slide animation uses Tailwind `transition-transform duration-300 ease-in-out`.


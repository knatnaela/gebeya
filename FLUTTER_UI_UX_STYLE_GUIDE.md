# Flutter UI/UX Style Guide (Gebeya Merchant App)

This document defines the **UI/UX patterns, colors, typography, spacing, and component styling** to use in the Flutter merchant app, aligned with the existing web design documented in `UI_UX_STYLE_GUIDE.md`.

---

## 1) Design goals

- **Match the web brand**: purple→blue identity, clean neutral surfaces, “card + table/list” information layout.
- **Mobile-first ergonomics**: large tap targets, bottom navigation + “More” hub, filter sheets, fast search.
- **Consistent states**: loading (skeleton), empty, error, expired subscription banner.
- **Token-driven theming**: centralize colors/typography/radius to keep screens consistent.

---

## 2) Typography (Flutter)

### 2.1 Font choice

Web uses **Geist / Geist Mono**. In Flutter you have two options:

- **Option A (recommended)**: Use **Inter** (Google Fonts) for body/UI and **Roboto Mono** for monospace.
- **Option B**: Bundle **Geist** as app assets and set it as the default font family.

### 2.2 Type scale (recommended)

Use a small set of text styles that map to the web patterns:

- **Page title**: 24–28sp, `FontWeight.w700` (web: `text-3xl font-bold`)
- **Section title**: 14–16sp, `FontWeight.w600`
- **Body**: 14–16sp, `FontWeight.w400`
- **Muted/secondary**: 12–14sp, `FontWeight.w400` with muted color

---

## 3) Color system

### 3.1 Brand colors (hard accents)

Use the same brand identity as web:

- **Brand Purple**: `#7C3AED` (approx Tailwind `purple-600`)
- **Brand Blue**: `#2563EB` (approx Tailwind `blue-600`)
- **Brand Gradient**: Purple → Blue

### 3.2 Semantic colors (tokens)

Define a token set similar to the web “shadcn tokens”. Recommended Flutter `ColorScheme` mapping:

- **background**: app background (web `--background`)
- **surface**: cards/sheets/dialogs (web `--card` / `--popover`)
- **onSurface**: primary text (web `--foreground`)
- **primary / onPrimary**: primary CTA
- **secondary / onSecondary**: secondary surfaces (chips, subtle panels)
- **error / onError**: destructive actions / errors (web `--destructive`)
- **outline**: borders (web `--border`)

### 3.3 Suggested light/dark palettes

Use neutral UI tokens and keep brand accents consistent:

- **Light**
  - Background: `#FFFFFF`
  - Surface: `#FFFFFF`
  - Text: `#111827` (near-slate/neutral)
  - Muted text: `#6B7280`
  - Border/outline: `#E5E7EB`
  - Error: `#DC2626`
- **Dark**
  - Background: `#0B0B0C` / near-black neutral
  - Surface: `#111827` / deep neutral
  - Text: `#F9FAFB`
  - Muted text: `#9CA3AF`
  - Border/outline: `#374151`
  - Error: `#EF4444`

> Note: web already defines `.dark` tokens; Flutter should support `ThemeMode.system` and provide both schemes.

---

## 4) Spacing, radius, elevation, motion

### 4.1 Spacing scale

Use an 8pt grid (with 4pt increments):

- 4, 8, 12, 16, 24, 32

### 4.2 Radius

Web uses base radius ~10px. Use:

- **Default radius**: 10
- **Small**: 6–8
- **Large**: 12–16 (for large cards / sheets)

### 4.3 Elevation / shadows

Mirror web usage:

- **Cards**: subtle elevation (1–2)
- **Sidebar equivalent** (not used on mobile): heavier elevation (4–6)
- **Dialogs**: elevation 8+

### 4.4 Motion

- Use short, consistent durations:
  - **Fast**: 150–200ms (button/hover feedback)
  - **Normal**: 250–300ms (route transitions, bottom sheet)
- Use easing similar to web’s `ease-in-out`.

---

## 5) Layout patterns (mobile)

### 5.1 App shell

- **Bottom navigation** for primary modules:
  - Dashboard, Products, Inventory, Sales, More
- **Top area** of each tab:
  - Page title + subtitle (optional)
  - Global `SubscriptionBanner` displayed above page content when expired

### 5.2 Screen composition

Match the web “cards + tables” structure using mobile-friendly equivalents:

- **Cards**: summary/KPI cards, form sections, filter sections
- **Lists**: replace tables with `ListView` rows + trailing actions
- **Detail pages**: key metrics as cards, then item lists

### 5.3 Filters

- Use a **Filter Bottom Sheet**:
  - Search field (if needed)
  - Chips/toggles for common filters
  - “Clear” and “Apply” actions

---

## 6) Component standards (Flutter equivalents)

### 6.1 Buttons

Map to web button variants:

- **Primary**: `FilledButton` (primary background)
- **Secondary**: `FilledButton.tonal` or `OutlinedButton` depending on emphasis
- **Outline**: `OutlinedButton`
- **Ghost**: `TextButton` (minimal)
- **Destructive**: `FilledButton` with `error` color

Rules:
- Minimum height: **48dp**
- Icon buttons: 40–48dp square, clear semantics.

### 6.2 Badges / status pills

Use small `Container` pills:

- Default: primary background + onPrimary text
- Secondary: muted surface + onSurface
- Destructive: error background + onError text
- Outline: border + transparent background

Used for: Active/Inactive, Stock state, Subscription state, Discount/Over Price flags.

### 6.3 Cards

Use `Card` with:

- Rounded corners (radius 10–12)
- Border (outline color) *or* subtle elevation (choose one consistently; web uses border + shadow-sm)

### 6.4 Forms

Use `TextFormField` + validation:

- Consistent height and padding
- Error text below field
- Required indicator on labels
- Use pickers for:
  - Dates / date ranges
  - Select fields (product, location, category)

### 6.5 Dialogs & bottom sheets

- **Confirmations**: `showDialog` with concise title + description + Cancel/Confirm
- **Forms**: prefer **modal bottom sheets** (`showModalBottomSheet`) for quick actions (adjust stock, record payment)
- **Large forms**: full-screen route (create sale, create product)

### 6.6 Tables → Lists

Web uses tables; in Flutter:

- Use `ListTile` / custom row widgets with:
  - Primary line: title
  - Secondary lines: metadata
  - Trailing: amount/status badge/actions
- For dense “grid-like” data (inventory entries), use a `Card` per row or a two-column layout inside each row.

---

## 7) UX states (required patterns)

### 7.1 Loading

- Use shimmer skeletons for:
  - KPI card grids
  - Lists (5–10 skeleton rows)
- Use small spinners only for button-level actions.

### 7.2 Empty

- Standard empty view:
  - Icon (brand tint)
  - Title + short description
  - Primary CTA if applicable (e.g., “Add Product”, “Record Sale”)

### 7.3 Errors

- Standard error view:
  - “Couldn’t load …”
  - Retry button
- Subscription-expired errors:
  - Show the **SubscriptionBanner** and disable write actions.

### 7.4 Notifications

- Use `ScaffoldMessenger` snackbars:
  - Success: green
  - Error: red
  - Info: neutral/brand

---

## 8) Brand surfaces to mirror web

### 8.1 Auth screens + error shells

Web uses a soft gradient background (`from-purple-50 to-blue-50`). In Flutter:

- Use a background `Container` with a linear gradient from a light purple tint to a light blue tint.
- Center a single auth `Card` with:
  - Logo mark: circle with brand gradient and “G”
  - Title + subtitle
  - Full-width primary CTA button

#### Login screen (Flutter)

- **Layout**
  - Gradient background + centered card (max width ~420dp)
  - Email + password fields with clear validation
  - Primary CTA: “Sign in”
  - Secondary link: “Register as Merchant”
- **Feedback**
  - Loading state on CTA (disable button + inline spinner)
  - Errors shown inline and as snackbar (avoid duplicating long messages)

#### Merchant signup screen (Flutter)

- **Layout**
  - Same gradient background + larger card (or scrollable full-screen)
  - Two sections:
    - Business info: name, email, phone, address
    - Admin user: first/last name, password, confirm password
  - Primary CTA: “Register”
  - Secondary link: “Already have an account? Sign in”
- **Feedback**
  - On success: show message “Awaiting approval” then route to login.
  - Validate password match and min length (>= 6) to match current web UI.

### 8.2 App “main content” background

Web content uses `from-slate-50 to-blue-50/30`. In Flutter:

- Use a very light neutral background with a subtle blue tint at the top-right or bottom-right.

---

## 9) ThemeData implementation (reference)

Below is a reference snippet (adjust to your actual palette and typography):

```dart
ThemeData buildLightTheme() {
  const brandPurple = Color(0xFF7C3AED);
  const brandBlue = Color(0xFF2563EB);

  final scheme = ColorScheme.fromSeed(
    seedColor: brandPurple,
    brightness: Brightness.light,
  ).copyWith(
    primary: brandPurple,
    secondary: brandBlue,
    error: const Color(0xFFDC2626),
    background: const Color(0xFFFFFFFF),
    surface: const Color(0xFFFFFFFF),
    outline: const Color(0xFFE5E7EB),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.background,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
  );
}
```

---

## 10) Component checklist (to keep consistency)

Implement these once in `core/ui/widgets/` and reuse everywhere:

- `AppScaffold` (handles subscription banner)
- `AppCard`
- `PrimaryButton`, `SecondaryButton`, `DestructiveButton`, `GhostButton`
- `StatusBadge`
- `AppTextField`
- `AppDateRangeField`
- `AppLoadingSkeleton`
- `AppEmptyView`
- `AppErrorView`
- `ConfirmDialog`
- `FilterBottomSheet`


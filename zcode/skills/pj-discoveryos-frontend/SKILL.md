---
name: discoveryos-frontend
description: Build frontend interfaces (React/Next.js components, pages, dashboards, internal lab tools, data views) that conform to the DiscoveryOS "暖纸/暖夜" (Warm Paper / Warm Night) design system — a restrained, flat, sharp-cornered shadcn/ui + Tailwind v4 theme with vermilion-blue (朱砂蓝) as the primary, 2px radius, and typography-as-semantics. Use this skill whenever building or styling ANY frontend for the lab / internal tools, or whenever the user mentions DiscoveryOS, 暖纸, 暖夜, 朱砂蓝/vermilion, the lab design system, or asks for UI that matches the team's existing look — even if they don't name the system explicitly. For these contexts this skill takes precedence over generic "be bold and original" design advice; here the goal is consistency and restraint, not novelty.
---

# DiscoveryOS Frontend (暖纸 / 暖夜)

This skill builds production frontends that match the DiscoveryOS design system used across the lab's internal tools. The system has a strong, opinionated point of view, and the value of this skill is *fidelity to that point of view*. Do not improvise a new aesthetic. When in doubt, choose the more restrained option.

## The one-paragraph mental model

DiscoveryOS looks like **a clean technical document, not a SaaS landing page**. Warm paper background, ink-colored text, one disciplined accent (朱砂蓝 / vermilion-blue), nearly flat surfaces, and 2px corners everywhere. Hierarchy comes from **type, weight, and spacing — not from boxes, shadows, and color**. If a screen feels "designed" in a flashy way, it is wrong. If it feels calm, legible, and slightly editorial, it is right.

## Non-negotiable rules

These are the rules that, if broken, make output stop looking like DiscoveryOS. Treat them as hard constraints.

1. **Always wire colors through the semantic tokens, never hardcode hex.** Use `bg-background`, `text-foreground`, `bg-card`, `text-primary`, `border-border`, `text-muted-foreground`, etc. The theme file defines both 暖纸 (light) and 暖夜 (dark); hardcoding a hex breaks dark mode and the brand. The only place raw hex lives is `assets/globals.css`.
2. **2px corners. That's the whole story.** `rounded-sm` / `rounded-md` / `rounded-lg` all resolve to ~2px by design. Do NOT reach for `rounded-xl`, `rounded-2xl`, or `rounded-full` (the one exception: true circles like avatars/status dots may use `rounded-full`). Pills and big soft cards are off-brand.
3. **Flat by default.** Most surfaces have NO shadow — they separate by a 1px `border-border` and/or a different surface token (`card` / `muted` / `secondary`). Shadows are reserved for things that genuinely float above the page: popovers, dropdowns, modals, toasts. Use only `shadow-lg` (overlays) and `shadow-2xl` (modals). Never put a shadow on a static card or button.
4. **One accent, used sparingly.** 朱砂蓝 (`primary`) marks the single most important action or the active state — not every interactive element. Most buttons are secondary/ghost/outline. A screen with five blue buttons is wrong.
5. **Typography is the hierarchy.** Serif (`font-serif`, Cormorant Garamond) for display/large headings where you want an editorial feel; sans (`font-sans`, Inter) for UI and body; mono (`font-mono`, JetBrains Mono) for numbers, code, IDs, timestamps, data. Reach for weight and size before you reach for color or a box.
6. **Spacing is a 4px grid.** Use multiples of 4 (Tailwind `1,1.5,2,2.5,3,3.5,4,5,6,8,10,14,20` → 4–80px). The canonical scale is 4/6/8/10/12/14/16/20/24/32/40/56/80px. Be generous with whitespace; density is fine but it must be *regular*.
7. **Dark mode (暖夜) is warm, not inverted.** It is already handled by the tokens — but never assume dark = pure black or pure white text. If you add custom colors, keep backgrounds warm (~10° warm bias, like `#1a1815`) and text warm-white (`#ebe6dc`), never `#000`/`#fff`. The accent hue (H 214°) stays identical between modes; only its lightness changes.

If a request pushes against one of these (e.g. "make the cards pop with big rounded corners and a drop shadow"), build the DiscoveryOS-correct version and briefly note the system constraint, rather than silently breaking the system.

## Tech stack assumptions

- **Next.js (App Router) + React + TypeScript**, **Tailwind CSS v4**, **shadcn/ui** components.
- Dark mode via `next-themes` toggling a `.dark` class on `<html>`; the theme also falls back to `prefers-color-scheme`.
- The theme is the single source of truth in `app/globals.css`. Use `assets/globals.css` from this skill verbatim. If the user is in a plain HTML/CSS or non-Next context, adapt the same tokens but keep every rule above.

When you start a new project or page, the first move is to install/confirm the theme (see Workflow), then build with utility classes that reference the tokens.

## Token cheat-sheet (light → use the semantic name, not the hex)

| Role | Token (class) | 暖纸 light | 暖夜 dark | Use for |
|---|---|---|---|---|
| Page bg | `bg-background` | `#fdfcf8` | `#1a1815` | the page / app shell |
| Body text | `text-foreground` | `#1a2332` | `#ebe6dc` | default text (ink) |
| Card | `bg-card` | `#ffffff` | `#252320` | L1 containers (equal weight) |
| Popover/menu | `bg-popover` | `#ffffff` | `#252320` | floating menus, tooltips |
| Primary | `bg-primary` / `text-primary` | `#1554a8` | `#7aa5db` | the ONE key action / active state |
| On-primary | `text-primary-foreground` | `#ffffff` | `#1a1815` | text on a primary fill |
| Secondary | `bg-secondary` | `#f7f4ec` | `#252320` | low-emphasis buttons, hover bleed |
| Muted | `bg-muted` | `#fafaf7` | `#1f1d1a` | subtle wells, table zebra, code bg |
| Muted text | `text-muted-foreground` | `#7a8394` | `#8a8478` | captions, hints, secondary labels |
| Accent (hover) | `bg-accent` | `#f7f4ec` | `#252320` | hover/active backgrounds |
| Destructive | `bg-destructive` | `#c03030` | `#e57878` | delete/error only |
| Border / rule | `border-border` | `#e8e4d9` | `#3a3631` | the primary separator (use this a lot) |
| Focus ring | `ring-ring` | `#1554a8` | `#7aa5db` | `:focus-visible` outline |

Charts (`--chart-1..5`): vermilion `#1554a8`, light-blue `#88addd`, success-green `#6b7a3a`, warning-gold `#a8864b`, deep-vermilion `#0c3c80`. Use `chart-3`/`chart-4` for semantic success/warning; never invent new status colors.

Semantic intents: **success** ≈ `#6b7a3a` (olive), **warning** ≈ `#a8864b` (gold), **error/destructive** = `destructive`. Keep these muted and earthy — no neon green/red/yellow.

## Workflow

1. **Read the references before building anything non-trivial.** For the reasoning behind the rules (so you apply them correctly to novel cases), read `references/design-principles.md`. For concrete, copy-ready component recipes (buttons, cards, inputs, tables, sidebar, badges, empty states, etc.), read `references/component-patterns.md`. Skim the patterns file even for "simple" components — it encodes the exact class strings that keep things on-brand.
2. **Install the theme.** Copy `assets/globals.css` into the project's `app/globals.css` (or import it). Confirm fonts are loaded: Inter, Cormorant Garamond, JetBrains Mono (e.g. via `next/font` or a Google Fonts link). Don't substitute other fonts.
3. **Compose with shadcn/ui** where a component exists; style with token-referencing utilities. Match the patterns file for variants and states.
4. **Self-check against the Non-negotiable rules** before finishing: no stray hex, no fat corners, no decorative shadows, one accent, type-driven hierarchy, 4px spacing, warm dark mode.
5. **Verify accessibility:** the token pairings are pre-checked (primary text hits AA 5.6:1, muted-foreground AA ~4.5:1). If you introduce new color combinations, keep body text ≥ 4.5:1 and large text ≥ 3:1.

## What "good" looks like (quick gut-check)

- A dashboard reads like a well-set report: clear headings (often serif), tabular numbers in mono, generous margins, hairline rules between sections, almost no shadows, a single blue primary button per view.
- Buttons are mostly quiet (outline/ghost/secondary); the blue one is the exception.
- Cards are white-on-paper separated by thin warm borders, not floating drop-shadow boxes.
- Toggling dark mode feels like the same room at night — warm, dim, legible — not a different app.

Read `references/design-principles.md` and `references/component-patterns.md` now if you're about to build UI.

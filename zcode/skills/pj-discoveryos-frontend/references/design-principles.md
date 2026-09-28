# DiscoveryOS · Design Principles (the "why")

Read this when you need to apply the system to a situation the cheat-sheet doesn't directly cover. The rules in SKILL.md are derived from these principles; understanding them lets you make correct calls on novel components.

## 1. The document metaphor

DiscoveryOS treats the screen as **a printed technical document**, not an app chrome. Think a beautifully typeset paper or lab notebook, not a dashboard template. Consequences that flow from this:

- **Paper, not panels.** The background (`#fdfcf8`) is warm off-white, like good paper stock — never stark `#fff`, never gray. Content sits *on* the paper; it isn't boxed into floating cards stacked on a gray canvas.
- **Rules, not boxes.** A 1px warm rule (`border-border`) is the default way to separate things — like horizontal rules in a document. Heavy outlined boxes and nested cards-in-cards are off-brand.
- **Ink, not black.** Text is ink (`#1a2332`), a desaturated blue-black, not `#000`. It reads softer and more "printed."

When you're unsure how to structure a region, ask: *how would this look set in a thoughtful document?* Usually the answer is "a heading, some space, the content, maybe a hairline rule" — not "a card with a shadow."

## 2. Hierarchy by typography, weight, and space — not decoration

The system deliberately strips the usual decorative hierarchy tools (big shadows, color blocks, rounded pills) so that **type and spacing carry the structure**. This is why fonts are described as *semantic*:

- `font-serif` (Cormorant Garamond): editorial display — page titles, section headers, hero numbers, anything that should feel composed and human. Serif at large sizes gives DiscoveryOS its distinctive "considered" character. Don't use it for small UI text.
- `font-sans` (Inter): the workhorse — UI labels, body copy, buttons, form text. Neutral and legible.
- `font-mono` (JetBrains Mono): data — numbers in tables, IDs, hashes, timestamps, code, metrics, kbd. Mono signals "this is a precise value." Tabular figures keep columns aligned.

Practical hierarchy ladder (sans body = 14–16px):
- Page title: serif, ~28–40px, normal/medium weight.
- Section heading: serif or sans-semibold, ~18–22px.
- Subsection / card title: sans, 15–16px, medium/semibold.
- Body: sans, 14–16px, normal, `text-foreground`.
- Caption / meta: sans, 12–13px, `text-muted-foreground`.
- Data / metric value: mono, size to taste, often `text-foreground` with mono giving the precision cue.

Reach for **weight and size and whitespace** before color. Color (the blue) is a scarce signal, not a hierarchy tool.

## 3. Flatness and the shadow budget

The system is **flat by intent**. Elevation is meaningful, so it's rationed:

- **Z-level 0 (the page and everything in normal flow): no shadow.** Cards, panels, table rows, sidebars — separated by surface tokens and borders only.
- **Z-level 1 (genuinely floating, transient): shadow allowed.** Popovers, dropdown menus, tooltips, command palettes → `shadow-lg` (this maps to the system's `--shadow-overlay`).
- **Z-level 2 (modal, blocks the page): `shadow-2xl`** (maps to `--shadow-modal`), usually with a backdrop.

The small shadow steps (`shadow-2xs` … `shadow-md`) exist in the theme for completeness but the system "almost never uses them." Don't sprinkle `shadow-sm` on cards to make them "pop" — that's the single most common way to make output look generic-SaaS instead of DiscoveryOS.

To make something feel distinct without a shadow: change its surface (`card` vs `muted` vs `secondary`), add a border, or add space around it.

## 4. The accent is precious (朱砂蓝)

`primary` is 朱砂蓝 — vermilion-blue, hue 214°. It is the system's single voice of emphasis. Discipline:

- **One primary action per view.** The main CTA, the submit, the "create." Everything else is secondary, outline, or ghost.
- **Active/selected state** can use the accent (e.g. active nav item gets `text-primary` and/or a left vermilion rule), because "active" is a kind of emphasis.
- Links may use `text-primary`.
- Do **not** color section headers, icons, borders, or backgrounds blue just for decoration. Blue means "this matters most / this is active."

The hue is held constant across light and dark (H 214°); only lightness shifts (L37% → L67%) so the brand reads identically at night. If you ever need a custom tint, rotate lightness, never hue.

## 5. 暖夜 (Warm Night) is a re-expression, not an inversion

Dark mode is designed, not computed. Principles:

- Background keeps a **~10° warm bias** (`#1a1815`), never neutral `#1a1a1a` or black. It should feel like dim warm light, not a void.
- Text is **warm white** (`#ebe6dc`), never `#fff`, to avoid the "visual burn" of max-contrast white on dark.
- The accent **lightens** (`#7aa5db`) so it stays legible on dark surfaces while keeping the exact hue.
- Surfaces *lift* with slightly lighter warm grays (`card #252320`) rather than the light-mode trick of going whiter.
- Shadows deepen (more opaque black) because the surrounding field is dark.

All of this is already in the tokens — so the practical instruction is simply: **use the tokens and dark mode is correct for free.** Only when you hand-author a color do you need to apply these principles yourself.

## 6. Restraint as the aesthetic

The throughline: DiscoveryOS earns its look by what it *refuses*. No gradients-for-decoration, no glassmorphism, no neon, no big rounded friendly blobs, no drop-shadow everything, no rainbow of status colors. The earthy semantic palette (olive success, gold warning, brick error) reinforces the "printed, serious, calm" register.

When a design decision is ambiguous, the more restrained, more document-like, more typographic option is almost always the DiscoveryOS-correct one.

## 7. Accessibility is baked in

The shipped pairings are pre-checked: `primary-foreground` on `primary` ≈ AA 5.6:1; `muted-foreground` on its background ≈ AA 4.5–4.6:1; dark-mode `primary-foreground` on `primary` reaches AAA. So sticking to the token pairs keeps contrast safe. If you create a new pairing, verify body text ≥ 4.5:1 and large/bold text ≥ 3:1, and never rely on the blue accent alone to convey state (pair it with text, weight, or an icon).

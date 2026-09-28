# DiscoveryOS · Component Patterns

Copy-ready recipes. Every class string here references theme tokens so light/dark both work. Adjust spacing to the 4px scale; keep corners at the default ~2px (do not add `rounded-xl`+). These assume Tailwind v4 + the DiscoveryOS `globals.css` and, where noted, shadcn/ui.

## Contents
1. App shell & page header
2. Buttons (the variant ladder)
3. Cards / panels
4. Inputs & forms
5. Tables & data
6. Sidebar / navigation
7. Badges & status
8. Tabs & segmented controls
9. Dropdowns, popovers, modals (the shadow exceptions)
10. Empty states, toasts, misc
11. Charts

---

## 1. App shell & page header

```tsx
<div className="min-h-screen bg-background text-foreground font-sans">
  <header className="border-b border-border">
    <div className="mx-auto max-w-7xl px-6 py-4 flex items-center justify-between">
      <h1 className="font-serif text-2xl">DiscoveryOS</h1>
      {/* one primary action max */}
      <Button>New run</Button>
    </div>
  </header>
  <main className="mx-auto max-w-7xl px-6 py-8 space-y-8">{/* ... */}</main>
</div>
```

Page title block — serif title, muted subtitle, hairline below:

```tsx
<div className="space-y-1 pb-6 border-b border-border">
  <h2 className="font-serif text-3xl">Experiment results</h2>
  <p className="text-sm text-muted-foreground">Last updated 2 minutes ago · 1,284 records</p>
</div>
```

Note the structure: heading → space → hairline rule. No card, no shadow.

## 2. Buttons (the variant ladder)

Most buttons are quiet. Reserve the filled blue `primary` for the single most important action on the view.

```tsx
// PRIMARY — one per view. The vermilion voice.
<button className="inline-flex items-center justify-center gap-2 rounded-md
  bg-primary text-primary-foreground px-4 py-2 text-sm font-medium
  transition-colors hover:bg-primary/90
  focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background
  disabled:opacity-50 disabled:pointer-events-none">
  Save changes
</button>

// SECONDARY / DEFAULT — the workhorse. Quiet, warm fill.
<button className="... rounded-md bg-secondary text-secondary-foreground px-4 py-2 text-sm font-medium
  hover:bg-accent ...">Cancel</button>

// OUTLINE — bordered, transparent. Good for toolbars.
<button className="... rounded-md border border-border bg-transparent text-foreground px-4 py-2 text-sm font-medium
  hover:bg-accent ...">Export</button>

// GHOST — no chrome until hover. For dense rows of actions.
<button className="... rounded-md bg-transparent text-foreground px-3 py-2 text-sm
  hover:bg-accent ...">Edit</button>

// DESTRUCTIVE — delete/error only.
<button className="... rounded-md bg-destructive text-destructive-foreground px-4 py-2 text-sm font-medium
  hover:bg-destructive/90 ...">Delete</button>
```

With shadcn `Button`, map: primary→`default`, secondary→`secondary`, outline→`outline`, ghost→`ghost`, destructive→`destructive`. Sizes via padding on the 4px grid (sm `px-3 py-1.5`, default `px-4 py-2`).

## 3. Cards / panels

Flat container = white surface on paper, separated by a thin warm border. **No shadow.**

```tsx
<div className="rounded-md border border-border bg-card text-card-foreground p-6 space-y-4">
  <div className="space-y-1">
    <h3 className="text-base font-semibold">Model accuracy</h3>
    <p className="text-sm text-muted-foreground">Validation set, last epoch</p>
  </div>
  <p className="font-mono text-3xl">94.2%</p>
</div>
```

Sectioning inside a card uses a hairline, not nesting:

```tsx
<div className="rounded-md border border-border bg-card divide-y divide-border">
  <div className="p-4">Row A</div>
  <div className="p-4">Row B</div>
</div>
```

Need a subtle "well" (e.g. code, callout)? Use `bg-muted` instead of a shadow:

```tsx
<pre className="rounded-md bg-muted p-4 font-mono text-sm overflow-x-auto">{code}</pre>
```

## 4. Inputs & forms

```tsx
<label className="space-y-1.5 block">
  <span className="text-sm font-medium text-foreground">Run name</span>
  <input
    className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm
      text-foreground placeholder:text-muted-foreground
      focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background
      disabled:opacity-50"
    placeholder="experiment-001" />
  <span className="text-xs text-muted-foreground">Use lowercase with hyphens.</span>
</label>
```

- Focus = the vermilion `ring-ring`, 2px, offset from the field. This is the system's focus signature.
- Error field: add `border-destructive` and a `text-destructive` message below; keep the field text normal-colored.
- Selects, textareas, checkboxes, radios follow the same border/ring/`bg-background` recipe at ~2px corners. Checkboxes/radios checked-state fill with `bg-primary`.

## 5. Tables & data

The system's home turf. Mono for values, hairline rules, optional muted zebra, generous row height.

```tsx
<table className="w-full text-sm border-collapse">
  <thead>
    <tr className="border-b border-border text-left">
      <th className="py-2 pr-4 font-medium text-muted-foreground">Run</th>
      <th className="py-2 pr-4 font-medium text-muted-foreground">Status</th>
      <th className="py-2 pr-4 font-medium text-muted-foreground text-right">Accuracy</th>
    </tr>
  </thead>
  <tbody>
    <tr className="border-b border-border hover:bg-accent/60 transition-colors">
      <td className="py-3 pr-4 font-mono">exp-014</td>
      <td className="py-3 pr-4"><StatusBadge intent="success">done</StatusBadge></td>
      <td className="py-3 pr-4 text-right font-mono">94.2%</td>
    </tr>
  </tbody>
</table>
```

- Numeric columns: `text-right font-mono` so digits align.
- Header labels: `text-muted-foreground`, medium weight, small. Let the data be the loud part.
- Zebra (optional, dense tables): `odd:bg-muted/40` on rows instead of borders.

## 6. Sidebar / navigation

Uses the dedicated `sidebar-*` tokens. Active item = vermilion text + a left rule; inactive = muted, hover bleeds to accent.

```tsx
<aside className="w-60 shrink-0 bg-sidebar text-sidebar-foreground border-r border-sidebar-border">
  <nav className="p-3 space-y-1">
    {/* active */}
    <a className="flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium
      border-l-2 border-primary text-primary bg-sidebar-accent">
      Experiments
    </a>
    {/* inactive */}
    <a className="flex items-center gap-3 rounded-md px-3 py-2 text-sm
      border-l-2 border-transparent text-muted-foreground
      hover:bg-sidebar-accent hover:text-sidebar-foreground transition-colors">
      Datasets
    </a>
  </nav>
</aside>
```

## 7. Badges & status

Quiet, bordered or low-fill. Earthy semantic colors via the chart tokens, never neon.

```tsx
// neutral
<span className="inline-flex items-center rounded-md border border-border bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground">draft</span>
// primary / active
<span className="... bg-primary/10 text-primary border border-primary/20">running</span>
// success  (olive)
<span className="... text-[--chart-3] border" style={{borderColor:'color-mix(in srgb, var(--chart-3) 25%, transparent)', background:'color-mix(in srgb, var(--chart-3) 10%, transparent)'}}>done</span>
// destructive
<span className="... bg-destructive/10 text-destructive border border-destructive/20">failed</span>
```

For status dots, `rounded-full` is fine (true circle): `<span className="size-2 rounded-full bg-[--chart-3]" />`.

## 8. Tabs & segmented controls

Underline tabs fit the document feel best (no pill backgrounds):

```tsx
<div className="border-b border-border flex gap-6">
  <button className="py-2 text-sm font-medium border-b-2 border-primary text-foreground">Overview</button>
  <button className="py-2 text-sm border-b-2 border-transparent text-muted-foreground hover:text-foreground">Logs</button>
</div>
```

If you need a segmented control, use a `bg-muted` track with the active segment as a `bg-card` 2px-corner tile (still no shadow).

## 9. Dropdowns, popovers, modals — the shadow exceptions

These genuinely float, so they get a shadow.

```tsx
// Popover / dropdown menu content
<div className="rounded-md border border-border bg-popover text-popover-foreground p-1 shadow-lg">
  <button className="w-full text-left rounded-md px-3 py-2 text-sm hover:bg-accent">Rename</button>
  <button className="w-full text-left rounded-md px-3 py-2 text-sm hover:bg-accent">Duplicate</button>
  <div className="my-1 h-px bg-border" />
  <button className="w-full text-left rounded-md px-3 py-2 text-sm text-destructive hover:bg-accent">Delete</button>
</div>

// Modal (with backdrop)
<div className="fixed inset-0 bg-foreground/20" /> {/* warm ink scrim, not pure black */}
<div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2
  w-full max-w-lg rounded-md border border-border bg-card p-6 shadow-2xl space-y-4">
  <h3 className="font-serif text-xl">Delete experiment?</h3>
  <p className="text-sm text-muted-foreground">This action cannot be undone.</p>
  <div className="flex justify-end gap-2 pt-2">
    <button className="rounded-md bg-secondary px-4 py-2 text-sm hover:bg-accent">Cancel</button>
    <button className="rounded-md bg-destructive text-destructive-foreground px-4 py-2 text-sm hover:bg-destructive/90">Delete</button>
  </div>
</div>
```

`shadow-lg` for overlays, `shadow-2xl` for modals — these are the only two shadow utilities the system endorses.

## 10. Empty states, toasts, misc

Empty state — centered, serif line, muted helper, one action:

```tsx
<div className="text-center py-16 space-y-3">
  <p className="font-serif text-xl text-foreground">No experiments yet</p>
  <p className="text-sm text-muted-foreground">Create your first run to see results here.</p>
  <div className="pt-2"><Button>New run</Button></div>
</div>
```

Toast — floating, so `shadow-lg`; keep it a card with a thin border and an accent or semantic left rule.

`kbd` / inline code: `font-mono` + `bg-muted` + `border-border` + 2px corners.

## 11. Charts

Use the five chart tokens in order; they're tuned for both modes. Keep chart chrome light — thin `border-border` axes/gridlines, `muted-foreground` labels, no heavy backgrounds.

```ts
const palette = ['var(--chart-1)','var(--chart-2)','var(--chart-3)','var(--chart-4)','var(--chart-5)'];
// chart-1 vermilion (primary series), chart-3 = success/olive, chart-4 = warning/gold
```

For Recharts/Chart.js: set series colors from `palette`, grid/axis stroke to `var(--border)`, tick text fill to `var(--muted-foreground)`, and let the surface stay transparent over the page/card. Single-series charts default to `chart-1`.

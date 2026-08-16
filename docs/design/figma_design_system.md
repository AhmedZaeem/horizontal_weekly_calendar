# Horizontal Weekly Calendar 2.0 — Figma Design System

**Status:** Archived; Figma removed from the 2.0 delivery process  
**Figma file:** https://www.figma.com/design/2dlM9mtELLwsQ1QAdCKOgi  
**Run ID:** `horizontal-calendar-v2-2026-08-04`

## Source-of-truth order

> Archived on 2026-08-04. The package implementation, product specification,
> automated tests, and runnable gallery are now the visual source of truth.
> No further Figma work is planned for 2.0.0.

1. The approved 2.0 specification defines behavior, accessibility, and platform adaptation.
2. The Flutter theme implementation and Figma variables share semantic names and values.
3. Official Material 3 and Apple iOS/iPadOS 26 kits are visual references for platform conventions, not dependencies of the Flutter package.
4. The 1.3 code is a compatibility reference only; its hard-coded colors and fixed dimensions do not constrain 2.0.

## Phase 0 findings

### Existing code

- The package has no design-token layer or reusable `ThemeExtension`.
- Its default visual vocabulary is Material blue, 12/16/18-point text, circular selected dates, 24-point navigation icons, and fixed day sizes.
- Styling is duplicated across the horizontal strip, table calendar, and event calendar.
- The platform font is inherited implicitly; there are no explicit Material, Cupertino, or neutral presets.
- The reusable visual concepts are date cell, month header, navigation action, event marker, time label, and event card.
- There are no Code Connect mappings or Figma URLs in the repository.

### New Figma file

- One empty page named `Page 1`.
- Zero variables, collections, components, text styles, effect styles, or paint styles.
- Exact usable platform fonts include Roboto, SF Pro, and Inter.
- The authenticated Starter plan may limit variable collections to one mode, so light and dark semantics will use separate one-mode collections unless a mode-creation probe proves two modes are available.

### Available libraries

- Material 3 Design Kit: date picker and icon-button component sets are available.
- Apple iOS and iPadOS 26: date/time picker and Liquid Glass symbol/text controls are available.
- Simple Design System: calendar and calendar-button component sets are available.
- These calendar components do not provide the horizontal, foldable, event-aware API required by 2.0. They will be used for visual comparison; local calendar components will be purpose-built.

## Locked Phase 1 token proposal

| Collection | Mode strategy | Proposed content |
| --- | --- | --- |
| `Primitives` | `Default` | Neutral, indigo, cyan, success, warning, error, black, and white raw values; hidden scopes. |
| `Color / Light` | `Light` | Background, surface, elevated surface, text, muted text, border, accent, on-accent, today, disabled, focus, event, and status semantics. |
| `Color / Dark` | `Dark` | Dark equivalents of the same semantic roles. |
| `Spacing` | `Default` | 0, 2, 4, 8, 12, 16, 20, 24, and 32 logical-pixel steps. |
| `Radius` | `Default` | 0, 4, 8, 12, 16, 22, and full/pill radii. |
| `Size` | `Default` | 4/6/8 markers, 20/24 icons, 44 Cupertino target, 48 Material target, and compact/comfortable day-cell sizes. |

The brand direction is calm indigo with a restrained cyan event accent. Platform presets change shape, typography, control treatment, and motion—not only color.

## Typography proposal

| Preset | Font | Styles |
| --- | --- | --- |
| Material | Roboto | Title, month, weekday, day, label, event |
| Cupertino | SF Pro | Title, month, weekday, day, label, event |
| Neutral | Inter | Title, month, weekday, day, label, event |

Each family will use verified Figma font style names. Flutter will use ambient platform typography by default and allow overrides.

## Effect styles

- `Elevation / Material / Resting`
- `Elevation / Material / Raised`
- `Material / Cupertino / Glass`
- `Elevation / Neutral / Soft`
- `Focus / Accessible`

## Component scope

Atoms are completed and validated before composed calendars.

| Component | Planned axes | Notes |
| --- | --- | --- |
| `Date Cell / Material` | State × Density | Default, today, selected, disabled, range-middle, outside; compact/comfortable. |
| `Date Cell / Cupertino` | State × Density | Apple typography, 44-point targets, softer selection and focus treatment. |
| `Date Cell / Neutral` | State × Density | Platform-independent presentation. |
| `Calendar Header` | Style × Density | Month/year title, previous/next, today, and optional fold action. |
| `Fold Handle` | Style × State | Collapsed/expanded and default/pressed treatment. |
| `Event Marker` | Style × Kind | Dot, count, and compact bar forms. |
| `Event Card` | Style × Kind × State | Timed/all-day and default/selected forms. |
| `Horizontal Calendar` | Style × Theme × Density | Flagship seven-day composition using component instances. |
| `Foldable Calendar` | Style × Theme × Fold | Shared collapsed-week and expanded-month composition. |

Variant matrices over 30 combinations are split into platform-specific component sets.

## Documentation and gallery frames

- Foundations: colors, typography, spacing, radius, size, elevation, motion notes.
- Android/Material phone: flagship strip, event-rich strip, and foldable collapsed/expanded.
- iOS/Cupertino phone: flagship strip, event-rich strip, and foldable collapsed/expanded.
- Neutral/responsive: compact phone, tablet, RTL, dark, high contrast, and large text.
- Component pages: usage, anatomy, states, accessibility notes, and matching Flutter API names.

## Code ↔ Figma map

| Flutter concept | Figma concept | Resolution |
| --- | --- | --- |
| `HorizontalCalendarThemeData` semantic fields | Semantic color/spacing/radius/size variables | Use the same role names and values. |
| `CalendarStyle.material` | Material component variants and Roboto styles | Follow Material 3 targets and shape/motion conventions. |
| `CalendarStyle.cupertino` | Cupertino component variants and SF Pro styles | Follow Apple control sizes and restrained feedback. |
| `CalendarStyle.neutral` | Neutral variants and Inter styles | No platform-specific visual dependency. |
| `CalendarDayBuilderContext` states | Date Cell variant states | One-to-one state names where Figma permits. |
| `CalendarFoldState` | Foldable Calendar and Fold Handle state axes | Collapsed/expanded selection and focus remain identical. |
| Event segment kind/state | Event Marker and Event Card axes | Original typed event remains a data/API concern, not a Figma token. |

## Gap analysis

- **Code-only:** legacy constructor parameters and hard-coded widget styles. Resolution: retain in deprecated wrappers, do not reproduce as the new design architecture.
- **Figma-only:** official Material, Apple, and Simple DS assets. Resolution: visual/reference input and selective nested controls only; no package runtime dependency.
- **Missing in both:** semantic tokens, platform presets, foldable calendar, accessible states, event marker/card system, responsive/RTL/large-text examples. Resolution: create locally in Figma and Flutter from the approved 2.0 contract.
- **Conflicts:** none. The file is empty and the old code has no authoritative token system.

## Exclusions for the first design-system pass

- Full timeline grid and agenda-page components; these follow after the flagship and foldable components establish the foundations.
- Product-specific app chrome, branding, photography, or illustrations; the package must remain app-agnostic.
- A visual recurrence-rule editor or resource scheduler; both are outside the 2.0.0 specification.

## Phase 0 approval

Approval authorizes Figma Phase 1 foundations and test-first Flutter implementation against this design map. It does not authorize any git push, tag, pub.dev publish, or release.

**Approved by Ahmed Zaeem on 2026-08-04.**

# Motion and gesture guide

Every animated behaviour in the kit is described by one object,
`CalendarMotion`, passed through `CalendarAppearance.motion`. Omitting it keeps
each surface at its plain, non-animated behaviour; supplying it turns on a
coordinated choreography across page changes, selection, event indicators,
folds, and pointer response.

```dart
HorizontalCalendar(
  selectedDate: selectedDate,
  onDateSelected: selectDate,
  appearance: CalendarAppearance(motion: CalendarMotion.fluid()),
)
```

## Presets

| Preset | Character | Good for |
|---|---|---|
| `none()` | No motion at all | Deliberately static interfaces, test harnesses |
| `subtle()` | Short cross-fades | Dense productivity tools |
| `fluid()` | Balanced spatial continuity | General-purpose applications |
| `spring()` | Responsive, slightly springy | Native-feeling mobile apps |
| `playful()` | Elastic and expressive | Consumer, wellness, social |
| `snappy()` | Fast shared-axis steps | High-frequency navigation |
| `gentle()` | Unhurried vertical reveal | Journalling, reading, wellness |
| `cinematic()` | Layered directional parallax | Hero calendar surfaces |
| `premium()` | Depth, blur, and cover-flow | Polished consumer products |

Every preset is a starting point — `copyWith` replaces any token.

## The four behaviours motion turns on

### 1. Pages follow the drag

`HorizontalCalendar` and `MonthCalendar` normally step a whole page when a
gesture crosses a threshold. With motion supplied and `followGestures` on
(the default), a horizontal drag translates the surface continuously with
rubber-band resistance, and releasing settles it with `settleSpring`.

A step commits when **any** of these is true:

- the drag travelled at least `commitDistance` (56 logical pixels), or
- it travelled at least `commitFraction` of the surface width (18%), or
- it was released with at least `commitVelocity` (420 px/s).

Resistance triples when the direction is blocked by `bounds`, so the calendar
communicates the edge instead of silently ignoring the gesture.

Chronological direction is resolved after text direction, so a right-to-left
layout moves *visually* the other way and *chronologically* the same way.

### 2. Folds follow the drag

`FoldableCalendar` lays out both the week strip and the month grid and
interpolates its own height between them. Any intermediate fold position is a
real layout, so:

- dragging vertically expands or collapses the calendar under your finger;
- releasing settles on a spring, carrying the fling velocity;
- only the dominant surface receives taps and appears in the semantics tree.

Both surfaces are mounted only while the fold is moving. A settled calendar
builds exactly one calendar.

### 3. Selection is interruptible

A selection change drives a continuous `0..1` progress rather than replaying a
fixed animation. Tapping through dates faster than the transition completes
continues from the current position at a constant perceived speed. Alongside
the transform, the day cell interpolates its fill, outline, padding, and label
colours, so the change reads as one movement.

`CalendarSelectionTransition` picks the transform:

| Value | Selected date |
|---|---|
| `none` | No transform |
| `fade` | No transform; the colour cross-fade carries the change |
| `scale` | Scales up slightly |
| `slide` | Lifts upward |
| `bounce` | Scales up through the preset's curve, overshooting with `elasticOut` or `easeOutBack` |

### 4. Surfaces respond to touch

Enabled day cells, carousel cards, and event tiles scale to `pressScale` while
held and spring back on release, and to `hoverScale` under a pointer. Pointer
observation happens outside the gesture arena, so taps, drags, and ink
responses behave exactly as they would without it.

## Page transitions

`CalendarPageTransition` chooses how a new page replaces the old one:

`none` · `slide` · `fadeThrough` · `scale` · `sharedAxis` · `zoom` · `flip` ·
`parallax` · `coverFlow` · `verticalReveal` · `blurThrough`

The compositing-heavy ones — `blurThrough`, `coverFlow`, `flip`, and
`parallax` — paint into their own layer so a transition never repaints the rest
of the screen.

## Springs

`settleSpring` is used whenever a gesture-driven surface is released. Leaving
`spring` null derives a slightly under-damped description from `duration`,
which keeps settle timing consistent with the rest of the choreography. Supply
your own for full control:

```dart
CalendarMotion.fluid().copyWith(
  spring: SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 380,
    ratio: .82,
  ),
)
```

The same spring settles the carousel's snapping physics, so a card fling and a
page fling decelerate identically.

## Reduced motion

Every animated surface reads `MediaQuery.disableAnimations`:

- transition durations collapse to zero;
- drags stop following and revert to threshold stepping;
- press and hover feedback is skipped;
- the live timeline indicator stops gliding between minutes.

Selection, navigation, and every callback stay identical, so a reduced-motion
user reaches the same states through the same interactions.

`CalendarMotion.none()` produces the same result unconditionally, which is
useful for golden tests and deterministic screenshots.

## Performance notes

- Cards in a snapping carousel are wrapped in repaint boundaries, and the
  spotlight layout derives its emphasis from scroll position rather than
  discrete state, so scrolling repaints only the cards themselves.
- The day cell drives fill, outline, padding, and text colour from a single
  implicit animation instead of a stack of separate ones.
- A page of dates that fits its container is laid out edge to edge with no
  scroll viewport at all.

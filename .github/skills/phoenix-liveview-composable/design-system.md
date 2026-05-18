# Atomic Words UI Design System

## Core Philosophy

The app should feel:
- minimal
- calm
- functional
- lightweight
- readable
- fast

Avoid decorative UI.

The design must prioritize:
1. readability
2. spacing
3. hierarchy
4. usability

NOT visual effects.

---

# Visual Rules

## Shadows

Do NOT use:
- heavy shadows
- layered shadows
- neumorphism
- glowing effects
- card-like blocks organization 

Allowed:
- very subtle shadow only if necessary for elevation

Preferred:
- borders instead of shadows

Example:
- use `border border-zinc-200`
- avoid `shadow-xl`

---

# Border Radius

Use small or medium radius only.

Preferred:
- rounded-md
- rounded-lg

Avoid:
- overly rounded cards
- pill-heavy UI
- large bubble shapes

---

# Colors

Use a restrained palette.

## Primary Colors
- white
- zinc
- slate
- one accent color only

Avoid:
- gradients
- colorful cards
- random accent colors
- saturated backgrounds

---

# Layout

Use:
- clean spacing
- predictable alignment
- simple vertical layouts

Prefer:
- stack layouts
- grids only when necessary

Avoid:
- floating elements
- overlapping sections
- complex dashboards

---

# Typography

Typography is the primary visual tool.

Use:
- font weight
- spacing
- font size hierarchy

Instead of:
- colors
- effects
- decorations

Preferred hierarchy:
- title
- subtitle
- body
- caption

Avoid:
- giant headings
- decorative fonts

---

# Components

## Buttons

Buttons should:
- be simple
- have clear contrast
- avoid excessive padding

Preferred:
- solid primary button
- outline secondary button

Avoid:
- glowing buttons
- gradient buttons
- oversized CTA buttons

---

## Cards

Cards should:
- have subtle borders
- minimal padding
- clear structure

Avoid:
- glassmorphism
- floating card effects
- deep shadows

---

## Inputs

Inputs should:
- be clean
- have visible borders
- focus on readability

Avoid:
- animated borders
- flashy focus states

---

# Animation

Animations should be:
- subtle
- fast
- functional

Allowed:
- hover opacity
- slight transitions
- small fade-ins

Avoid:
- bouncing
- parallax
- dramatic motion
- excessive microinteractions

---

# Mobile First

Design for mobile first.

Priority:
1. mobile usability
2. tablet compatibility
3. desktop adaptation

---

# UX Principles

Always optimize for:
- fast understanding
- low cognitive load
- minimal clicks

Every screen should answer:
- what is this?
- what can I do here?
- what is the primary action?

---

# Inspiration

Preferred style references:
- Duocards
- Notion
- Linear
- Apple Settings
- modern minimal productivity apps

NOT:
- gaming UI
- dribbble-style concept art
- flashy startup landing pages

---

# Technical Notes

Framework:
- Phoenix LiveView

UI approach:
- simple HTML structure
- reusable components
- consistent spacing scale

Prefer:
- Tailwind utility classes
- reusable primitives

Avoid:
- deeply nested layouts
- overengineered UI abstractions

---

# Final Rule

If unsure:
choose simpler.

Minimalism is preferred over decoration.
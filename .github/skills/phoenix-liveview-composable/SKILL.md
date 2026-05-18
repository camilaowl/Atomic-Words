---
name: phoenix-liveview-composable
description: "Use when creating or refactoring Phoenix LiveView screens in Atomic Words, especially when a page is getting too large and should be split into smaller helper functions or separate component files. Covers composable LiveView structure, feature-scoped function components, extraction thresholds, and when to avoid or use LiveComponent."
argument-hint: "Describe the LiveView change or refactor you want"
user-invocable: true
disable-model-invocation: false
---

# Phoenix LiveView Composable Changes

Use this skill for LiveView work that should stay readable and modular instead of turning into a single large render block.

This skill is specific to Atomic Words and follows the repository's Phoenix guidance:
- Keep `Layouts.app` as the top-level wrapper in LiveView templates.
- Prefer regular function components over `LiveComponent` unless stateful lifecycle behavior is actually needed.
- Use `use AtomicWordsWeb, :html` for extracted component modules.
- Keep page-level LiveViews focused on data loading, event handling, and high-level layout.

## When To Use

- Creating a new LiveView page or a large new section inside an existing LiveView.
- Refactoring a long `render/1` function into smaller pieces.
- Extracting repeated or visually distinct UI blocks into reusable components.
- Deciding whether code should stay in one file, move to helper functions, or become a separate component module.

## Goals

- Keep each LiveView easy to scan.
- Separate page orchestration from presentational markup.
- Reuse UI pieces without introducing unnecessary `LiveComponent` complexity.
- Keep extracted code near the feature unless it is broadly reusable.

## Decision Rules

### 1. Keep it in the same LiveView file when

- The extracted section is only used once.
- The markup is small enough to understand quickly.
- The section mostly exists to make `render/1` easier to read.

In this case, create a private or local function component in the same module and keep the main `render/1` at a high level.

### 2. Create a separate component module when

- The section is visually substantial.
- The section is reused across multiple LiveViews or across multiple sections of one feature.
- The page file is growing because of multiple extracted sections.
- The extracted UI has its own attributes and can be reasoned about independently.

Prefer feature-scoped component files instead of dumping all shared code into one global file.

### 3. Use `LiveComponent` only when

- The extracted unit genuinely needs its own state, lifecycle callbacks, or targeted event handling.
- A plain function component would force awkward assign juggling or excessive parent event logic.

If the code is presentational, or only needs assigns passed in, do not use `LiveComponent`.

## Preferred File Layout

For page-specific composable UI, prefer one of these patterns.

### Same-file extraction

- Keep the main LiveView in `lib/atomic_words_web/live/.../*.ex`.
- Add small helper function components below `render/1` or near related code.

### Feature-scoped extracted components

- Create a module under a feature-oriented path such as `lib/atomic_words_web/components/<feature>/..._components.ex` when the pieces are reusable and clearly presentational.
- If the component is tightly coupled to a single LiveView area, a feature-local path under the LiveView area is also acceptable if it keeps the boundary clear.

Do not extract code into a separate file just to satisfy a rule. Extract only when it improves readability, reuse, or maintainability.

## Procedure

1. Read the target LiveView and identify whether the problem is length, repeated markup, mixed responsibilities, or event-handling complexity.
2. Split the screen into named sections such as header, empty state, filters, form, summary card, modal, or list row.
3. Decide for each section:
   - same-file helper function component
   - separate function component module
   - `LiveComponent` only if stateful behavior is needed
4. Refactor the main `render/1` so it reads like page composition rather than a wall of markup.
5. Keep event handlers, data loading, and routing in the LiveView unless a real component boundary justifies moving them.
6. When extracting to a separate module, define explicit `attr` declarations and keep the API narrow.
7. Validate that the resulting structure still follows the project's Phoenix conventions.

## Composition Heuristics

- Extract a same-file helper function when a section is more than a short block and has a clear name.
- Extract a separate module when a helper function starts carrying multiple assigns, repeated styling logic, or cross-page reuse.
- Prefer section names that describe intent, such as `account_profile_section`, `security_section`, or `empty_state`, rather than generic names like `section_one`.
- Avoid creating a component file for trivial wrappers that add no semantic value.
- Avoid moving business logic into presentational components.

## Output Shape

When applying this skill, produce LiveView code that:
- Leaves a concise top-level `render/1`.
- Uses small named function components for local structure.
- Uses separate files only where they materially improve reuse or readability.
- Keeps forms and event names explicit.
- Preserves existing router/auth conventions such as `@current_scope` usage.

## References

- [Extraction guidelines](./references/extraction-guidelines.md)
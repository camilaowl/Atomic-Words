# Extraction Guidelines For Atomic Words LiveViews

This reference supports the `phoenix-liveview-composable` skill.

## What the repo currently shows

- Many LiveViews currently keep the whole page in one `render/1` function.
- There are already extracted modules for some UI pieces.
- The repo includes both plain components and `LiveComponent` modules, but project guidance says to avoid `LiveComponent` unless there is a strong reason.

## Preferred extraction strategy

### Option A: same-file function component

Use this first when the section is local to one page.

Example shape:

```elixir
def render(assigns) do
  ~H"""
  <Layouts.app flash={@flash} current_scope={@current_scope}>
    <div class="space-y-8">
      <.profile_section user={@current_scope.user} editing_nickname={@editing_nickname} form={@nickname_form} />
      <.security_section user={@current_scope.user} />
    </div>
  </Layouts.app>
  """
end

attr :user, :map, required: true
attr :editing_nickname, :boolean, required: true
attr :form, :any, default: nil

defp profile_section(assigns) do
  ~H"""
  ...
  """
end
```

Use this when:
- the section is page-local
- the section has a clear name
- the main `render/1` becomes noticeably easier to scan

### Option B: separate function component module

Use this when the markup is substantial or reused.

Suggested project path:

```text
lib/atomic_words_web/components/account/account_components.ex
```

Suggested module shape:

```elixir
defmodule AtomicWordsWeb.AccountComponents do
  use AtomicWordsWeb, :html

  attr :user, :map, required: true

  def profile_summary(assigns) do
    ~H"""
    ...
    """
  end
end
```

Then call it from the LiveView with an alias or module-qualified component call.

Choose a separate module when:
- the component has a stable API
- more than one page or section can use it
- the LiveView file is carrying too many extracted helpers

### Option C: LiveComponent

Use this only when the extracted unit needs more than presentation.

Valid reasons:
- internal component state
- lifecycle callbacks
- targeted events that are cleaner inside the component boundary

Invalid reasons:
- the markup is long
- the section is reusable but stateless
- the parent file looks crowded

## Practical thresholds

These are heuristics, not hard rules.

- If `render/1` reads like multiple distinct sections, split it.
- If one section has its own conditions, classes, actions, and form markup, consider a helper function.
- If there are three or more extracted helpers in one LiveView and they are substantial, consider a dedicated component module.
- If a component needs only assigns and emits markup, keep it as a function component.

## What to keep in the LiveView

- `mount/3`
- `handle_event/3`
- `handle_info/2`
- route-aware decisions
- data loading and orchestration
- flash and navigation behavior

## What to move out

- repeated markup blocks
- visually self-contained sections
- styling-heavy cards, rows, headers, and empty states
- presentational fragments that need a small explicit API

## Atomic Words specific reminders

- Keep `<Layouts.app ...>` at the root of the LiveView template.
- Pass `current_scope` where the page layout needs it.
- Use `<.input>` and `to_form/2` patterns for forms.
- Use `use AtomicWordsWeb, :html` for function component modules.
- Keep extracted modules focused on HTML composition, not business logic.
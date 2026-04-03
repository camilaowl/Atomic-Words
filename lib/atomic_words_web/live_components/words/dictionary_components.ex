defmodule DictionaryComponents do
  use AtomicWordsWeb, :live_view

  attr :text, :string, required: true
  attr :on_remove, :string, required: true
  attr :target, :any, required: true

  @spec badge(map()) :: Phoenix.LiveView.Rendered.t()
  def badge(assigns) do
    ~H"""
    <div
      class="flex flex-row gap-1 items-center justify-center rounded-lg p-2 transition-colors duration-200 shadow-sm cursor-pointer hover:opacity-80 bg-gray-50"
      phx-click={@on_remove}
      phx-value-value={@text}
      phx-target={@target}
    >
      <span class="relative z-10 block break-words text-gray-800">{@text}</span>
      <.icon name="hero-x-mark" class="size-5 shrink-0 text-gray-600" />
    </div>
    """
  end
end

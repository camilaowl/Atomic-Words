defmodule DictionaryComponents do
  use AtomicWordsWeb, :live_view

  attr :translation, :string, required: true
  attr :on_remove, :string, required: true
  attr :target, :any, required: true

  @spec translation_variant(map()) :: Phoenix.LiveView.Rendered.t()
  def translation_variant(assigns) do
    ~H"""
    <div
      class="group relative w-fit overflow-hidden rounded-lg bg-gray-100 p-2 transition-colors duration-200 hover:bg-red-100 cursor-pointer"
      phx-click={@on_remove}
      phx-value-value={@translation}
      phx-target={@target}
    >
      <div class="pointer-events-none absolute inset-0 rounded-lg opacity-0 transition-opacity duration-200 group-hover:opacity-100 bg-red-200">
      </div>
      <span class="relative z-10 block truncate text-gray-800">{@translation}</span>
    </div>
    """
  end
end

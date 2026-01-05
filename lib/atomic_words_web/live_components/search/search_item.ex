defmodule SearchItem do
  use Phoenix.Component

  import AtomicWordsWeb.CoreComponents

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the element"
  attr :item, :map, required: true, doc: "the item to display"
  attr :added, :boolean, default: false, doc: "whether the item was added by the user"

  def search_item(assigns) do
    ~H"""
    <div class="search-item flex flex-row items-center h-12 gap-x-8 w-full">
      <h4 class="flex-1 px-2">{@item.text}</h4>

      <button
        {@rest}
        phx-value-id={@item.id}
        class={[
          "flex items-center justify-center w-10 h-10 rounded-full transition-colors",
          (@added && "bg-green-600") || "bg-grey-400 hover:bg-green-700"
        ]}
      >
        <%= if @added do %>
          <.icon name="hero-check-circle" class="w-6 h-6 text-white" />
        <% else %>
          <.icon name="hero-plus-circle" class="w-6 h-6 text-white" />
        <% end %>
      </button>
    </div>
    """
  end
end

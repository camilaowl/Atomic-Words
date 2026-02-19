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
          "p-2 rounded-full transition-colors flex items-center justify-center",
          (@added && "bg-green-600") || "bg-gray-400 hover:bg-gray-600"
        ]}
      >
        <%= if @added do %>
          <.icon name="hero-check" class="w-5 h-5 text-white" />
        <% else %>
          <.icon name="hero-plus" class="w-5 h-5 text-white" />
        <% end %>
      </button>
    </div>
    """
  end
end

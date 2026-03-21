defmodule SearchItem do
  use Phoenix.Component

  import AtomicWordsWeb.CoreComponents

  attr :item, :map, required: true, doc: "the item to display"
  attr :added, :boolean, default: false, doc: "whether the item was added by the user"
  attr :container_attrs, :map, default: %{}, doc: "attrs for the outer div"
  attr :button_attrs, :map, default: %{}, doc: "attrs for the button"

  def search_item(assigns) do
    ~H"""
    <div
      class="search-item flex flex-row items-center h-12 gap-x-8 w-full"
      phx-value-id={@item.id}
      {@container_attrs}
    >
      <h4 class="flex-1 px-2">{@item.text}</h4>

      <button
        type="button"
        phx-value-id={@item.id}
        phx-stop-propagation
        {@button_attrs}
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

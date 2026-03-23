defmodule AtomicWordsWeb.LiveComponents.Words.AddWordModal do
  use AtomicWordsWeb, :live_component

  alias AtomicWordsWeb.LiveComponents.SearchComponent
  import DictionaryComponents

  attr :current_scope, :any, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="edit-modal"
      class="fixed inset-0 z-50 flex items-center justify-center"
      phx-window-keydown="close_edit_modal"
      phx-key="escape"
      phx-target={@myself}
    >
      <div class="absolute inset-0 bg-black/40" phx-click="close_edit_modal" phx-target={@myself} />
      <div class="relative z-10 w-full max-w-xl rounded-xl bg-white p-6 shadow-xl">
        <div class="flex flex-col items-center justify-between ">
          <.live_component
            module={SearchComponent}
            id="search_component"
            current_scope={@current_scope}
          />
          <.form
            for={@form}
            id="add-word-form"
            class="flex flex-col gap-4 w-full mt-6"
            phx-submit="save_word"
            phx-change="validate"
            phx-target={@myself}
          >
            <.input
              field={@form[:word]}
              class="border-1 border-gray-200 rounded-lg p-2 w-full"
              type="text"
              placeholder="Word"
            />
            <div class="flex flex-row w-full max-w-lg gap-2 justify-between items-center">
              <div class="grow [&_.fieldset]:mb-0">
                <.input
                  field={@form[:translation]}
                  class="w-full border-1 border-gray-200 rounded-lg p-2"
                  type="text"
                  placeholder="Translation"
                />
              </div>
              <% translation_value = Map.get(@form.params, "translation", "") %>
              <.button
                type="button"
                variant="icon"
                phx-click="add_translation_variant"
                phx-target={@myself}
                disabled={translation_value == "" or translation_value in @translations}
                class={
                  "transition-colors " <>
                    if(translation_value == "" or translation_value in @translations,
                      do: "bg-gray-200 cursor-not-allowed",
                      else: "bg-green-200 hover:bg-green-300"
                    )
                }
              >
                <.icon name="hero-check" class="size-4" />
              </.button>
            </div>
            <div class="flex flex-wrap gap-2">
              <%= for translation <- @translations do %>
                <.badge
                  text={translation}
                  on_remove="remove_translation_variant"
                  target={@myself}
                />
              <% end %>
            </div>
            <div class="flex flex-row gap-2 w-full max-w-lg justify-between items-center">
              <div class="grow [&_.fieldset]:mb-0">
                <.input
                  field={@form[:use_case]}
                  class="w-full border-1 border-gray-200 rounded-lg p-2"
                  type="text"
                  placeholder="Use Case"
                />
              </div>
              <% use_case_value = Map.get(@form.params, "use_case", "") %>
              <.button
                type="button"
                variant="icon"
                phx-click="add_use_case_variant"
                phx-target={@myself}
                disabled={use_case_value == "" or use_case_value in @use_cases}
                class={
                  "transition-colors " <>
                    if(use_case_value == "" or use_case_value in @use_cases,
                      do: "bg-gray-200 cursor-not-allowed",
                      else: "bg-green-200 hover:bg-green-300"
                    )
                }
              >
                <.icon name="hero-check" class="size-4" />
              </.button>
            </div>
            <div class="flex flex-wrap gap-2">
              <%= for use_case <- @use_cases do %>
                <div class="flex items-center gap-2">
                  <.badge
                    text={use_case}
                    on_remove="remove_use_case_variant"
                    target={@myself}
                  />
                </div>
              <% end %>
            </div>
            <div class="flex flex-row gap-4 mt-4 justify-end">
              <.button
                type="button"
                variant="text"
                phx-click="close_edit_modal"
                phx-target={@myself}
              >
                Cancel
              </.button>
              <.button
                variant="primary"
                type="submit"
              >
                Save
              </.button>
            </div>
          </.form>
        </div>
        <!-- form goes here -->
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    form =
      to_form(
        %{"word" => "", "translation" => "", "use_case" => ""},
        as: :word
      )

    socket =
      socket
      |> assign(:form, form)
      |> assign(:translations, [])
      |> assign(:use_cases, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"word" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: :word))}
  end

  @impl true
  def handle_event("add_translation_variant", _params, socket) do
    translation = socket.assigns.form.params["translation"] || ""

    socket =
      if translation == "" do
        socket
      else
        new_params = Map.put(socket.assigns.form.params, "translation", "")

        socket
        |> assign(:translations, socket.assigns.translations ++ [translation])
        |> assign(:form, to_form(new_params, as: :word))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_translation_variant", %{"value" => value}, socket) do
    {:noreply, assign(socket, translations: List.delete(socket.assigns.translations, value))}
  end

  @impl true
  def handle_event("add_use_case_variant", _params, socket) do
    use_case = socket.assigns.form.params["use_case"] || ""

    socket =
      if use_case == "" do
        socket
      else
        new_params = Map.put(socket.assigns.form.params, "use_case", "")

        socket
        |> assign(:use_cases, socket.assigns.use_cases ++ [use_case])
        |> assign(:form, to_form(new_params, as: :word))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_use_case_variant", %{"value" => value}, socket) do
    {:noreply, assign(socket, use_cases: List.delete(socket.assigns.use_cases, value))}
  end

  @impl true
  def handle_event("close_edit_modal", _params, socket) do
    send(self(), :close_add_word_modal)
    {:noreply, socket}
  end
end

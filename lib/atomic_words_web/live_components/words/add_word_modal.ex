defmodule AtomicWordsWeb.LiveComponents.Words.AddWordModal do
  alias AtomicWords.Dictionary
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
            origin_lang={@origin_lang}
            target_lang={@target_lang}
            notify_on_select={{__MODULE__, @id}}
            notify_on_lang_change={{__MODULE__, @id}}
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
                  placeholder="Add Translation"
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
                  placeholder="Add Use Case"
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
                disabled={@form[:word].value == "" or length(@translations) == 0}
              >
                Save
              </.button>
            </div>
          </.form>
        </div>
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
      |> assign(:origin_lang, "en")
      |> assign(:target_lang, "uk")

    {:ok, socket}
  end

  @impl true
  def update(%{origin_lang: origin_lang, target_lang: target_lang}, socket) do
    {:ok, assign(socket, origin_lang: origin_lang, target_lang: target_lang)}
  end

  @impl true
  def update(%{selected_item: _} = assigns, socket) do
    item_id = assigns.selected_item

    socket =
      case Integer.parse(item_id) do
        {id, _} ->
          word = AtomicWords.Dictionary.word_by_id(id)
          translations = Enum.map(word.translations, & &1.text)

          new_params = %{"word" => word.word, "translation" => "", "use_case" => ""}

          socket
          |> assign(:form, to_form(new_params, as: :word))
          |> assign(:translations, translations)

        :error ->
          socket
      end

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("validate", %{"word" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: :word))}
  end

  @impl true
  def handle_event("save_word", _params, socket) do
    Dictionary.save_word(
      socket.assigns.form[:word].value,
      socket.assigns.origin_lang,
      socket.assigns.translations,
      socket.assigns.target_lang,
      socket.assigns.current_scope.user.id
    )

    socket =
      socket
      |> assign(:form, to_form(%{"word" => "", "translation" => "", "use_case" => ""}, as: :word))
      |> assign(:translations, [])
      |> assign(:use_cases, [])

    send(self(), :close_add_word_modal)
    send(self(), :update_word_list)
    {:noreply, socket}
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

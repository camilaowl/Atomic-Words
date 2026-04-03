defmodule AtomicWordsWeb.UserLive.Settings do
  use AtomicWordsWeb, :live_view

  on_mount {AtomicWordsWeb.UserAuth, :require_sudo_mode}

  alias AtomicWords.Accounts
  alias AtomicWords.Preferencies

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      active_tab={:settings}
      active_session={@active_session}
    >
      <div class="flex flex-row gap-6 p-6">
        <div class="sticky top-6 self-start">
          <.categories live_action={@live_action} />
        </div>
        <div class="flex-1">
          <%= case @live_action do %>
            <% :general -> %>
              <.general_settings
                avatar_url={@avatar_url}
                nickname={@nickname}
                email={@current_email}
                interface_languages={@interface_languages}
                selected_interface_lang={@selected_interface_lang}
              />
            <% :account -> %>
              <.account_settings />
            <% :training -> %>
              <.training_settings />
            <% :dictionary -> %>
              <.dictionary_settings />
            <% :languages -> %>
              <.language_settings
                original_lang={@original_lang}
                target_langs={@target_langs}
                selected_target_lang={@selected_target_lang}
              />
            <% _ -> %>
              <p>Select a category</p>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def categories(assigns) do
    ~H"""
    <nav class="w-64 flex flex-col gap-2">
      <.link
        class={[
          "text-lg font-semibold rounded-lg px-3 py-2",
          if(@live_action == :general,
            do: "text-gray-900 dark:text-white",
            else: "text-gray-400 dark:text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
          )
        ]}
        patch={~p"/users/settings"}
      >
        {dgettext("settings", "General")}
      </.link>
      <.link
        class={[
          "text-lg font-semibold rounded-lg px-3 py-2",
          if(@live_action == :languages,
            do: "text-gray-900 dark:text-white",
            else: "text-gray-400 dark:text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
          )
        ]}
        patch={~p"/users/settings/languages"}
      >
        {dgettext("settings", "Languages")}
      </.link>
      <.link
        class={[
          "text-lg font-semibold rounded-lg px-3 py-2",
          if(@live_action == :training,
            do: "text-gray-900 dark:text-white",
            else: "text-gray-400 dark:text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
          )
        ]}
        patch={~p"/users/settings/training"}
      >
        {dgettext("settings", "Training")}
      </.link>
      <.link
        class={[
          "text-lg font-semibold rounded-lg px-3 py-2",
          if(@live_action == :dictionary,
            do: "text-gray-900 dark:text-white",
            else: "text-gray-400 dark:text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
          )
        ]}
        patch={~p"/users/settings/dictionary"}
      >
        {dgettext("settings", "Dictionary")}
      </.link>
      <.link
        class={[
          "text-lg font-semibold rounded-lg px-3 py-2",
          if(@live_action == :account,
            do: "text-gray-900 dark:text-white",
            else: "text-gray-400 dark:text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
          )
        ]}
        patch={~p"/users/settings/account"}
      >
        {dgettext("settings", "Account")}
      </.link>
    </nav>
    """
  end

  def general_settings(assigns) do
    ~H"""
    <div class="flex flex-col gap-6">
      <h2 class="text-2xl font-bold mb-4">{dgettext("settings", "General")}</h2>
      <div id="account" class="flex flex-col gap-2">
        <p class="text-base font-semibold text-gray-900 dark:text-white mb-1">
          {dgettext("settings", "Profile")}
        </p>
        <div id="account" class="flex flex-row gap-4 items-center">
          <%= if @avatar_url do %>
            <img src={@avatar_url} class="w-16 h-16 rounded-full object-cover" />
          <% else %>
            <div class="w-16 h-16 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center text-white text-xl font-bold select-none">
              {String.first(@email) |> String.upcase()}
            </div>
          <% end %>

          <div class="flex flex-col">
            <p class="text-lg font-semibold text-gray-900 dark:text-white">
              {@nickname}
            </p>
            <p class="text-sm text-gray-500 dark:text-gray-400">{@email}</p>
          </div>
        </div>
        <.link
          patch={~p"/users/settings/account"}
          class="mt-2 inline-block text-blue-600 hover:none"
        >
          {dgettext("settings", "Manage Account")}
        </.link>
      </div>
      <div id="theme" class="flex flex-col gap-2">
        <p class="text-base font-semibold text-gray-900 dark:text-white mb-1">
          {dgettext("settings", "Theme")}
        </p>
        <label class="flex items-center gap-3 cursor-pointer w-fit">
          <input
            id="dark-mode-toggle"
            type="checkbox"
            class="sr-only peer"
            phx-hook="ThemeToggle"
            phx-update="ignore"
          />
          <div class="relative w-11 h-6 bg-gray-300 rounded-full peer-checked:bg-blue-600 transition-colors after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:w-5 after:h-5 after:transition-all peer-checked:after:translate-x-5">
          </div>
          <span class="text-gray-700 dark:text-white font-medium">
            {dgettext("settings", "Dark Mode")}
          </span>
        </label>
      </div>
      <div id="interface_language" class="flex flex-col gap-2">
        <p class="text-base font-semibold text-gray-900 dark:text-white mb-1">
          {dgettext("settings", "Interface Language")}
        </p>
        <form
          phx-change="save_interface_language"
          id="interface-lang-form"
          class="flex gap-3 items-end"
        >
          <div class="relative">
            <select
              name="interface_lang"
              id="interface-lang-select"
              class="appearance-none rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white pl-3 pr-10 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
            >
              <%= for {name, code} <- @interface_languages do %>
                <option value={code} selected={@selected_interface_lang == code}>{name}</option>
              <% end %>
            </select>
            <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-400 dark:text-gray-500">
              <.icon name="hero-chevron-down" class="w-4 h-4" />
            </span>
          </div>
        </form>
      </div>
    </div>
    """
  end

  def account_settings(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold mb-4">{dgettext("settings", "Account")}</h2>
    </div>
    """
  end

  def training_settings(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold mb-4">{dgettext("settings", "Training")}</h2>
    </div>
    """
  end

  def dictionary_settings(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold mb-4">{dgettext("settings", "Dictionary")}</h2>
    </div>
    """
  end

  def language_settings(assigns) do
    all_languages = AtomicWords.Constants.native_languages()
    target_langs = assigns.target_langs || []

    available_languages =
      Enum.reject(all_languages, fn {_name, code} ->
        code == assigns.original_lang || code in target_langs
      end)

    target_lang_options = [{"English", "en"}]

    lang_map = Map.new(all_languages, fn {name, code} -> {code, name} end)

    assigns =
      assigns
      |> assign(:all_languages, all_languages)
      |> assign(:available_languages, available_languages)
      |> assign(:target_lang_options, target_lang_options)
      |> assign(:lang_map, lang_map)

    ~H"""
    <div class="max-w-2xl space-y-8">
      <div>
        <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Language Preferences</h2>
      </div>

      <%!-- Native Language --%>
      <div id="native-language" class="flex flex-col gap-2">
        <h3 class="text-base font-semibold text-gray-900 dark:text-white mb-1">Native Language</h3>

        <form phx-submit="save_original_lang" id="original-lang-form" class="flex gap-3 items-end">
          <div class="relative ">
            <select
              name="original_lang"
              class="appearance-none rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white pl-3 pr-10 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
            >
              <option value="">Select a language</option>
              <%= for {name, code} <- @all_languages do %>
                <option value={code} selected={@original_lang == code}>{name}</option>
              <% end %>
            </select>
            <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-400 dark:text-gray-500">
              <.icon
                name="hero-chevron-down"
                class="w-4 h-4"
              />
            </span>
          </div>
        </form>
      </div>

      <%!-- Languages I'm Learning --%>
      <div id="target_language" class="flex flex-col gap-2">
        <h3 class="text-base font-semibold text-gray-900 dark:text-white mb-1">
          Target Language
        </h3>

        <form phx-submit="add_target_lang" id="add-target-lang-form" class="flex gap-3 items-end mb-5">
          <div class="relative">
            <select
              name="new_target_lang"
              class="appearance-none rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white pl-3 pr-10 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer"
            >
              <option value="">Select a target language</option>
              <%= for {name, code} <- @target_lang_options do %>
                <option value={code}>{name}</option>
              <% end %>
            </select>
            <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-400 dark:text-gray-500">
              <.icon
                name="hero-chevron-down"
                class="w-4 h-4"
              />
            </span>
          </div>
        </form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)
    interface_lang = Preferencies.interface_lang(user.id)

    Gettext.put_locale(AtomicWordsWeb.Gettext, interface_lang)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:avatar_url, nil)
      |> assign(:nickname, user.nickname)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:original_lang, nil)
      |> assign(:target_langs, [])
      |> assign(:selected_target_lang, nil)
      |> assign(:interface_languages, [{"English", "en"}, {"Українська", "uk"}])
      |> assign(:selected_interface_lang, interface_lang)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end

  def handle_event("save_original_lang", %{"original_lang" => lang}, socket) when lang != "" do
    user_id = socket.assigns.current_scope.user.id

    case Preferencies.update_original_lang(user_id, lang) do
      {:ok, _} ->
        {:noreply,
         socket |> assign(:original_lang, lang) |> put_flash(:info, "Native language saved.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not save native language.")}
    end
  end

  def handle_event("save_original_lang", _params, socket), do: {:noreply, socket}

  def handle_event("add_target_lang", %{"new_target_lang" => lang}, socket) when lang != "" do
    user_id = socket.assigns.current_scope.user.id

    case Preferencies.add_target_lang(user_id, lang) do
      {:ok, _} ->
        target_langs = (socket.assigns.target_langs ++ [lang]) |> Enum.uniq()
        {:noreply, assign(socket, :target_langs, target_langs)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not add language.")}
    end
  end

  def handle_event("add_target_lang", _params, socket), do: {:noreply, socket}

  def handle_event("remove_target_lang", %{"lang" => lang}, socket) do
    user_id = socket.assigns.current_scope.user.id

    case Preferencies.delete_target_lang(user_id, lang) do
      {:ok, _} ->
        target_langs = Enum.reject(socket.assigns.target_langs, &(&1 == lang))

        socket =
          socket
          |> assign(:target_langs, target_langs)

        socket =
          if socket.assigns.selected_target_lang == lang do
            assign(socket, :selected_target_lang, nil)
          else
            socket
          end

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not remove language.")}
    end
  end

  def handle_event("save_selected_target_lang", params, socket) do
    case Map.get(params, "selected_target_lang") do
      lang when is_binary(lang) and lang != "" ->
        user_id = socket.assigns.current_scope.user.id

        case Preferencies.update_selected_target_lang(user_id, lang) do
          {:ok, _} ->
            {:noreply,
             socket
             |> assign(:selected_target_lang, lang)
             |> put_flash(:info, "Target language saved.")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Could not save target language.")}
        end

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("save_interface_language", %{"interface_lang" => lang}, socket)
      when lang in ["en", "uk"] do
    user_id = socket.assigns.current_scope.user.id

    case Preferencies.update_interface_lang(user_id, lang) do
      {:ok, _} ->
        {:noreply, push_navigate(socket, to: ~p"/users/settings")}

      {:error, _} ->
        {:noreply,
         put_flash(socket, :error, dgettext("default", "Could not save interface language."))}
    end
  end

  def handle_event("save_interface_language", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_params(_params, _uri, socket) do
    live_action = socket.assigns.live_action

    socket =
      case live_action do
        :account ->
          socket

        :languages ->
          user_id = socket.assigns.current_scope.user.id

          target_langs =
            Preferencies.target_langs(user_id)
            |> List.flatten()
            |> Enum.reject(&is_nil/1)

          socket
          |> assign(:original_lang, Preferencies.original_lang(user_id))
          |> assign(:target_langs, target_langs)
          |> assign(:selected_target_lang, Preferencies.selected_target_lang(user_id))

        :training ->
          socket

        :dictionary ->
          socket

        _ ->
          socket
      end

    {:noreply, socket}
  end
end

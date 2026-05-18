defmodule AtomicWordsWeb.AccountComponents do
  use AtomicWordsWeb, :html

  attr :user, :map, required: true
  attr :avatar_url, :string, default: nil
  attr :editing_nickname, :boolean, required: true
  attr :nickname_form, :any, required: true

  def profile_section(assigns) do
    ~H"""
    <section class="flex flex-col gap-5">
      <div class="flex flex-col gap-6 sm:flex-row sm:items-center">
        <div class="relative shrink-0">
          <%= if @avatar_url do %>
            <img
              src={@avatar_url}
              alt="Account avatar"
              class="h-24 w-24 rounded-full border border-zinc-200 object-cover dark:border-zinc-700"
            />
          <% else %>
            <div class="flex h-24 w-24 items-center justify-center rounded-full border border-zinc-200 bg-zinc-50 text-3xl font-semibold text-slate-700 dark:border-zinc-700 dark:bg-slate-900 dark:text-slate-200">
              {avatar_initial(@user)}
            </div>
          <% end %>

          <button
            id="account-avatar-edit"
            type="button"
            phx-click="avatar_unavailable"
            class="absolute -bottom-2 -right-2 inline-flex h-9 w-9 appearance-none items-center justify-center rounded-full border border-zinc-200 bg-white text-slate-600 transition hover:bg-zinc-50 dark:border-zinc-700 dark:bg-slate-950 dark:text-slate-300 dark:hover:bg-slate-900"
            aria-label="Edit avatar"
          >
            <.icon name="hero-pencil-square" class="size-4" />
          </button>
        </div>

        <div class="flex-1">
          <%= if @editing_nickname do %>
            <.nickname_form form={@nickname_form} />
          <% else %>
            <.profile_summary user={@user} />
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  attr :form, :any, required: true

  def nickname_form(assigns) do
    ~H"""
    <.form
      for={@form}
      id="account-nickname-form"
      phx-change="validate_nickname"
      phx-submit="update_nickname"
      class="flex flex-col gap-4"
    >
      <.input field={@form[:nickname]} type="text" label="Nickname" />
      <div class="flex gap-3">
        <.button>Save</.button>
        <button
          type="button"
          phx-click="cancel_nickname_edit"
          class="inline-flex items-center justify-center rounded-md border border-zinc-300 px-4 py-2 text-sm font-medium text-slate-600 transition hover:bg-zinc-50 dark:border-zinc-700 dark:text-slate-300 dark:hover:bg-slate-900"
        >
          Cancel
        </button>
      </div>
    </.form>
    """
  end

  attr :user, :map, required: true

  def profile_summary(assigns) do
    ~H"""
    <div class="flex flex-col gap-5">
      <div class="flex items-start justify-between gap-4">
        <div class="space-y-1">
          <p class="text-2xl font-semibold tracking-tight text-slate-900 dark:text-white">
            {@user.nickname}
          </p>
          <p class="text-sm text-slate-600 dark:text-slate-300">{@user.email}</p>
        </div>
        <button
          id="account-nickname-edit"
          phx-click="toggle_nickname_edit"
          class="flex h-10 w-10 appearance-none items-center justify-center rounded-md border border-zinc-200 bg-transparent text-slate-500 transition hover:bg-zinc-50 dark:border-zinc-700 dark:text-slate-300 dark:hover:bg-slate-900"
          aria-label="Edit nickname"
        >
          <.icon name="hero-pencil-square" class="size-4" />
        </button>
      </div>
    </div>
    """
  end

  attr :email, :string, required: true

  def security_section(assigns) do
    ~H"""
    <section>
      <div class="flex flex-col gap-4">
        <.settings_row title="Email" description={@email} navigate={~p"/account/email"} />
        <.settings_row
          title="Password"
          description="Enter your current password on the next page before setting a new one."
          navigate={~p"/account/password"}
        />
      </div>
    </section>
    """
  end

  def session_section(assigns) do
    ~H"""
    <section class="flex flex-col gap-5 border-t border-zinc-200 pt-6 dark:border-zinc-800">
      <div class="flex items-center justify-between gap-4 py-1">
        <div class="flex flex-col gap-1">
          <p class="text-base font-semibold text-slate-900 dark:text-white">Log out</p>
          <p class="text-sm text-slate-600 dark:text-slate-300">
            End the current session on this device.
          </p>
        </div>

        <.link
          href={~p"/users/log-out"}
          class="inline-flex items-center gap-2 rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-slate-800 dark:bg-slate-100 dark:text-slate-900 dark:hover:bg-white"
        >
          <.icon name="hero-arrow-left-start-on-rectangle" class="size-4" /> Log out
        </.link>
      </div>
    </section>
    """
  end

  attr :expanded, :boolean, required: true

  def remove_account_section(assigns) do
    ~H"""
    <section class="flex flex-col gap-4 border-t border-zinc-200 pt-6 dark:border-zinc-800">
      <button
        id="account-remove-toggle"
        type="button"
        phx-click="toggle_remove_account_details"
        class="relative flex items-center gap-4 rounded-md border border-gray-300 bg-transparent px-4 py-3 pr-10 text-left dark:border-gray-600 dark:bg-transparent"
        aria-expanded={to_string(@expanded)}
      >
        <div class="space-y-1">
          <h2 class="text-base font-semibold text-slate-900 dark:text-white">Remove account</h2>
        </div>
        <span class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-gray-400 dark:text-gray-500">
          <.icon
            name={if @expanded, do: "hero-chevron-up", else: "hero-chevron-down"}
            class="w-4 h-4"
          />
        </span>
      </button>

      <%= if @expanded do %>
        <div class="flex items-start justify-between gap-4 py-1">
          <p class="max-w-xl text-sm leading-6 text-slate-600 dark:text-slate-300">
            This action is permanent and should only happen after password confirmation.
          </p>

          <button
            id="account-delete-action"
            type="button"
            phx-click="open_delete_modal"
            class="inline-flex items-center gap-2 rounded-md border border-red-200 bg-white px-4 py-2 text-sm font-semibold text-red-700 transition hover:bg-red-50 dark:border-red-900/50 dark:bg-slate-950 dark:text-red-300 dark:hover:bg-red-950/20"
          >
            <.icon name="hero-trash" class="size-4" /> Remove account
          </button>
        </div>
      <% end %>
    </section>
    """
  end

  attr :show, :boolean, required: true
  attr :form, :any, required: true
  attr :delete_password, :string, required: true
  attr :delete_password_errors, :list, required: true

  def delete_account_modal(assigns) do
    ~H"""
    <%= if @show do %>
      <div class="fixed inset-0 z-40 bg-gray-950/50" />
      <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="w-full max-w-md rounded-md border border-red-200 bg-white p-6 dark:border-red-900/40 dark:bg-slate-950">
          <div class="flex items-start justify-between gap-4">
            <div class="space-y-2">
              <h3 class="text-xl font-semibold text-red-900 dark:text-red-100">Delete account</h3>
              <p class="text-sm text-slate-600 dark:text-slate-300">
                This will be forever. Enter your password to confirm that you understand this action is permanent.
              </p>
            </div>

            <button
              type="button"
              phx-click="close_delete_modal"
              class="text-slate-400 transition hover:text-slate-600 dark:hover:text-slate-200"
              aria-label="Close delete account modal"
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>

          <.form for={@form} id="account-delete-form" phx-submit="confirm_delete_account" class="mt-6">
            <.input
              type="password"
              name="delete_account[password]"
              id="delete-account-password"
              value={@delete_password}
              label="Password"
              errors={@delete_password_errors}
            />

            <div class="mt-4 flex gap-3">
              <button
                type="button"
                phx-click="close_delete_modal"
                class="inline-flex items-center justify-center rounded-md border border-zinc-300 px-4 py-2 text-sm font-medium text-slate-600 transition hover:bg-zinc-50 dark:border-zinc-700 dark:text-slate-300 dark:hover:bg-slate-900"
              >
                Cancel
              </button>
              <button class="inline-flex items-center justify-center rounded-md bg-red-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-red-700">
                Confirm deletion
              </button>
            </div>
          </.form>
        </div>
      </div>
    <% end %>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :navigate, :string, required: true

  defp settings_row(assigns) do
    ~H"""
    <div class="flex items-center justify-between gap-4 py-1">
      <div class="flex flex-col gap-1">
        <p class="text-base font-semibold text-slate-900 dark:text-white">{@title}</p>
        <p class="text-sm text-slate-600 dark:text-slate-300">{@description}</p>
      </div>

      <.link
        navigate={@navigate}
        class="inline-flex h-10 w-10 items-center justify-center rounded-md border border-zinc-200 text-slate-500 transition hover:bg-zinc-50 dark:border-zinc-700 dark:text-slate-300 dark:hover:bg-slate-900"
        aria-label={"Edit #{@title}"}
      >
        <.icon name="hero-pencil-square" class="size-4" />
      </.link>
    </div>
    """
  end

  defp avatar_initial(user) do
    user.nickname
    |> to_string()
    |> String.trim()
    |> case do
      "" -> user.email
      nickname -> nickname
    end
    |> String.first()
    |> case do
      nil -> "?"
      character -> String.upcase(character)
    end
  end
end

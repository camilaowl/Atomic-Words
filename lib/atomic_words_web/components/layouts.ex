defmodule AtomicWordsWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use AtomicWordsWeb, :html

  # Embed all files in layouts/* within this module.
  embed_templates "layouts/*"

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class=" flex flex-row items-center rounded-full">
      <div class="absolute w-1/3 h-fit rounded-full bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  attr :current_user, :any
  attr :active_tab, :atom, default: :home

  def topbar_menu(assigns) do
    ~H"""
    <div class="fixed z-1 flex flex-row w-full h-fit shadow-md px-4 bg-white">
      <nav class="flex flex-row items-center justify-between items-justify w-full">
        <div class="flex items-center">
          <.link class="flex items-center" navigate={~p"/"}>
            <.icon name="hero-rocket-launch" class="w-8 h-8 text-purple-600" />
            <span class="h-8 w-auto text-2xl ml-1 font-bold">
              Atomic Words
            </span>
          </.link>
        </div>

        <.topbar_nav_links
          current_user={@current_user}
          active_tab={@active_tab}
        />
        <div class="flex flex-row items-justify-center">
          <.profile_info current_user={@current_user} />
        </div>
      </nav>
    </div>
    """
  end

  attr :current_user, :any

  def profile_info(assigns) do
    ~H"""
    <div class="relative flex items-center pr-4 my-4 group">
      <div class="flex items-center gap-3 px-3 py-2 cursor-default">
        <div class="w-9 h-9 rounded-full overflow-hidden bg-gray-200 flex items-center justify-center shrink-0">
          <img src="/images/avatar.svg" alt="User Avatar" class="w-9 h-9" />
        </div>
        <div class="text-left hidden sm:block">
          <p class="text-sm font-semibold text-gray-900 leading-tight">
            {@current_user.nickname} {@current_user.id}
          </p>
          <p class="text-xs text-gray-500 leading-tight">{@current_user.email}</p>
        </div>
        <.icon
          name="hero-chevron-down"
          class="w-4 h-4 text-gray-400 shrink-0 group-hover:rotate-180 transition-transform duration-200"
        />
      </div>

      <div class="invisible opacity-0 group-hover:visible group-hover:opacity-100 transition-all duration-150 absolute top-full left-1/2 -translate-x-1/2 mt-0 w-52 bg-white rounded-xl shadow-lg border border-gray-100 py-1.5 z-50">
        <.link
          navigate={~p"/users/settings"}
          class="flex items-center gap-2.5 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
        >
          <.icon name="hero-cog-6-tooth" class="w-4 h-4" /> Settings
        </.link>
        <.link
          navigate={~p"/users/settings/account"}
          class="flex items-center gap-2.5 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
        >
          <.icon name="hero-user" class="w-4 h-4" /> Account
        </.link>
        <div class="my-1 border-t border-gray-100" />
        <.link
          href={~p"/users/log-out"}
          class="flex items-center gap-2.5 px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors"
        >
          <.icon name="hero-arrow-left-start-on-rectangle" class="w-4 h-4" /> Log out
        </.link>
      </div>
    </div>
    """
  end

  attr :current_user, :any
  attr :active_tab, :atom, default: :home

  def topbar_nav_links(assigns) do
    ~H"""
    <div class="flex flex-row space-x-2">
      <.link
        class={
            "text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md #{if @active_tab == :home, do: "bg-gray-200", else: "hover:bg-gray-50"}"
          }
        navigate={~p"/"}
      >
        <.icon name="hero-home" class="size-4 inline-block mr-2" /> Home
      </.link>
      <.link
        class={
            "text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md #{if @active_tab == :training, do: "bg-gray-200", else: "hover:bg-gray-50"}"
          }
        navigate={~p"/training_mode"}
      >
        <.icon name="hero-fire" class="size-4 inline-block mr-2" /> Training
      </.link>
      <.link
        class={
            "text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md #{if @active_tab == :words, do: "bg-gray-200", else: "hover:bg-gray-50"}"
          }
        navigate={~p"/words"}
      >
        <.icon name="hero-book-open" class="size-4 inline-block mr-2" /> My Dictionary
      </.link>

      <.link
        class={
            "text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md #{if @active_tab == :statistics, do: "bg-gray-200", else: "hover:bg-gray-50"}"
          }
        navigate={~p"/statistics"}
      >
        <.icon name="hero-chart-bar" class="size-4 inline-block mr-2" /> Statistics
      </.link>
      <.link
        class={
            "text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md #{if @active_tab == :settings, do: "bg-gray-200", else: "hover:bg-gray-50"}"
          }
        navigate={~p"/users/settings"}
      >
        <.icon name="hero-cog-6-tooth" class="size-4 inline-block mr-2" /> Settings
      </.link>
      <.link
        class={
            "text-gray-700 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md #{if @active_tab == :logout, do: "bg-gray-200", else: "hover:bg-gray-50"}"
          }
        href={~p"/users/log-out"}
      >
        <.icon name="hero-arrow-left-start-on-rectangle" class="size-4 inline-block mr-2" /> Log out
      </.link>
    </div>
    """
  end
end

defmodule AtomicWordsWeb.UserLive.Registration do
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Accounts
  alias AtomicWords.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.auth flash={@flash} current_scope={@current_scope}>
      <div class="w-full h-screen bg-blue-50 items-center flex justify-center">
        <div class="w-1/3 h-fit bg-white items-stretch p-12 flex flex-col justify-center rounded-2xl shadow-sm">
          <h1 class="text-3xl font-bold mb-6 text-center">Sign Up</h1>

          <.form
            :let={f}
            for={@form}
            id="registration_form"
            phx-submit="save"
          >
            <.input
              readonly={!!@current_scope}
              field={f[:nickname]}
              type="text"
              label="Nickname"
              autocomplete="username"
              required
            />
            <.input
              readonly={!!@current_scope}
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              required
            />
            <.input
              field={f[:password]}
              type="password"
              label="Password"
              required
            />
            <.input
              field={f[:password_confirmation]}
              type="password"
              label="Confirm Password"
              required
            />

            <.button class="btn btn-primary w-full mt-4">
              Sign Up
            </.button>
          </.form>

          <div class=""></div>

          <div class="text-center mt-4">
            <p>
              Already have an account? <.link
                navigate={~p"/users/log-in"}
                class="font-semibold text-brand hover:underline"
                phx-no-format
              >Sign in</.link>
            </p>
          </div>

          <div class="mt-4 flex flex-col items-center">
            <p class="mb-2">Or</p>

            <.link href={~p"/auth/google/callback"} class="inline-block">
              <img
                src="/images/google/light/web_light_sq_SU.svg"
                alt="Google Logo"
                class="size-48 size-fit"
              />
            </.link>
          </div>
        </div>
      </div>
    </Layouts.auth>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: AtomicWordsWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_email(%User{}, %{}, validate_unique: false)

    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    socket =
      socket
      |> assign_form(changeset)
      |> assign(form: form)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        token = Phoenix.Token.sign(AtomicWordsWeb.Endpoint, "auto_login", user.id)

        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully.")
         |> push_navigate(to: ~p"/users/auto-log-in/#{token}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_email(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end

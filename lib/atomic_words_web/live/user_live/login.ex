defmodule AtomicWordsWeb.UserLive.Login do
  use AtomicWordsWeb, :live_view

  alias AtomicWords.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.auth flash={@flash} current_scope={@current_scope}>
      <div class="w-full h-screen bg-blue-50 items-center flex justify-center">
        <div class="w-1/3 h-2/3 bg-white items-stretch px-12 flex flex-col justify-center rounded-2xl shadow-sm">
          <h1 class="text-3xl font-bold mb-6 text-center">Sign In</h1>

          <.form
            :let={f}
            for={@form}
            id="login_form_password"
            action={~p"/users/log-in"}
            phx-submit="submit_password"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              readonly={!!@current_scope}
              field={f[:email]}
              type="email"
              label="Email"
              autocomplete="username"
              required
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              autocomplete="current-password"
            />

            <.button class="btn btn-primary w-full">
              Sign In
            </.button>
          </.form>

          <div class=""></div>

          <div class="text-center">
            <p>
              Don't have an account? <.link
                navigate={~p"/users/register"}
                class="font-semibold text-brand hover:underline"
                phx-no-format
              >Sign up</.link>
            </p>
          </div>

          <div class="mt-4 flex flex-col items-center">
            <p class="mb-2">Or</p>

            <.link href={~p"/auth/google/callback"} class="inline-block">
              <img
                src="/images/google/light/web_light_sq_SI.svg"
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
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     assign(socket,
       form: form,
       trigger_submit: false
     )}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:atomic_words, AtomicWords.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end

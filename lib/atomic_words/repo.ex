defmodule AtomicWords.Repo do
  use Ecto.Repo,
    otp_app: :atomic_words,
    adapter: Ecto.Adapters.Postgres
end

defmodule AtomicWords.Users do

  @moduledoc """
  The Users context.
  """
  import Ecto.Query, warn: false

  defp words_query(user) do
    from w in Word,
      where: w.user_id == ^user.id,
      order_by: [desc: w.inserted_at]
  end


end

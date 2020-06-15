defmodule Jwt.Plugs.Verification do
  @expired_token_error {:error, "Expired token."}
  @timeutils Application.get_env(:jwt, :timeutils, Jwt.TimeUtils)
  @five_minutes 5 * 60

  def default_options(), do: %{:ignore_token_expiration => false, :time_window => @five_minutes}

  def verify_token(token, opts) do
    verify_signature(token)
    |> verify_expiration(opts)
  end

  defp verify_signature(token), do: Jwt.verify(token)

  defp verify_expiration({:ok, claims}, opts) do
    [ignore_token_expiration, time_window] = opts

    expiration_date = claims["exp"] - time_window
    now = @timeutils.get_system_time()

    cond do
      ignore_token_expiration -> {:ok, claims}
      now > expiration_date -> @expired_token_error
      now < expiration_date -> {:ok, claims}
    end
  end

  defp verify_expiration({:error, _}, _opts), do: @expired_token_error
end

defmodule Jwt.Plug do
    import Plug.Conn

    require Logger

    @timeutils Application.get_env(:jwt, :timeutils, Jwt.TimeUtils)
    @authorization_header "authorization"
    @bearer "Bearer "
    @invalid_header_error {:error, "Invalid authorization header value."}
    @expired_token_error {:error, "Expired token."}
    @five_minutes 5 * 60
    @default_options %{:ignore_token_expiration => false, :time_window => @five_minutes}

    def init(opts) do
        case Enum.count(opts) do
          2 -> opts
          _ -> [@default_options.ignore_token_expiration, @default_options.time_window]
        end
    end

    def call(conn, opts) do
        List.first(get_req_header(conn, @authorization_header))
        |> extract_token
        |> verify_token(opts)
        |> continue_if_verified(conn)
    end

    defp extract_token(auth_header) when is_binary(auth_header) and auth_header != "" do
        case String.starts_with?(auth_header, @bearer) do
          true -> {:ok, List.last(String.split(auth_header, @bearer))}
          false -> @invalid_header_error
        end
    end
    defp extract_token(_), do: @invalid_header_error

    defp verify_token({:ok, token}, opts) do
        verify_signature(token)
        |> verify_expiration(opts)
    end
    defp verify_token({:error, _}, _opts), do: @invalid_header_error

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
    defp verify_expiration({:error, _}, _opts), do: @invalid_header_error

    defp continue_if_verified({:ok, claims}, conn) do
        assign(conn, :jwtclaims, claims)
    end
    defp continue_if_verified({:error, _}, conn), do: send_resp(conn, 401, "")
end
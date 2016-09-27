defmodule Jwt.Plug do
    import Plug.Conn

    require Logger

    @timeutils Application.get_env(:jwt, :timeutils, Jwt.TimeUtils)
    @authorization_header "authorization"
    @bearer "Bearer "
    @invalid_header_error {:error, "Invalid authorization header value."}
    @expired_token_error {:error, "Expired token."}
    @five_minutes 5 * 60

    def init(opts) do
        opts = Dict.put_new(opts, :ignore_token_expiration, false)
        Dict.put_new(opts, :time_window, @five_minutes)
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
        expiration_date = claims["exp"] - opts.time_window
        now = @timeutils.get_system_time()

        cond do
            opts.ignore_token_expiration -> {:ok, claims}
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
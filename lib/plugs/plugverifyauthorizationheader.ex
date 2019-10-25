defmodule Jwt.Plugs.VerifyAuthorizationHeader do
    import Plug.Conn
    alias Jwt.Plugs.Verification, as: Verification

    require Logger

    @authorization_header "authorization"
    @bearer "Bearer "
    @invalid_header_error {:error, "Invalid authorization header value."}

    def init(opts) do
        case Enum.count(opts) do
          2 -> opts
          _ -> [Verification.default_options().ignore_token_expiration, Verification.default_options().time_window]
        end
    end

    def call(conn, opts) do
        Logger.debug "call. Authorization header: #{inspect get_req_header(conn, @authorization_header)}"

        List.first(get_req_header(conn, @authorization_header))
        |> extract_token
        |> verify(opts)
        |> continue_after_verification(conn)
    end

    defp extract_token(auth_header) when is_binary(auth_header) and auth_header != "" do
        case String.starts_with?(auth_header, @bearer) do
          true -> {:ok, List.last(String.split(auth_header, @bearer))}
          false -> @invalid_header_error
        end
    end
    defp extract_token(_), do: @invalid_header_error

    defp verify({:ok, token}, opts), do: Verification.verify_token(token, opts)
    defp verify({:error, _}, _opts), do: @invalid_header_error

    defp continue_after_verification({:ok, claims}, conn) do
        assign(conn, :jwtclaims, claims)
    end
    defp continue_after_verification({:error, _}, conn) do
        conn
         |> send_resp(401, "")
         |> halt
    end
end
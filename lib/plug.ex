defmodule Jwt.Plug do
    import Plug.Conn

    @authorization_header "authorization"
    @bearer "Bearer "
    @invalid_header_error {:error, "Invalid authorization header value."}

    def init([]), do: false

    def call(conn, _opts) do
        List.first(get_req_header(conn, @authorization_header))
        |> extract_token
        |> verify
        |> continue_if_verified(conn)
    end

    defp extract_token(auth_header) when is_binary(auth_header) and auth_header != "" do
        case String.starts_with?(auth_header, @bearer) do
          true -> {:ok, List.last(String.split(auth_header, @bearer))}
          false -> @invalid_header_error
        end
    end
    defp extract_token(_), do: @invalid_header_error

    defp verify({:ok, token}), do: Jwt.verify(token)
    defp verify({:error, _}), do: @invalid_header_error

    defp continue_if_verified({:ok, claims}, conn) do
        assign(conn, :jwtclaims, claims)
    end
    defp continue_if_verified({:error, _}, conn), do: send_resp(conn, 401, "")
end
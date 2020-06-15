defmodule Jwt.Plugs.VerifyCookie do
  import Plug.Conn

  alias Jwt.Plugs.Verification, as: Verification

  def default_verification_failure_response, do: %{"response" => :unauthorized}

  def default_cookie_name, do: "googlejwt"

  def init(opts) do
    case Enum.count(opts) do
      3 ->
        opts

      _ ->
        [
          Verification.default_options().ignore_token_expiration,
          Verification.default_options().time_window,
          default_verification_failure_response()
        ]
    end
  end

  def call(conn, opts) do
    verification_options = Enum.slice(opts, 0, 2)
    response_options = List.last(opts)
    conn_with_cookies = fetch_cookies(conn)

    conn_with_cookies
    |> read_cookie
    |> verify(conn_with_cookies, verification_options)
    |> continue_after_verification(conn, response_options)
  end

  defp read_cookie(conn) do
    token = conn.req_cookies[default_cookie_name()]

    case token do
      nil -> {:error, :notfound}
      _ -> {:ok, token}
    end
  end

  defp verify({:ok, token}, _, opts), do: Verification.verify_token(token, opts)
  defp verify({:error, :notfound}, _, _), do: {:error, :notfound}

  defp continue_after_verification({:ok, claims}, conn, _) do
    assign(conn, :jwtclaims, claims)
  end

  defp continue_after_verification({:error, _}, conn, %{"response" => :unauthorized}) do
    conn
    |> send_resp(401, "")
    |> halt
  end

  defp continue_after_verification({:error, _}, conn, %{
         "location" => location,
         "response" => :redirect
       }) do
    conn
    |> resp(:found, "")
    |> put_resp_header("location", location)
    |> halt
  end
end

defmodule JwtPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  require Logger

  @opts Jwt.Plug.init([])

  test "Missing authorization header returns 401" do
    conn = conn(:get, "/protected")

    conn = Jwt.Plug.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == ""
  end

  test "Empty authorization header returns 401" do
      conn = conn(:get, "/protected")
      conn = put_req_header conn, "authorization", ""

      conn = Jwt.Plug.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 401
      assert conn.resp_body == ""
  end

  test "Invalid token in authorization header returns 401" do
      conn = conn(:get, "/protected")
      conn = put_req_header conn, "authorization", "token"

      conn = Jwt.Plug.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 401
      assert conn.resp_body == ""
  end

  test "Valid token is allowed" do
    header = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwZWZiZjlmOWEzZThlYzVlN2RmYTc5NjFkNzFlMmU0YmZkYTI0MzUifQ"
    claims = "eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhdWQiOiIzNDczODQ1NjIxMTMtcmRtNnNsZG0xbWIzOGs0dW1yY28zcDhsN3I1aGcwazUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTAzNjE0MDAyNDQ4NzEyMjU0MTQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMzQ3Mzg0NTYyMTEzLXIyOHBqZDB1Yzlwb2Y1Y20xcDBubmwyNXM5N2o4dXFwLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJieXRlYWJ5dGUubmV0IiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJpYXQiOjE0NzMyMjU4NjQsImV4cCI6MTQ3MzIyOTQ2NCwibmFtZSI6IkFsZWphbmRybyBNZXpjdWEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1mSUpUN0cydVozRS9BQUFBQUFBQUFBSS9BQUFBQUFBQUFRWS9KdkNWbUZIWG5yOC9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiQWxlamFuZHJvIiwiZmFtaWx5X25hbWUiOiJNZXpjdWEiLCJsb2NhbGUiOiJlbiJ9"
    signature = "Kc90u_gtZyhq6glw6UoYQSInZx9r16uqrRO7g50x17JWH7VkyAZrh3sfjdBYpGtDNJjDRBKSxuinpDjpyfiCp3-XAqqOUWqziyYvkV4-CdQvNhcnUQFXjjx_CzNiiEi5PRPCHhX4ajidet1NH4Me02S17gwOZiaZfed1BMWQuQ_7Hf2RsX5FID1xqOpcaaouMFcrqQFmdBIbcstHamWxs9D83c4JpOsioNOMb6-LBinzOg7qdxr1D4NvHD6VSXBTbyXiOBjK2elLU1iCz_Hz_BH-R1IYCdTRr5PczRWdSCgoTdZ7ds1nTTglfuXlGNbaEhhzsFxX8OCR4uNK6vbWXQ"
    valid_token = header <> "." <> claims <> "." <> signature

    auth_header= "Bearer " <> valid_token
    conn = conn(:get, "/protected")
    conn = put_req_header conn, "authorization", auth_header

    conn = Jwt.Plug.call(conn, @opts)

    claims = conn.assigns[:jwtclaims]
    Logger.debug fn -> "Claims: " <> inspect(claims) end
    assert claims != nil
    assert claims["name"] == "Alejandro Mezcua"
  end
end
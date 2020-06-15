defmodule JwtVerifyCookiePlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  require Logger

  alias Jwt.TimeUtils.Mock, as: TimeUtils
  alias Jwt.Plugs.Verification, as: Verification

  @plug Jwt.Plugs.VerifyCookie

  @defaultopts []

  @test_header "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwZWZiZjlmOWEzZThlYzVlN2RmYTc5NjFkNzFlMmU0YmZkYTI0MzUifQ"
  @test_claims "eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhdWQiOiIzNDczODQ1NjIxMTMtcmRtNnNsZG0xbWIzOGs0dW1yY28zcDhsN3I1aGcwazUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTAzNjE0MDAyNDQ4NzEyMjU0MTQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMzQ3Mzg0NTYyMTEzLXIyOHBqZDB1Yzlwb2Y1Y20xcDBubmwyNXM5N2o4dXFwLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJieXRlYWJ5dGUubmV0IiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJpYXQiOjE0NzMyMjU4NjQsImV4cCI6MTQ3MzIyOTQ2NCwibmFtZSI6IkFsZWphbmRybyBNZXpjdWEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1mSUpUN0cydVozRS9BQUFBQUFBQUFBSS9BQUFBQUFBQUFRWS9KdkNWbUZIWG5yOC9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiQWxlamFuZHJvIiwiZmFtaWx5X25hbWUiOiJNZXpjdWEiLCJsb2NhbGUiOiJlbiJ9"
  @test_signature "Kc90u_gtZyhq6glw6UoYQSInZx9r16uqrRO7g50x17JWH7VkyAZrh3sfjdBYpGtDNJjDRBKSxuinpDjpyfiCp3-XAqqOUWqziyYvkV4-CdQvNhcnUQFXjjx_CzNiiEi5PRPCHhX4ajidet1NH4Me02S17gwOZiaZfed1BMWQuQ_7Hf2RsX5FID1xqOpcaaouMFcrqQFmdBIbcstHamWxs9D83c4JpOsioNOMb6-LBinzOg7qdxr1D4NvHD6VSXBTbyXiOBjK2elLU1iCz_Hz_BH-R1IYCdTRr5PczRWdSCgoTdZ7ds1nTTglfuXlGNbaEhhzsFxX8OCR4uNK6vbWXQ"
  @test_token_exp_value 1473229464 # Expiration timestamp for the token avobe
  @ten_minutes 10 * 60
  @four_minutes 4 * 60

  test "With default options, missing cookie returns 401" do
    conn = conn(:get, "/protected")

    conn = @plug.call(conn, @plug.init(@defaultopts))

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == ""
  end

  test "With default options, invalid cookie returns 401" do
    conn = conn(:get, "/protected")
      |> put_req_cookie(@plug.default_cookie_name(), "invalid")
      |> fetch_cookies()

    conn = @plug.call(conn, @plug.init(@defaultopts))

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == ""
  end

  test "With default options, empty cookie returns 401" do
    conn = conn(:get, "/protected")
      |> put_req_cookie(@plug.default_cookie_name(), "")
      |> fetch_cookies()

    conn = @plug.call(conn, @plug.init(@defaultopts))

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == ""
  end

  test "With redirect option, missing cookie redirects to the required url" do
    expected_redirect_location = "/"
    opts = Map.values(Verification.default_options()) ++ [%{"response" => :redirect, "location" => expected_redirect_location}]
    conn = conn(:get, "/protected")

    conn = @plug.call(conn, @plug.init(opts))

    assert conn.state == :set
    assert conn.status == 302
    assert conn.resp_body == ""
    actual_redirect_location = List.first(get_resp_header(conn, "location"))
    assert actual_redirect_location == expected_redirect_location
  end

  test "With redirect option, invalid cookie redirects to the required url" do
    expected_redirect_location = "/"
    opts = Map.values(Verification.default_options()) ++ [%{"response" => :redirect, "location" => expected_redirect_location}]
    conn = conn(:get, "/protected")
      |> put_req_cookie(@plug.default_cookie_name(), "invalid")
      |> fetch_cookies()

    conn = @plug.call(conn, @plug.init(opts))

    assert conn.state == :set
    assert conn.status == 302
    assert conn.resp_body == ""
    actual_redirect_location = List.first(get_resp_header(conn, "location"))
    assert actual_redirect_location == expected_redirect_location
  end

  test "With redirect option, empty cookie redirects to the required url" do
    expected_redirect_location = "/"
    opts = Map.values(Verification.default_options()) ++ [%{"response" => :redirect, "location" => expected_redirect_location}]
    conn = conn(:get, "/protected")
      |> put_req_cookie(@plug.default_cookie_name(), "")
      |> fetch_cookies()

    conn = @plug.call(conn, @plug.init(opts))

    assert conn.state == :set
    assert conn.status == 302
    assert conn.resp_body == ""
    actual_redirect_location = List.first(get_resp_header(conn, "location"))
    assert actual_redirect_location == expected_redirect_location
  end

  test "Ignoring the token expiration, with a valid token in cookie it is parsed and claims added" do
    TimeUtils.set_time_for_tests()
    valid_token = @test_header <> "." <> @test_claims <> "." <> @test_signature
    conn = conn(:get, "/protected")
      |> put_req_cookie(@plug.default_cookie_name(), valid_token)
      |> fetch_cookies()

    conn = @plug.call(conn, @plug.init([true, 5 * 60, @plug.default_verification_failure_response()]))

    claims = conn.assigns[:jwtclaims]
    assert claims != nil
    assert claims["name"] == "Alejandro Mezcua"
  end

  test "With default options, an expired token is rejected and 401 is returned" do
    TimeUtils.set_time_for_tests()
    expired_token = @test_header <> "." <> @test_claims <> "." <> @test_signature
    conn = conn(:get, "/protected")
      |> put_req_cookie(@plug.default_cookie_name(), expired_token)
      |> fetch_cookies()

    conn = @plug.call(conn, @plug.init(@defaultopts))

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == ""
  end

  test "Token expiration allowed below but outside time window" do
    TimeUtils.set_time_for_tests(@test_token_exp_value - @ten_minutes)
    expired_in_window_token = @test_header <> "." <> @test_claims <> "." <> @test_signature
    conn = conn(:get, "/protected")
      |> put_req_cookie(@plug.default_cookie_name(), expired_in_window_token)
      |> fetch_cookies()

    conn = @plug.call(conn, @plug.init(@defaultopts))

    claims = conn.assigns[:jwtclaims]
    assert claims != nil
    assert claims["name"] == "Alejandro Mezcua"
  end

  test "Token expiration not allowed below but within time window" do
    TimeUtils.set_time_for_tests(@test_token_exp_value - @four_minutes)
    expired_in_window_token = @test_header <> "." <> @test_claims <> "." <> @test_signature
    conn = conn(:get, "/protected")
    |> put_req_cookie(@plug.default_cookie_name(), expired_in_window_token)
    |> fetch_cookies()

    conn = @plug.call(conn, @plug.init(@defaultopts))

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == ""
  end

  test "Token expiration not allowed above expiration time" do
    TimeUtils.set_time_for_tests(@test_token_exp_value + 1)
    expired_in_window_token = @test_header <> "." <> @test_claims <> "." <> @test_signature
    conn = conn(:get, "/protected")
      |> put_req_cookie(@plug.default_cookie_name(), expired_in_window_token)
      |> fetch_cookies()

    conn = @plug.call(conn, @plug.init(@defaultopts))

    assert conn.state == :sent
    assert conn.status == 401
    assert conn.resp_body == ""
  end
end

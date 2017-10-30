defmodule JwtFilterClaimsPlugTest do
    use ExUnit.Case, async: true
    use Plug.Test

    require Logger

    @rawclaims "eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhdWQiOiIzNDczODQ1NjIxMTMtcmRtNnNsZG0xbWIzOGs0dW1yY28zcDhsN3I1aGcwazUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTAzNjE0MDAyNDQ4NzEyMjU0MTQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMzQ3Mzg0NTYyMTEzLXIyOHBqZDB1Yzlwb2Y1Y20xcDBubmwyNXM5N2o4dXFwLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJieXRlYWJ5dGUubmV0IiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJpYXQiOjE0NzMyMjU4NjQsImV4cCI6MTQ3MzIyOTQ2NCwibmFtZSI6IkFsZWphbmRybyBNZXpjdWEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1mSUpUN0cydVozRS9BQUFBQUFBQUFBSS9BQUFBQUFBQUFRWS9KdkNWbUZIWG5yOC9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiQWxlamFuZHJvIiwiZmFtaWx5X25hbWUiOiJNZXpjdWEiLCJsb2NhbGUiOiJlbiJ9"
    @the_plug Jwt.Plugs.FilterClaims
    @opts []

    test "Missing claims returns 401" do
        conn = conn(:get, "/protected")

        conn = @the_plug.call(conn, @the_plug.init(@opts))

        assert401(conn)
    end

    test "Missing or empty options returns 401" do
        conn = build_conn_with_claims()

        conn = @the_plug.call(conn, @the_plug.init([]))

        assert401(conn)
    end

    test "Filter passes single exact email address" do
        conn = build_conn_with_claims()

        conn = @the_plug.call(conn, [%{"email" => "^alejandro.mezcua@byteabyte.net$"}])

        assertFilterPassed(conn)
    end

    test "Filter rejects single non matching exact email address" do
        conn = build_conn_with_claims()

        conn = @the_plug.call(conn, [%{"email" => "^not_in_claims@byteabyte.net$"}])

        assert401(conn)
    end

    test "Filter passes any email address from domain" do
        conn = build_conn_with_claims()

        conn = @the_plug.call(conn, [%{"email" => "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@byteabyte.net$"}])

        assertFilterPassed(conn)
    end

    test "Filter passes domain property" do
        conn = build_conn_with_claims()

        conn = @the_plug.call(conn, [%{"hd" => "^byteabyte.net$"}])

        assertFilterPassed(conn)
    end

    test "Filter passes when email in token is last in config list" do
      conn = build_conn_with_claims()

      conn = @the_plug.call(conn, [ %{"email" => ["^someone@byteabyte.net$", "^alejandro.mezcua@byteabyte.net$"]} ])

      assertFilterPassed(conn)
    end

    test "Filter fails when email in token is not in config list" do
      conn = build_conn_with_claims()

      conn = @the_plug.call(conn, [ %{"email" => ["^someone@byteabyte.net$", "^other@byteabyte.net$"]} ])

      assert401(conn)
    end

    test "Filter passes on two different valid properties" do
      conn = build_conn_with_claims()

      conn = @the_plug.call(conn, [ %{"iss" => "^https://accounts.google.com$"},
                                    %{"email" => "^alejandro.mezcua@byteabyte.net$"}])

      assertFilterPassed(conn)
    end

    test "Filter fails on two different properties, one invalid" do
      conn = build_conn_with_claims()

      conn = @the_plug.call(conn, [ %{"iss" => "^https://accounts.google.com$"},
                                    %{"email" => "^someone@byteabyte.net$"}])

      assert401(conn)
    end

    test "Filter fails if requested claim is not present" do
        conn = build_conn_with_claims()

        conn = @the_plug.call(conn, [ %{"notpresent" => "^anyvalue$"} ])

        assert401(conn)
    end

    defp build_conn_with_claims() do
        conn = conn(:get, "/protected")
        Plug.Conn.assign(conn, :jwtclaims, Poison.Parser.parse!(Base.url_decode64!(@rawclaims)))
    end

    defp assert401(conn) do
        assert conn.state == :sent
        assert conn.status == 401
        assert conn.resp_body == ""
    end

    defp assertFilterPassed(conn) do
        assert conn.assigns[:jwtfilterclaims] == {:ok}
    end
end
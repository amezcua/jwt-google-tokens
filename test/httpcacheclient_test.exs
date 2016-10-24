defmodule CachingHttpClientTest do
    use ExUnit.Case, async: true

    require Logger

    @validtesturl "https://accounts.google.com/.well-known/openid-configuration"
    @invalidtesturl "https://www.google.com"
    @testcache  Jwt.Cache.Ets

    setup do
        @testcache.invalidate()
        :ok
    end

    test "Response not in cache is cached" do
        Application.put_env(:jwt, :httpclient, HTTPoison)

        Jwt.HttpCacheClient.get(@validtesturl, @testcache)
        {result, value} = @testcache.get(@validtesturl)

        assert result == :ok
        assert value != nil
    end

    test "Invalid url is not cached" do
        invaliduri = "invalid"

        Jwt.HttpCacheClient.get(invaliduri, @testcache)

        assert {:error, invaliduri} == @testcache.get(invaliduri)
    end

    test "Cached values are returned instead of hitting the network" do
        cachedresponse = cacheableresponse(Timex.shift(Timex.now, hours: 1))

        Logger.debug("Cached response is: #{inspect cachedresponse}")

        @testcache.set(@validtesturl, cachedresponse)

        {client_result, client_value} = Jwt.HttpCacheClient.get(@validtesturl, @testcache)
        {cached_result, cached_value} = @testcache.get(@validtesturl)

        assert client_result == :ok
        assert client_value == cachedresponse
        assert cached_result == :ok
        assert cached_value == cachedresponse
    end

    test "Do not cache responses that do not include the Expires header" do
        testurl = "http://fakeurl"
        testresponse = noncacheableresponse()
        Application.put_env(:jwt, :fake_response, {:ok, testresponse})

        {client_result, client_value} = Jwt.HttpCacheClient.get(testurl, @testcache, CachingHttpClientTest.FakeHttpClient)
        {cached_result, cached_value} = @testcache.get(testurl)

        assert client_result == :ok
        assert client_value == testresponse
        assert cached_result == :error
        assert cached_value == testurl
    end

    test "Cache response if expires header present" do
        testurl = "http://fakeurl"
        response = cacheableresponse()
        Application.put_env(:jwt, :fake_response, {:ok, response})

        Jwt.HttpCacheClient.get(testurl, @testcache, CachingHttpClientTest.FakeHttpClient)
        {result, value} = @testcache.get(testurl)

        assert result == :ok
        assert value == response
    end

    test "Expired responses are discarded and downloaded and cached" do
        testurl = "http://fakeurl"
        expiredresponse = cacheableresponse(Timex.shift(Timex.now, hours: -1))
        currentresponse = cacheableresponse(Timex.now)
        Application.put_env(:jwt, :fake_response, {:ok, currentresponse})
        @testcache.set(testurl, expiredresponse)

        {client_result, client_value} = Jwt.HttpCacheClient.get(testurl, @testcache, CachingHttpClientTest.FakeHttpClient)
        {cache_result, cache_value} = @testcache.get(testurl)

        assert client_result == :ok
        assert client_value == currentresponse
        assert cache_result == :ok
        assert cache_value == currentresponse
    end

    defp noncacheableresponse() do
      %{body: "{\n \"issuer\": \"https://accounts.google.com\",\n \"authorization_endpoint\": \"https://accounts.google.com/o/oauth2/v2/auth\",\n \"token_endpoint\": \"https://www.googleapis.com/oauth2/v4/token\",\n \"userinfo_endpoint\": \"https://www.googleapis.com/oauth2/v3/userinfo\",\n \"revocation_endpoint\": \"https://accounts.google.com/o/oauth2/revoke\",\n \"jwks_uri\": \"https://www.googleapis.com/oauth2/v3/certs\",\n \"response_types_supported\": [\n  \"code\",\n  \"token\",\n  \"id_token\",\n  \"code token\",\n  \"code id_token\",\n  \"token id_token\",\n  \"code token id_token\",\n  \"none\"\n ],\n \"subject_types_supported\": [\n  \"public\"\n ],\n \"id_token_signing_alg_values_supported\": [\n  \"RS256\"\n ],\n \"scopes_supported\": [\n  \"openid\",\n  \"email\",\n  \"profile\"\n ],\n \"token_endpoint_auth_methods_supported\": [\n  \"client_secret_post\",\n  \"client_secret_basic\"\n ],\n \"claims_supported\": [\n  \"aud\",\n  \"email\",\n  \"email_verified\",\n  \"exp\",\n  \"family_name\",\n  \"given_name\",\n  \"iat\",\n  \"iss\",\n  \"locale\",\n  \"name\",\n  \"picture\",\n  \"sub\"\n ],\n \"code_challenge_methods_supported\": [\n  \"plain\",\n  \"S256\"\n ]\n}\n",
        headers: [
            {"Vary", "Accept-Encoding"},
            {"Content-Type", "application/json"}],
        status_code: 200}
    end

    defp cacheableresponse(expires_date \\ Timex.now) do
      %{body: "{\n \"issuer\": \"https://accounts.google.com\",\n \"authorization_endpoint\": \"https://accounts.google.com/o/oauth2/v2/auth\",\n \"token_endpoint\": \"https://www.googleapis.com/oauth2/v4/token\",\n \"userinfo_endpoint\": \"https://www.googleapis.com/oauth2/v3/userinfo\",\n \"revocation_endpoint\": \"https://accounts.google.com/o/oauth2/revoke\",\n \"jwks_uri\": \"https://www.googleapis.com/oauth2/v3/certs\",\n \"response_types_supported\": [\n  \"code\",\n  \"token\",\n  \"id_token\",\n  \"code token\",\n  \"code id_token\",\n  \"token id_token\",\n  \"code token id_token\",\n  \"none\"\n ],\n \"subject_types_supported\": [\n  \"public\"\n ],\n \"id_token_signing_alg_values_supported\": [\n  \"RS256\"\n ],\n \"scopes_supported\": [\n  \"openid\",\n  \"email\",\n  \"profile\"\n ],\n \"token_endpoint_auth_methods_supported\": [\n  \"client_secret_post\",\n  \"client_secret_basic\"\n ],\n \"claims_supported\": [\n  \"aud\",\n  \"email\",\n  \"email_verified\",\n  \"exp\",\n  \"family_name\",\n  \"given_name\",\n  \"iat\",\n  \"iss\",\n  \"locale\",\n  \"name\",\n  \"picture\",\n  \"sub\"\n ],\n \"code_challenge_methods_supported\": [\n  \"plain\",\n  \"S256\"\n ]\n}\n",
        headers: [
            {"Vary", "Accept-Encoding"},
            {"Content-Type", "application/json"},
            {"Expires", Timex.format!(expires_date, "{RFC1123}")}],
        status_code: 200}
    end

    defmodule FakeHttpClient do
      def get(_uri), do: Application.get_env(:jwt, :fake_response)
    end
end
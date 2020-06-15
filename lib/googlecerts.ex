defmodule Jwt.GoogleCerts.PublicKey do

  @httpclient Jwt.HttpCacheClient
  @discovery_url "https://accounts.google.com/.well-known/openid-configuration"
  @jwt_uri_in_discovery "jwks_uri"
  @exponent "e"
  @modulus "n"

  def getfor(id), do: fetch id

  defp fetch(id) do
    @httpclient.get!(@discovery_url)
        |> get_response_body
        |> extract_certificates_url
        |> case do
          {:ok, uri} -> {:ok, uri}
          _ -> {:error, nil}
        end
        |> request_certificates_uri
        |> get_response_body
        |> extract_public_key_for_id(id)
  end

  defp get_response_body(%{body: body, headers: _headers, status_code: 200}), do: {:ok, body}
  defp get_response_body(%{body: body, headers: _headers, status_code: _status_code}), do: {:error, body}

  defp extract_certificates_url({:ok, body}) do
    parsed = Jason.decode!(body, %{})
    case parsed[@jwt_uri_in_discovery] do
        nil -> {:notfounderror, "No JWT url found"}
        _ -> {:ok, parsed[@jwt_uri_in_discovery]}
    end
  end

  defp extract_certificates_url({:error, _body}), do: []

  defp request_certificates_uri({:ok, uri}), do: @httpclient.get! uri
  defp request_certificates_uri({:error, _}), do: %{body: nil, headers: nil, status_code: 404}

  defp extract_public_key_for_id({:error, _}, _id), do: nil
  defp extract_public_key_for_id({:ok, body}, id) do
    parsed = Jason.decode!(body, %{})

    key = List.first(Enum.filter parsed["keys"], fn key -> key["kid"] == id end)

    case key do
      nil -> {:notfounderror, "Public key id not found"}
      _ -> {:ok, %{exp: Base.url_decode64!(key[@exponent], padding: false), mod: Base.url_decode64!(key[@modulus], padding: false)}}
    end
  end
end
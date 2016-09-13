defmodule Jwt.GoogleCerts.PublicKey do

  @discovery_url "https://accounts.google.com/.well-known/openid-configuration"
  @jwt_uri_in_discovery "jwks_uri"
  @keys_in_certificates "keys"
  @id_key_in_certificates "kid"
  @exponent "e"
  @modulus "n"

  def getfor(id), do: fetch id

  defp fetch(id) do
    HTTPoison.get!(@discovery_url)
        |> get_response_body
        |> extract_certificated_url
        |> case do
          {:ok, uri} -> {:ok, uri}
          _ -> {:error, nil}
        end
        |> request_certificates_uri
        |> get_response_body
        |> extract_public_key_for_id(id)
  end

  defp get_response_body(%{body: body, headers: _headers, status_code: 200}), do: {:ok, body}
  defp get_response_body(%{body: body, headers: _headers, status_code: status_code}), do: {:error, body}

  defp extract_certificated_url({:ok, body}) do
    {:ok, parsed} = Poison.Parser.parse body
    case parsed[@jwt_uri_in_discovery] do
        nil -> {:error, "No JWT url found"}
        _ -> {:ok, parsed[@jwt_uri_in_discovery]}
    end
  end

  defp extract_certificated_url({:error, _body}), do: []

  defp request_certificates_uri({:ok, uri}), do: HTTPoison.get! uri
  defp request_certificates_uri({:error, _}), do: %{body: nil, headers: nil, status_code: 404}

  defp extract_public_key_for_id({:error, _}, _id), do: nil
  defp extract_public_key_for_id({:ok, body}, id) do
    {:ok, parsed} = Poison.Parser.parse body

    key = List.first(Enum.filter parsed["keys"], fn key -> key["kid"] == id end)

    case key do
      nil -> {:error, "Public key id not found"}
      _ -> {:ok, %{exp: key[@exponent], mod: key[@modulus]}}
    end
  end
end
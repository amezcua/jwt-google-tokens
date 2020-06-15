defmodule Jwt.FirebaseCerts.PublicKey do
  @httpclient Jwt.HttpCacheClient
  @certs_url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  def getfor(id), do: fetch(id)

  defp fetch(id) do
    @httpclient.get!(@certs_url)
    |> get_response_body
    |> extract_public_key_for_id(id)
  end

  defp get_response_body(%{body: body, headers: _headers, status_code: 200}), do: {:ok, body}

  defp get_response_body(%{body: body, headers: _headers, status_code: _status_code}),
    do: {:error, body}

  defp extract_public_key_for_id({:error, _}, _id), do: nil

  defp extract_public_key_for_id({:ok, body}, id) do
    parsed = Jason.decode!(body, %{})

    cert = parsed[id]

    case cert do
      nil -> {:error, "Public key id not found"}
      cert_string -> Jwt.PemParser.extract_exponent_and_modulus_from_pem_cert(cert_string)
    end
  end
end

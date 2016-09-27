defmodule Jwt do
    @google_certs_api Application.get_env(:jwt, :googlecerts, Jwt.GoogleCerts.PublicKey)
    @invalid_token_error {:error, "Invalid token"}
    @invalid_signature_error {:error, "Invalid signature"}
    @key_id "kid"
    @alg "alg"

    @doc """
        Verifies a Google generated JWT token against the current public Google certificates and returns the claims
        if the token's signature is verified successfully.

        ## Example
            iex > {:ok, {claims}} = Jwt.verify token
    """
    def verify(token) do
        token_parts = String.split token, "."

        _verify(Enum.map(token_parts, fn(part) -> Base.url_decode64(part, padding: false) end), token_parts)
    end

    defp _verify([{:ok, header}, {:ok, _claims}, {:ok, signature}], [header_b64, claims_b64, _signature_b64]) do
        Poison.Parser.parse!(header)[@key_id]
            |> @google_certs_api.getfor
            |> verify_signature(header_b64, claims_b64, signature)
    end

    defp _verify(_,_), do: @invalid_token_error

    defp verify_signature({:ok, public_key}, header_b64, claims_b64, signature) do
        msg = header_b64 <> "." <> claims_b64
        mod = :binary.decode_unsigned(Base.url_decode64!(public_key.mod, padding: false))
        exp = :binary.decode_unsigned(Base.url_decode64!(public_key.exp, padding: false))

        case :crypto.verify :rsa, :sha256, msg, signature, [exp, mod] do
            true -> {:ok, Poison.Parser.parse! Base.url_decode64!(claims_b64, padding: false)}
            false -> @invalid_signature_error
        end
    end

    defp verify_signature(_, _, _, _), do: @invalid_signature_error
end

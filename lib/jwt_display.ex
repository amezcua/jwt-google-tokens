defmodule Jwt.Display do
    @doc ~S"""
    Displays the content of a token. Useful to inspect them quickly. It does not do any verification on them.

    ## Examples

        iex> Jwt.Display.display("eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwZWZiZjlmOWEzZThlYzVlN2RmYTc5NjFkNzFlMmU0YmZkYTI0MzUifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhdWQiOiIzNDczODQ1NjIxMTMtcmRtNnNsZG0xbWIzOGs0dW1yY28zcDhsN3I1aGcwazUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTAzNjE0MDAyNDQ4NzEyMjU0MTQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMzQ3Mzg0NTYyMTEzLXIyOHBqZDB1Yzlwb2Y1Y20xcDBubmwyNXM5N2o4dXFwLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJieXRlYWJ5dGUubmV0IiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJpYXQiOjE0NzMyMjU4NjQsImV4cCI6MTQ3MzIyOTQ2NCwibmFtZSI6IkFsZWphbmRybyBNZXpjdWEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1mSUpUN0cydVozRS9BQUFBQUFBQUFBSS9BQUFBQUFBQUFRWS9KdkNWbUZIWG5yOC9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiQWxlamFuZHJvIiwiZmFtaWx5X25hbWUiOiJNZXpjdWEiLCJsb2NhbGUiOiJlbiJ9.Kc90u_gtZyhq6glw6UoYQSInZx9r16uqrRO7g50x17JWH7VkyAZrh3sfjdBYpGtDNJjDRBKSxuinpDjpyfiCp3-XAqqOUWqziyYvkV4-CdQvNhcnUQFXjjx_CzNiiEi5PRPCHhX4ajidet1NH4Me02S17gwOZiaZfed1BMWQuQ_7Hf2RsX5FID1xqOpcaaouMFcrqQFmdBIbcstHamWxs9D83c4JpOsioNOMb6-LBinzOg7qdxr1D4NvHD6VSXBTbyXiOBjK2elLU1iCz_Hz_BH-R1IYCdTRr5PczRWdSCgoTdZ7ds1nTTglfuXlGNbaEhhzsFxX8OCR4uNK6vbWXQ")
        {:ok, {:claims, 
            %{
                "aud" => "347384562113-rdm6sldm1mb38k4umrco3p8l7r5hg0k5.apps.googleusercontent.com", 
                "azp" => "347384562113-r28pjd0uc9pof5cm1p0nnl25s97j8uqp.apps.googleusercontent.com", 
                "email" => "alejandro.mezcua@byteabyte.net", 
                "email_verified" => true, 
                "exp" => 1473229464, 
                "family_name" => "Mezcua", 
                "given_name" => "Alejandro", 
                "hd" => "byteabyte.net", 
                "iat" => 1473225864, 
                "iss" => "https://accounts.google.com", 
                "locale" => "en", 
                "name" => "Alejandro Mezcua", 
                "picture" => "https://lh3.googleusercontent.com/-fIJT7G2uZ3E/AAAAAAAAAAI/AAAAAAAAAQY/JvCVmFHXnr8/s96-c/photo.jpg", 
                "sub" => "110361400244871225414"
                }}}

    """
    def display(token) do
        token_parts = String.split token, "."

        {:ok, _display(Enum.map(token_parts, fn(part) -> Base.url_decode64(part, padding: false) end), token_parts)}
    end

    defp _display([{:ok, _header}, {:ok, claims}, {:ok, _signature}], [_header_b64, _claims_b64, _signature_b64]) do
        {:claims, Poison.Parser.parse!(claims, %{})}
    end
end
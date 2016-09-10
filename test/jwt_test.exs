defmodule JwtTest do
  use ExUnit.Case, async: true
  doctest Jwt

  @google_certs_api Application.get_env(:jwt, :googlecerts)
  @invalid_token_error {:error, "Invalid token"}
  @base64part "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdkMWEzMTcxMTE5NTFiZDI0MjdlMjZmMjA3Nzc3MzRlYjgwZjY1YTUifQ"
  @non_base64part "1"
  @valid_token_header "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwZWZiZjlmOWEzZThlYzVlN2RmYTc5NjFkNzFlMmU0YmZkYTI0MzUifQ"
  @valid_token_claims "eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhdWQiOiIzNDczODQ1NjIxMTMtcmRtNnNsZG0xbWIzOGs0dW1yY28zcDhsN3I1aGcwazUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTAzNjE0MDAyNDQ4NzEyMjU0MTQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMzQ3Mzg0NTYyMTEzLXIyOHBqZDB1Yzlwb2Y1Y20xcDBubmwyNXM5N2o4dXFwLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJieXRlYWJ5dGUubmV0IiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJpYXQiOjE0NzMyMjU4NjQsImV4cCI6MTQ3MzIyOTQ2NCwibmFtZSI6IkFsZWphbmRybyBNZXpjdWEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1mSUpUN0cydVozRS9BQUFBQUFBQUFBSS9BQUFBQUFBQUFRWS9KdkNWbUZIWG5yOC9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiQWxlamFuZHJvIiwiZmFtaWx5X25hbWUiOiJNZXpjdWEiLCJsb2NhbGUiOiJlbiJ9"
  @valid_token_signature "Kc90u_gtZyhq6glw6UoYQSInZx9r16uqrRO7g50x17JWH7VkyAZrh3sfjdBYpGtDNJjDRBKSxuinpDjpyfiCp3-XAqqOUWqziyYvkV4-CdQvNhcnUQFXjjx_CzNiiEi5PRPCHhX4ajidet1NH4Me02S17gwOZiaZfed1BMWQuQ_7Hf2RsX5FID1xqOpcaaouMFcrqQFmdBIbcstHamWxs9D83c4JpOsioNOMb6-LBinzOg7qdxr1D4NvHD6VSXBTbyXiOBjK2elLU1iCz_Hz_BH-R1IYCdTRr5PczRWdSCgoTdZ7ds1nTTglfuXlGNbaEhhzsFxX8OCR4uNK6vbWXQ"

  test "Invalid Jwt tokens are rejected" do
    invalid_token = "invalid_token"
    assert @invalid_token_error = Jwt.verify(invalid_token)

    invalid_token = "1.2"
    assert @invalid_token_error = Jwt.verify(invalid_token)

    invalid_token = ""
    assert @invalid_token_error = Jwt.verify(invalid_token)
  end

  test "Non base 64 token header rejects token" do
    invalid_token = "#{@non_base64part}.#{@base64part}.#{@base64part}"
    assert @invalid_token_error = Jwt.verify(invalid_token)
  end

  test "Non base 64 token claims rejects token" do
    invalid_token = "#{@base64part}.#{@non_base64part}.#{@base64part}"
    assert @invalid_token_error = Jwt.verify(invalid_token)
  end

  test "Non base 64 token signature rejects token" do
    invalid_token = "#{@base64part}.#{@base64part}.#{@non_base64part}"
    assert @invalid_token_error = Jwt.verify(invalid_token)
  end

  test "The claims are extracted from a valid token" do
    valid_token = @valid_token_header <> "." <> @valid_token_claims <> "." <> @valid_token_signature
    assert {:ok, _} = Jwt.verify(valid_token)
  end

end

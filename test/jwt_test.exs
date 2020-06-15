defmodule JwtTest do
  use ExUnit.Case, async: true

  @invalid_token_error {:error, "Invalid token"}
  @base64part "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdkMWEzMTcxMTE5NTFiZDI0MjdlMjZmMjA3Nzc3MzRlYjgwZjY1YTUifQ"
  @non_base64part "1"
  @valid_google_token_header "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwZWZiZjlmOWEzZThlYzVlN2RmYTc5NjFkNzFlMmU0YmZkYTI0MzUifQ"
  @valid_google_token_claims "eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhdWQiOiIzNDczODQ1NjIxMTMtcmRtNnNsZG0xbWIzOGs0dW1yY28zcDhsN3I1aGcwazUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTAzNjE0MDAyNDQ4NzEyMjU0MTQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMzQ3Mzg0NTYyMTEzLXIyOHBqZDB1Yzlwb2Y1Y20xcDBubmwyNXM5N2o4dXFwLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJieXRlYWJ5dGUubmV0IiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJpYXQiOjE0NzMyMjU4NjQsImV4cCI6MTQ3MzIyOTQ2NCwibmFtZSI6IkFsZWphbmRybyBNZXpjdWEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1mSUpUN0cydVozRS9BQUFBQUFBQUFBSS9BQUFBQUFBQUFRWS9KdkNWbUZIWG5yOC9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiQWxlamFuZHJvIiwiZmFtaWx5X25hbWUiOiJNZXpjdWEiLCJsb2NhbGUiOiJlbiJ9"
  @valid_google_token_signature "Kc90u_gtZyhq6glw6UoYQSInZx9r16uqrRO7g50x17JWH7VkyAZrh3sfjdBYpGtDNJjDRBKSxuinpDjpyfiCp3-XAqqOUWqziyYvkV4-CdQvNhcnUQFXjjx_CzNiiEi5PRPCHhX4ajidet1NH4Me02S17gwOZiaZfed1BMWQuQ_7Hf2RsX5FID1xqOpcaaouMFcrqQFmdBIbcstHamWxs9D83c4JpOsioNOMb6-LBinzOg7qdxr1D4NvHD6VSXBTbyXiOBjK2elLU1iCz_Hz_BH-R1IYCdTRr5PczRWdSCgoTdZ7ds1nTTglfuXlGNbaEhhzsFxX8OCR4uNK6vbWXQ"

  @valid_firebase_token_header "eyJhbGciOiJSUzI1NiIsImtpZCI6ImU3MGRiMDg5MzU5MDBkNTY0YWFiMjdiMzllNmJkNWM4NDdkMDQxM2QifQ"
  @valid_firebase_token_claims "eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vYmFkYWNoaW4tNTUzYjkiLCJuYW1lIjoiQWxlamFuZHJvIE1lemN1YSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vLWZJSlQ3RzJ1WjNFL0FBQUFBQUFBQUFJL0FBQUFBQUFBQVFZL0p2Q1ZtRkhYbnI4L3Bob3RvLmpwZyIsImF1ZCI6ImJhZGFjaGluLTU1M2I5IiwiYXV0aF90aW1lIjoxNDgzMzUxNjY5LCJ1c2VyX2lkIjoiTVNsZ0JueVU1NWdRQ3Q3WElTNWpiQzVYdE5BMyIsInN1YiI6Ik1TbGdCbnlVNTVnUUN0N1hJUzVqYkM1WHROQTMiLCJpYXQiOjE0ODM0MjkzMzYsImV4cCI6MTQ4MzQzMjkzNiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjExMDM2MTQwMDI0NDg3MTIyNTQxNCJdLCJlbWFpbCI6WyJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiXX0sInNpZ25faW5fcHJvdmlkZXIiOiJnb29nbGUuY29tIn19"
  @valid_firebase_token_signature "tk8mTHJnRCqn1KQ0Ha5R_34sOWYoxV0QFCgLQ32UCLWy00kkq_waLyoYdb7G7Tns6dLk6e2rPcrz97JCcWTCqD3erMd9oN2IyqAGPUOU7FJr8PjtaMzHWDUdTinI05sKpRJNxMcEiP7Wd0VKk4ubuImbO7MphKZL5-KLz2KTcQztQaJC0dw1Ey3mBCSbdOkIMuTxCzfjkvXrbmGirIAfn8INJyIEg8Vnav-NaBT5ShIcie_ovVZy97iReNcubRZn34ipMQrai_k_JaRjlVMn0m0u9dee44S4XHlvdC4hkC-DpBZubDDj3BVQq-Ztk9H9CZREuPUjdfy3anflBE_BwQ"

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

  test "The claims are extracted from a valid Google token" do
    valid_google_token =
      @valid_google_token_header <>
        "." <> @valid_google_token_claims <> "." <> @valid_google_token_signature

    assert {:ok, _} = Jwt.verify(valid_google_token)
  end

  test "The claims are extracted from a valid Firebase token" do
    valid_firebase_token =
      @valid_firebase_token_header <>
        "." <> @valid_firebase_token_claims <> "." <> @valid_firebase_token_signature

    assert {:ok, _} = Jwt.verify(valid_firebase_token)
  end
end

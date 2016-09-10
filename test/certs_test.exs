defmodule CertsTest do
    use ExUnit.Case, async: true

    require Logger

    @mod "zkSRsA8npcga4dKSt91-OtSXA481Y94jt5tn64h2MUtUnQ_1JP-4xcDBYVG52m1Cdc7Fq2_cpUOvm27jAxIc4oYxLk1YtyJX9ce5p2rkbKyC71nSq5om3rBE4n3hYUa0nPCcXNC0uC_G0UTVY_OsiYS6hSNVSnHqySn50yid8EBWY8sHHCsqEtlk4uwXXalgnpZ5BXI22yQWQASnZdeIiRKhxSWdkDrbLUq1FmyfNn9vabhIADZsdjCL3iCfJVW8YTdntObZRVsuh_ezm9K7-l3U400EvZA7RN_Dt5QGC6gSjo4syP5TkGXD6iC6rUx67FLzgww_Lo0O4kYEFzDLzw"
    @exp "AQAB"
    @header "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwZWZiZjlmOWEzZThlYzVlN2RmYTc5NjFkNzFlMmU0YmZkYTI0MzUifQ"
    @claims "eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhdWQiOiIzNDczODQ1NjIxMTMtcmRtNnNsZG0xbWIzOGs0dW1yY28zcDhsN3I1aGcwazUuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTAzNjE0MDAyNDQ4NzEyMjU0MTQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiMzQ3Mzg0NTYyMTEzLXIyOHBqZDB1Yzlwb2Y1Y20xcDBubmwyNXM5N2o4dXFwLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJieXRlYWJ5dGUubmV0IiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJpYXQiOjE0NzMyMjU4NjQsImV4cCI6MTQ3MzIyOTQ2NCwibmFtZSI6IkFsZWphbmRybyBNZXpjdWEiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1mSUpUN0cydVozRS9BQUFBQUFBQUFBSS9BQUFBQUFBQUFRWS9KdkNWbUZIWG5yOC9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiQWxlamFuZHJvIiwiZmFtaWx5X25hbWUiOiJNZXpjdWEiLCJsb2NhbGUiOiJlbiJ9"
    @signature "Kc90u_gtZyhq6glw6UoYQSInZx9r16uqrRO7g50x17JWH7VkyAZrh3sfjdBYpGtDNJjDRBKSxuinpDjpyfiCp3-XAqqOUWqziyYvkV4-CdQvNhcnUQFXjjx_CzNiiEi5PRPCHhX4ajidet1NH4Me02S17gwOZiaZfed1BMWQuQ_7Hf2RsX5FID1xqOpcaaouMFcrqQFmdBIbcstHamWxs9D83c4JpOsioNOMb6-LBinzOg7qdxr1D4NvHD6VSXBTbyXiOBjK2elLU1iCz_Hz_BH-R1IYCdTRr5PczRWdSCgoTdZ7ds1nTTglfuXlGNbaEhhzsFxX8OCR4uNK6vbWXQ"

    test "Verify signature" do
        mod = :binary.decode_unsigned(Base.url_decode64!(@mod, padding: false))
        exp = :binary.decode_unsigned(Base.url_decode64!(@exp, padding: false))
        pk = [exp, mod]
        signature = Base.url_decode64! @signature, padding: false

        msg = @header <> "." <> @claims

        assert :crypto.verify :rsa, :sha256, msg, signature, pk
    end
end
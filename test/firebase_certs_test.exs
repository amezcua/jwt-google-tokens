defmodule FirebaseCertsTest do
    use ExUnit.Case, async: true

    require Logger

    @certificate "-----BEGIN CERTIFICATE-----\nMIIDHDCCAgSgAwIBAgIIHCf0ZvzSh6gwDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UE\nAxMmc2VjdXJldG9rZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wHhcNMTcw\nMTAzMDA0NTI2WhcNMTcwMTA2MDExNTI2WjAxMS8wLQYDVQQDEyZzZWN1cmV0b2tl\nbi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD\nggEPADCCAQoCggEBAMew823wkK4hu02ROzImYBkryY8V6hH5aKbIcbXoaktTn/en\n5PB29MFqgy5GXrPsg6knIxsx2RR+yX5qWvMJJlxYz/NytMNkgFZPh+wtgEG0XmA5\n34J1nS6p9Lg/5jgxTyDmN9/WOj9Ml4DgQSFzz4f4AGwStw+dOERXBz+wASrs+8qL\ntxLt/Z2ENAqMDnxaY8VdOqNlFeQuBca3KQsZEvv3jObFGwrtFsCa+gnQ2JNYCACz\nuaJou68I4P0SOc17NqX8NZtyW/UmBam2WEHfE9C8qGUk96sfIktSL5MwRYQyl3UP\nU+SiorVkGBJgTGMHSymsbR/Ia4tB+nQ4KIuEbWUCAwEAAaM4MDYwDAYDVR0TAQH/\nBAIwADAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwIwDQYJ\nKoZIhvcNAQEFBQADggEBAJ3M+1HJTt/IQZ/09eW8B9gwgBBVhawZ1n0+aY7SuKSB\njHz474nUlQVz6SxBmeVScb9IXh2lL1K+YYrP/O7sP/OUYXHfjxKGNFMDl/lo/Pgq\nMmSOXnvbvEOgXrsgF8/ytj2BEyMe7wuZC7impUCkbarV4FKcvqjff1iLzAKWn4et\nRJJEyEngemOfAl2l9JBuQG/mouOyapv1g7B9mfRTTYKtbFl1o3N1GJtWC78pD+K9\noawYyz9tiGmm8IKW/KYiJhj616eq06ugEb3VHDjFL+hjGPmORPUND/al+XibYU/q\nNN45J+dag1ZeKxu1Ugc9p2IQB1RMtLMfGmaBldHQ5dY=\n-----END CERTIFICATE-----\n"

    @header "eyJhbGciOiJSUzI1NiIsImtpZCI6ImU3MGRiMDg5MzU5MDBkNTY0YWFiMjdiMzllNmJkNWM4NDdkMDQxM2QifQ"
    @claims "eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vYmFkYWNoaW4tNTUzYjkiLCJuYW1lIjoiQWxlamFuZHJvIE1lemN1YSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vLWZJSlQ3RzJ1WjNFL0FBQUFBQUFBQUFJL0FBQUFBQUFBQVFZL0p2Q1ZtRkhYbnI4L3Bob3RvLmpwZyIsImF1ZCI6ImJhZGFjaGluLTU1M2I5IiwiYXV0aF90aW1lIjoxNDgzMzUxNjY5LCJ1c2VyX2lkIjoiTVNsZ0JueVU1NWdRQ3Q3WElTNWpiQzVYdE5BMyIsInN1YiI6Ik1TbGdCbnlVNTVnUUN0N1hJUzVqYkM1WHROQTMiLCJpYXQiOjE0ODM0MjkzMzYsImV4cCI6MTQ4MzQzMjkzNiwiZW1haWwiOiJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjExMDM2MTQwMDI0NDg3MTIyNTQxNCJdLCJlbWFpbCI6WyJhbGVqYW5kcm8ubWV6Y3VhQGJ5dGVhYnl0ZS5uZXQiXX0sInNpZ25faW5fcHJvdmlkZXIiOiJnb29nbGUuY29tIn19"
    @signature "tk8mTHJnRCqn1KQ0Ha5R_34sOWYoxV0QFCgLQ32UCLWy00kkq_waLyoYdb7G7Tns6dLk6e2rPcrz97JCcWTCqD3erMd9oN2IyqAGPUOU7FJr8PjtaMzHWDUdTinI05sKpRJNxMcEiP7Wd0VKk4ubuImbO7MphKZL5-KLz2KTcQztQaJC0dw1Ey3mBCSbdOkIMuTxCzfjkvXrbmGirIAfn8INJyIEg8Vnav-NaBT5ShIcie_ovVZy97iReNcubRZn34ipMQrai_k_JaRjlVMn0m0u9dee44S4XHlvdC4hkC-DpBZubDDj3BVQq-Ztk9H9CZREuPUjdfy3anflBE_BwQ"

    test "Verify signature Firebase certificate" do
        [{_, dert, _}] = :public_key.pem_decode(@certificate)
        otp = :public_key.pkix_decode_cert(dert, :otp)

        [_, mod, exp] = otp 
                |> Tuple.to_list 
                |> Enum.slice(1..1)
                |> hd
                |> Tuple.to_list 
                |> Enum.slice(7..7) 
                |> hd 
                |> Tuple.to_list 
                |> Enum.slice(2..2) 
                |> hd 
                |> Tuple.to_list

        pk = [exp, mod]
        signature = Base.url_decode64! @signature, padding: false
        msg = @header <> "." <> @claims

        assert :crypto.verify :rsa, :sha256, msg, signature, pk
    end
end
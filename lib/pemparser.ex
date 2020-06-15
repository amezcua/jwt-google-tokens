defmodule Jwt.PemParser do
  def extract_exponent_and_modulus_from_pem_cert(pem_cert) do
    [{_, dert, _}] = :public_key.pem_decode(pem_cert)
    otp = :public_key.pkix_decode_cert(dert, :otp)

    [_, mod, exp] =
      otp
      |> Tuple.to_list()
      |> Enum.slice(1..1)
      |> hd
      |> Tuple.to_list()
      |> Enum.slice(7..7)
      |> hd
      |> Tuple.to_list()
      |> Enum.slice(2..2)
      |> hd
      |> Tuple.to_list()

    {:ok, %{exp: exp, mod: mod}}
  end
end

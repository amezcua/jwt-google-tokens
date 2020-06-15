defmodule Jwt.GoogleCerts.PublicKey.Mock do
  @firebaseid "e70db08935900d564aab27b39e6bd5c847d0413d"
  @exponent "AQAB"
  @modulus "zkSRsA8npcga4dKSt91-OtSXA481Y94jt5tn64h2MUtUnQ_1JP-4xcDBYVG52m1Cdc7Fq2_cpUOvm27jAxIc4oYxLk1YtyJX9ce5p2rkbKyC71nSq5om3rBE4n3hYUa0nPCcXNC0uC_G0UTVY_OsiYS6hSNVSnHqySn50yid8EBWY8sHHCsqEtlk4uwXXalgnpZ5BXI22yQWQASnZdeIiRKhxSWdkDrbLUq1FmyfNn9vabhIADZsdjCL3iCfJVW8YTdntObZRVsuh_ezm9K7-l3U400EvZA7RN_Dt5QGC6gSjo4syP5TkGXD6iC6rUx67FLzgww_Lo0O4kYEFzDLzw"

  def getfor(@firebaseid) do
    {:notfounderror, "Public key id not found"}
  end

  def getfor(_id) do
    {:ok,
     %{
       exp: :binary.decode_unsigned(Base.url_decode64!(@exponent, padding: false)),
       mod: :binary.decode_unsigned(Base.url_decode64!(@modulus, padding: false))
     }}
  end
end

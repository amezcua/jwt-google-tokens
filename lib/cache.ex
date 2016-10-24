defmodule Jwt.Cache do
    @callback invalidate() :: {:ok} | {:error, any}
    @callback get(uri :: String.t) :: {:ok, struct} | {:error, any}
    @callback set(uri :: String.t, data :: struct) :: {:ok, struct} | {:error, any}
end
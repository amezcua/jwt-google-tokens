defmodule Jwt.HttpCacheClient do
  require Logger
  @expires_header "Expires"

  def get!(uri, cache \\ Jwt.Cache.Ets, httpclient \\ HTTPoison) do
    {_result, value} = get(uri, cache, httpclient)
    value
  end

  def get(uri, cache \\ Jwt.Cache.Ets, httpclient \\ HTTPoison) do
    cache.get(uri)
    |> case do
      {:ok, cached_value} ->
        case expired_entry?(cached_value) do
          true -> request_and_cache(uri, cache, httpclient)
          false -> {:ok, cached_value}
        end

      {:error, _} ->
        request_and_cache(uri, cache, httpclient)
    end
  end

  defp expired_entry?(cached_value) do
    case Enum.find(cached_value.headers, fn header -> elem(header, 0) == @expires_header end) do
      {@expires_header, expires_value} -> expired_date?(expires_value)
      _ -> true
    end
  end

  defp request_and_cache(uri, cache, httpclient) do
    Logger.debug("Requesting URL: #{inspect(uri)}...")

    httpclient.get(uri)
    |> case do
      {:ok, response} -> cache_if_expires_header_present(uri, response, cache)
      {:error, _} -> {:error, uri}
    end
  end

  defp cache_if_expires_header_present(uri, response, cache) do
    case Enum.any?(response.headers, fn header -> elem(header, 0) == @expires_header end) do
      true -> cache.set(uri, response)
      false -> {:ok, response}
    end
  end

  defp expired_date?(date) do
    shifted_time = Timex.shift(Timex.parse!(date, "{RFC1123}"), minutes: -20)
    Timex.before?(shifted_time, Timex.now())
  end
end

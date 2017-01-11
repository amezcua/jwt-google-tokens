defmodule Jwt.Cache.Ets do
    use GenServer
    @behaviour Jwt.Cache

    require Logger

    @cache_name EtsCache
    @cache_table_name :certstable

    def start(_type, _args) do
        link = GenServer.start_link(__MODULE__, [], name: @cache_name)
        Logger.debug("Jwt.Cache.Ets Started: #{inspect link}")
        link
    end

    def invalidate(), do: GenServer.call(@cache_name, :invalidate)
    def get(uri), do: GenServer.call(@cache_name, {:get, uri})
    def set(uri, data), do: GenServer.call(@cache_name, {:set, uri, data})

    def init(_), do: {:ok, _invalidate()}
    def handle_call(:invalidate, _from, _), do: {:reply, _invalidate(), []}
    def handle_call({:get, uri}, _from, _), do: {:reply, _get(uri), uri}
    def handle_call({:set, uri, data}, _from, _), do: {:reply, _set(uri, data), uri}

    defp _invalidate() do
        :ets.info(@cache_table_name)
        |> create_cache
        |> case do
            @cache_table_name -> {:ok, @cache_table_name}
            _ -> {:error, "Failed to invalidate the cache"}
        end
    end

    defp create_cache(:undefined) do
        cache = :ets.new(@cache_table_name, [:named_table, :public])
        Logger.debug("Jwt.Cache.Ets.create_cache: #{inspect cache}")
        cache
    end

    defp create_cache(_) do
      :ets.delete(@cache_table_name)
      create_cache(:undefined)
    end

    defp _get(uri) do
        value = :ets.lookup(@cache_table_name, uri)
        case value do
          [] -> {:error, uri}
          _ -> {:ok,  elem(Enum.at(value, 0), 1)}
        end
    end

    defp _set(uri, data) do
        Logger.debug "#{inspect uri} saving to cache."
        :ets.insert(@cache_table_name, {uri, data})
        |> case do
          true -> {:ok, data}
          false -> {:error, uri}
        end
    end
end
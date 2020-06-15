defmodule Jwt.Plugs.FilterClaims do
  import Plug.Conn

  require Logger

  def init(opts), do: opts

  def call(conn, []), do: send_401(conn)

  def call(conn, opts) do
    filter_claims(conn.assigns[:jwtclaims], conn, opts)
  end

  defp filter_claims([], conn, _), do: send_401(conn)
  defp filter_claims(nil, conn, _), do: send_401(conn)

  defp filter_claims(claims, conn, filters) do
    evaluate_all_filters(claims, filters)
    |> all_filters_pass?
    |> deliver_filters_result(conn)
  end

  defp all_filters_pass?(evaluated_filters),
    do: Enum.all?(evaluated_filters, fn filter_passed -> filter_passed end)

  defp deliver_filters_result(true, conn), do: Plug.Conn.assign(conn, :jwtfilterclaims, {:ok})
  defp deliver_filters_result(false, conn), do: send_401(conn)

  defp evaluate_all_filters(claims, filters) do
    Enum.map(filters, fn filter -> evaluate_single_filter(claims, filter) end)
  end

  defp evaluate_single_filter(claims, filter) do
    {_key_in_claims, claims_value_for_filter} =
      find_first_instance_of_filter_in_claims(claims, filter)

    {_key_in_filter, filter_regex} = Enum.at(Map.to_list(filter), 0)

    Logger.debug(
      "Filter value: #{inspect(claims_value_for_filter)} with regex: #{inspect(filter_regex)}"
    )

    claims_value_for_filter
    |> case do
      :notfound ->
        false

      _ ->
        Enum.map(as_list(filter_regex), fn regex ->
          Regex.match?(Regex.compile!(regex), claims_value_for_filter)
        end)
        |> Enum.any?(fn matched -> matched end)
    end
  end

  defp find_first_instance_of_filter_in_claims(claims, filter) do
    matching_claim_list = Map.to_list(Map.take(claims, Map.keys(filter)))

    matching_claim_list
    |> Enum.count()
    |> case do
      0 -> {:error, :notfound}
      _ -> hd(matching_claim_list)
    end
  end

  defp as_list(filter) do
    is_list(filter)
    |> case do
      true -> filter
      false -> [filter]
    end
  end

  defp send_401(conn) do
    conn
    |> send_resp(401, "")
    |> halt
  end
end

alias CloudFlareUpdater.API, as: API

defmodule CloudFlareUpdater.Client do

  def start, do: API.start()

  def update(ip) do
    context = build_context()

    resp = get_zone(context)
    |> get_dns_record(context)
    |> set_dns_record(ip, context)

    IO.inspect resp
  end

  defp build_context do
    domain = Application.get_env(:cloud_flare_updater, :domain)
    [_, zone] = String.split(domain, ".", parts: 2)

    headers = %{
      "X-Auth-Email": Application.get_env(:cloud_flare_updater, :auth_email),
      "X-Auth-Key": Application.get_env(:cloud_flare_updater, :auth_key)
    }

    {zone, domain, headers}
  end

  defp get_zone({zone, _domain, headers}) do
    query = URI.encode_query(%{"name": zone})
    resp = API.get!("zones?" <> query, headers)
    List.first(resp.body["result"])
  end

  defp get_dns_record(zone, {_zone, domain, headers}) do
    url = :io_lib.format("zones/~s/dns_records", [zone["id"]])
    resp = API.get!(url, headers)

    Enum.find(resp.body["result"], fn(x) -> x["name"] == domain end)
  end

  defp set_dns_record(record, content, {_zone, _domain, headers}) do
    url = get_dns_record_url(record)
    data = build_dns_record_data(record, content)
    headers = Map.put(headers, "Content-Type", "application/json")

    IO.inspect record
    IO.inspect data

    API.put!(url, Poison.encode!(data), headers)
  end

  defp get_dns_record_url(record) do
    id = record["id"]
    zone_id = record["zone_id"]
    :io_lib.format("zones/~s/dns_records/~s", [zone_id, id])
  end

  defp build_dns_record_data(record, content) do
    preserve = ["id", "proxiable", "proxied", "name",
                "ttl", "type", "zone_id", "zone_name"]
    preserved = Map.take(record, preserve)
    Map.put(preserved, "content", content)
  end

end

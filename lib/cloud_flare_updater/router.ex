defmodule CloudFlareUpdater.Router do

  def get_ip do
    resp = HTTPoison.get!(get_url)

    Floki.find(resp.body, "table.colortable")
    |> Enum.at(2)
    |> Floki.find("table > tr")
    |> Enum.at(0)
    |> Floki.find("td")
    |> Enum.at(1)
    |> Floki.text
  end

  defp get_url do
    hostname = Application.get_env(:cloud_flare_updater, :router_hostname)
    :io_lib.format("http://~s/xslt?PAGE=C_1_0", [hostname])
  end

end

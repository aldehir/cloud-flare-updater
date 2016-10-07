defmodule CloudFlareUpdater.API do
  use HTTPoison.Base

  def process_url(url) do
    "https://api.cloudflare.com/client/v4/" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end
end

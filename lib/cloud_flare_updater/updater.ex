alias CloudFlareUpdater.Router, as: Router
alias CloudFlareUpdater.Client, as: Client

defmodule CloudFlareUpdater.Updater do

  def start do
    HTTPoison.start
    Client.start
  end

  def update do
    Router.get_ip
    |> Client.update
  end

end

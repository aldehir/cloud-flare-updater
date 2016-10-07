alias CloudFlareUpdater.Updater, as: Updater

defmodule CloudFlareUpdater.CLI do

  def main(_argv) do
    Updater.start

    minutes = Application.get_env(:cloud_flare_updater, :interval)
    milliseconds = minutes * 60 * 1000

    :timer.send_interval milliseconds, self, :update
    start
  end

  defp start do
    Updater.update
    loop
  end

  defp loop do
    receive do
      :update ->
        Updater.update
        loop
    end
  end

end

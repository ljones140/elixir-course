defmodule TextClient.Runtime.RemoteHangman do

  # This is your actual machine name
  # TODO: use env var
  @remote_server :"hangman@{machinename}"

  def connect() do
    :rpc.call(@remote_server, Hangman, :new_game, [])
  end
end

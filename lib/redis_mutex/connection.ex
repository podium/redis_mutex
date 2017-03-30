defmodule RedisMutex.Connection do
  @moduledoc """
  This module contains connects to the Redis instance.
  """
  def start_link(name, uri) do
    client = Exredis.start_using_connection_string(uri)
    true = Process.register(client, name)
    {:ok, client}
  end
end

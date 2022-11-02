defmodule RedisMutex.Connection do
  @moduledoc """
  This module connects to the Redis instance.
  """
  def start_link(name, uri) do
    Redix.start_link(uri, name: name)
  end
end

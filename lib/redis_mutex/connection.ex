defmodule RedisMutex.Connection do
  @moduledoc """
  This module connects to the Redis instance.
  """

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(name, uri) do
    Redix.start_link(uri, name: name, sync_connect: true)
  end
end

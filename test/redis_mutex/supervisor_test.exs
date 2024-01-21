defmodule RedisMutex.SupervisorTest do
  use ExUnit.Case, async: true

  import Mox

  alias RedisMutex.Supervisor

  describe "init/1" do
    test "should start children with the options provided" do
      lock_module = RedisMutex.LockMock

      opts = [
        redis_url: "redis://localhost:6379",
        name: RedisMutex
      ]

      expect(RedisMutex.LockMock, :child_spec, fn spec_opts ->
        %{
          id: RedisMutex.LockMock,
          start: {RedisMutex.LockMock, :start_link, [spec_opts]},
          type: :worker
        }
      end)

      assert {:ok, {strategy, [child]}} = Supervisor.init({lock_module, opts})
      assert strategy.strategy == :one_for_one

      assert %{
               id: RedisMutex.LockMock,
               type: :worker,
               start: {RedisMutex.LockMock, :start_link, start_opts}
             } = child

      assert start_opts == [
               [[redis_url: "redis://localhost:6379", name: RedisMutex]]
             ]
    end
  end
end

defmodule RedisMutex.SupervisorTest do
  use ExUnit.Case, async: true

  import Mox

  alias RedisMutex.Supervisor

  describe "init/1" do
    test "should start children with the options provided" do
      otp_app = :my_app
      module = RedisMutex.SupervisorTest.MyModule
      lock_module = RedisMutex.LockV2Mock

      opts = [
        redis_url: "redis://localhost:6379",
        name: RedisMutex.SupervisorTest.MyModule
      ]

      expect(RedisMutex.LockV2Mock, :child_spec, fn spec_opts ->
        dbg(spec_opts)

        %{
          id: RedisMutex.LockV2Mock,
          start: {RedisMutex.LockV2Mock, :start_link, [spec_opts]},
          type: :worker
        }
      end)

      assert {:ok, {strategy, [child]}} = Supervisor.init({otp_app, module, lock_module, opts})
      assert strategy.strategy == :one_for_one

      assert %{
               id: RedisMutex.LockV2Mock,
               type: :worker,
               start: {RedisMutex.LockV2Mock, :start_link, start_opts}
             } = child

      assert start_opts == [
               [redis_url: "redis://localhost:6379", name: RedisMutex.SupervisorTest.MyModule]
             ]
    end
  end
end

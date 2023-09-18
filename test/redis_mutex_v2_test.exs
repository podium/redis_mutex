defmodule RedisMutexV2Test do
  use ExUnit.Case, async: true

  import Mox

  alias RedisMutex.LockV2Mock

  setup :verify_on_exit!

  defmodule RedisMutexUser do
    use RedisMutexV2, otp_app: :redis_mutex, lock_module: RedisMutex.LockV2Mock

    def two_plus_two(key, timeout, expiry) do
      with_lock(key, timeout, expiry) do
        2 + 2
      end
    end
  end

  setup do
    stub(LockV2Mock, :child_spec, fn _opts -> :ignore end)
    stub(LockV2Mock, :start_link, fn _opts -> :ignore end)
    start_supervised(RedisMutexUser, [])
    :ok
  end

  describe "__using__/1" do
    test "should use the lock module specified" do
      my_key = "my-key"
      my_timeout = 200
      my_expiry = 2_000

      expect(LockV2Mock, :with_lock, fn key, timeout, expiry, do_clause ->
        assert key == my_key
        assert timeout == my_timeout
        assert expiry == my_expiry

        [do: block_value] =
          quote do
            unquote(do_clause)
          end

        block_value
      end)

      assert 4 == RedisMutexUser.two_plus_two(my_key, my_timeout, my_expiry)
    end
  end
end

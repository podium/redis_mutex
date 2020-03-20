defmodule RedisMutexWithoutMockTest do
  use ExUnit.Case
  use RedisMutex, cache_client_env: :not_a_test_env
  doctest RedisMutex

  @moduletag :redis_dependent

  describe "with_lock" do
    test "works with two tasks contending for the same lock, making one run after the other" do
      [start_1, end_1, start_2, end_2] =
        Enum.map(1..2, fn _ ->
          Task.async(fn ->
            with_lock("two_threads_lock") do
              start_time = Timex.now()
              end_time = Timex.now()
              {start_time, end_time}
            end
          end)
        end)
        |> Task.yield_many(5000)
        |> Enum.map(fn {task, res} ->
          # Shut down the tasks that did not reply nor exit
          res || Task.shutdown(task, :brutal_kill)
        end)
        |> Enum.flat_map(fn result ->
          case result do
            {:ok, {start_time, end_time}} -> [start_time, end_time]
            {:error, e} -> raise e
          end
        end)

      assert Timex.before?(start_1, end_1)
      assert Timex.before?(start_2, end_2)

      # one ran before the other, regardless of which
      assert (Timex.before?(start_1, start_2) and Timex.before?(end_1, end_2)) or
               (Timex.before?(start_2, start_1) and Timex.before?(end_2, end_1))
    end
  end
end

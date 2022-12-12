defmodule RedisMutexWithoutMockTest do
  use ExUnit.Case
  use RedisMutex, lock_module: RedisMutex.Lock
  doctest RedisMutex

  @moduletag :redis_dependent

  describe "with_lock" do
    test "works with two tasks contending for the same lock, making one run after the other" do
      res =
        run_in_parallel(2, 5000, fn ->
          with_lock("two_threads_lock") do
            start_time = DateTime.utc_now()
            end_time = DateTime.utc_now()
            {start_time, end_time}
          end
        end)

      [start_1, end_1, start_2, end_2] =
        Enum.flat_map(res, fn result ->
          case result do
            {:ok, {start_time, end_time}} -> [start_time, end_time]
            {:error, e} -> raise e
          end
        end)

      assert DateTime.compare(start_1, end_1) == :lt
      assert DateTime.compare(start_2, end_2) == :lt

      # one ran before the other, regardless of which
      assert (DateTime.compare(start_1, start_2) == :lt and DateTime.compare(end_1, end_2) == :lt) or
               (DateTime.compare(start_2, start_1) == :lt and
                  DateTime.compare(end_2, end_1) == :lt)
    end

    test "only runs one of the two tasks when the other times out attempting to acquire the lock" do
      res =
        run_in_parallel(2, 5000, fn ->
          try do
            # Make sure this doesn't conflict with other tests in this file
            # because everything gets run async and they could step on each other
            with_lock("two_threads_one_loses_lock", 500) do
              start_time = DateTime.utc_now()
              :timer.sleep(1000)
              end_time = DateTime.utc_now()
              {start_time, end_time}
            end
          rescue
            RedisMutex.Error -> :timed_out
          end
        end)

      [result_1, result_2] =
        Enum.map(res, fn result ->
          case result do
            {:ok, {start_time, end_time}} -> [start_time, end_time]
            error -> error
          end
        end)

      # make sure one task failed and one task succeeded, regardless of which
      cond do
        is_tuple(result_1) ->
          assert {:ok, :timed_out} == result_1
          [start_time, end_time] = result_2
          assert DateTime.compare(start_time, end_time) == :lt

        is_tuple(result_2) ->
          assert {:ok, :timed_out} == result_2
          [start_time, end_time] = result_1
          assert DateTime.compare(start_time, end_time) == :lt

        true ->
          flunk("Both tasks ran, which means our lock timeout did not work!")
      end
    end

    test "expires the lock after the given time" do
      # Kick off a task that will run for a long time, holding the lock
      t =
        Task.async(fn ->
          with_lock("two_threads_lock_expires", 10_000, 250) do
            :timer.sleep(10_000)
          end
        end)

      # let enough time pass so that the lock expire
      Task.yield(t, 1000)

      # try to run another task and see if it gets the lock
      results =
        with_lock("two_threads_lock_expires", 1000, 500) do
          "I RAN!!!"
        end

      Task.shutdown(t, :brutal_kill)

      assert results == "I RAN!!!"
    end
  end

  defp run_in_parallel(concurrency, timeout, content) do
    1..concurrency
    |> Enum.map(fn _ ->
      Task.async(content)
    end)
    |> Task.yield_many(timeout)
    |> Enum.map(fn {task, res} ->
      # Shut down the tasks that did not reply nor exit
      res || Task.shutdown(task, :brutal_kill)
    end)
  end
end

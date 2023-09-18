defmodule RedisMutexTest do
  use ExUnit.Case
  use RedisMutex
  doctest RedisMutex

  @moduletag :skip

  describe "with_lock" do
    test "with_lock returns value of the contained logic" do
      possum_lodge_motto =
        with_lock("red_green") do
          "I'm a man, but I can change. If I have to. I guess."
        end

      assert possum_lodge_motto == "I'm a man, but I can change. If I have to. I guess."
    end
  end
end

defmodule ActiveJobTest do
  use ExUnit.Case
  doctest ActiveJob

  test "greets the world" do
    assert ActiveJob.hello() == :world
  end
end

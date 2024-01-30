defmodule JugglerTest do
  use ExUnit.Case
  doctest Juggler

  test "greets the world" do
    assert Juggler.hello() == :world
  end
end

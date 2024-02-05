defmodule JugglerTest do
  use ExUnit.Case
  doctest Juggler

  @tmp_path Path.expand("../tmp", __DIR__)

  setup do
    File.mkdir_p!(@tmp_path)
    on_exit(fn -> File.rm_rf(@tmp_path) end)
    :ok
  end

  test "greets the world" do
    File.cd!(
      @tmp_path,
      fn ->
        refute File.exists?("juggles.exs")
        assert Juggler.init() == :ok
        assert File.exists?("juggles.exs")
      end
    )
  end
end
